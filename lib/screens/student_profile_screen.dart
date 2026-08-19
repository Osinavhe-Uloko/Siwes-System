import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/app_user.dart';
import '../models/attendance_checkin.dart';
import '../models/logbook_entry.dart';
import '../models/placement.dart';
import '../providers.dart';
import '../routes.dart';
import '../services/location_service.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  final String studentId;

  const StudentProfileScreen({super.key, required this.studentId});

  @override
  ConsumerState<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  static const _uuid = Uuid();

  bool _loading = true;
  String? _loadError;
  AppUser? _student;
  List<LogbookEntry> _entries = [];
  AppUser? _institutionSupervisor;
  Placement? _placement;
  AppUser? _industrySupervisor;
  List<AttendanceCheckIn> _checkIns = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final results = await (
        firestore.getUser(widget.studentId),
        firestore.getEntriesForStudent(widget.studentId),
        firestore.getPlacementForStudent(widget.studentId),
        firestore.getCheckInsForStudent(widget.studentId),
      ).wait;
      final student = results.$1;
      final entries = results.$2;
      final placement = results.$3;
      final checkIns = results.$4;

      final lookups = await (
        student?.institutionSupervisorId != null
            ? firestore.getUser(student!.institutionSupervisorId!)
            : Future.value(null),
        placement?.industrySupervisorId != null
            ? firestore.getUser(placement!.industrySupervisorId!)
            : Future.value(null),
      ).wait;

      if (!mounted) return;
      setState(() {
        _student = student;
        _entries = entries;
        _placement = placement;
        _checkIns = checkIns;
        _institutionSupervisor = lookups.$1;
        _industrySupervisor = lookups.$2;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _reviewEntry(LogbookEntry entry, String status) async {
    final commentCtrl = TextEditingController(text: entry.supervisorComment ?? '');
    final comment = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(status == 'reviewed' ? 'Approve Entry' : 'Request Changes'),
        content: TextField(
          controller: commentCtrl,
          autofocus: true,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Comment (optional)',
            hintText: 'Feedback for the student...',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, commentCtrl.text.trim()),
            child: Text(status == 'reviewed' ? 'Approve' : 'Submit'),
          ),
        ],
      ),
    );
    if (comment == null) return;

    // Update the UI immediately rather than waiting on the round trip and a
    // full reload — the write happens in the background, and only rolls
    // the card back if it actually fails.
    final index = _entries.indexWhere((e) => e.id == entry.id);
    final previous = _entries[index];
    setState(() {
      _entries[index] = LogbookEntry(
        id: previous.id,
        studentId: previous.studentId,
        entryDate: previous.entryDate,
        submittedAt: previous.submittedAt,
        content: previous.content,
        weekNumber: previous.weekNumber,
        status: status,
        supervisorComment: comment.isNotEmpty ? comment : previous.supervisorComment,
        grade: previous.grade,
      );
    });

    try {
      await ref.read(firestoreServiceProvider).updateEntry(entry.id, {
        'status': status,
        if (comment.isNotEmpty) 'supervisor_comment': comment,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _entries[index] = previous);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update entry: $e')),
      );
    }
  }

  Future<void> _assignInstitutionSupervisor() async {
    final firestore = ref.read(firestoreServiceProvider);
    final options = await firestore.getUsersByRole('institution_supervisor');
    if (!mounted) return;
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No institution supervisors exist yet.')),
      );
      return;
    }

    final selected = await showDialog<AppUser>(
      context: context,
      builder: (context) => _SupervisorPickerDialog(title: 'Assign Institution Supervisor', options: options),
    );
    if (selected == null) return;

    await firestore.assignInstitutionSupervisor(widget.studentId, selected.id);
    await _load();
  }

  Future<void> _createPlacement() async {
    final firestore = ref.read(firestoreServiceProvider);
    final industrySupervisors = await firestore.getUsersByRole('industry_supervisor');
    if (!mounted) return;
    if (industrySupervisors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No industry supervisors exist yet. Create one before adding a placement.')),
      );
      return;
    }

    // Editing reuses the existing placement's id so the form updates that
    // document in place (e.g. adding a GPS location later) instead of
    // creating a second, duplicate placement for the same student.
    final existing = _placement;
    final placement = await showDialog<Placement>(
      context: context,
      builder: (context) => _PlacementFormDialog(
        id: existing?.id ?? _uuid.v4(),
        studentId: widget.studentId,
        industrySupervisors: industrySupervisors,
        existing: existing,
      ),
    );
    if (placement == null) return;

    await firestore.setPlacement(placement);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 40, color: Colors.red),
              const SizedBox(height: 12),
              Text('Failed to load student: $_loadError', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_student == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Student not found.'),
            TextButton(onPressed: () => context.go(Routes.students), child: const Text('Return to students')),
          ],
        ),
      );
    }

    final student = _student!;
    final viewerRole = ref.read(authServiceProvider).currentUser?.role;
    // Only the industry supervisor reviews day-to-day logbook entries —
    // they're the one who witnesses the work at the placement. The
    // institution supervisor's role here is oversight: view entries and
    // the industry supervisor's comments, not approve/flag them.
    final canReview = viewerRole == 'industry_supervisor';
    final isCoordinator = viewerRole == 'coordinator';

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(Routes.students),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Profile', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Viewing logbook and details for ${student.name}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  child: Text(student.name.isNotEmpty ? student.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(student.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('${student.email} • ${student.phone}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Matric Number', style: Theme.of(context).textTheme.labelSmall),
                                Text(student.matricNumber ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Department', style: Theme.of(context).textTheme.labelSmall),
                                Text('${student.department ?? 'N/A'} (${student.level ?? 'N/A'}L)',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Placement & Supervisors', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _AssignmentTile(
            label: 'Institution Supervisor',
            person: _institutionSupervisor,
            actionLabel: isCoordinator ? 'Assign' : null,
            onAction: _assignInstitutionSupervisor,
          ),
          const SizedBox(height: 12),
          _PlacementTile(
            placement: _placement,
            industrySupervisor: _industrySupervisor,
            actionLabel: isCoordinator ? (_placement == null ? 'Create Placement' : 'Edit Placement') : null,
            onAction: _createPlacement,
          ),
          const SizedBox(height: 20),
          Text('GPS Attendance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            'Daily on-site check-ins recorded before the logbook entry for that day could be submitted.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          if (_checkIns.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('No GPS check-ins recorded yet.'),
            )
          else
            ..._checkIns.map((checkIn) => _CheckInTile(checkIn: checkIn)),
          const SizedBox(height: 20),
          Text('Logbook Entries', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('No logbook entries found for this student.'),
            )
          else
            ..._entries.map((entry) => _EntryReviewCard(
                  entry: entry,
                  showActions: canReview && entry.status == 'pending',
                  onApprove: () => _reviewEntry(entry, 'reviewed'),
                  onFlag: () => _reviewEntry(entry, 'flagged'),
                )),
        ],
      ),
    );
  }
}

class _AssignmentTile extends StatelessWidget {
  final String label;
  final AppUser? person;
  final String? actionLabel;
  final VoidCallback onAction;

  const _AssignmentTile({required this.label, required this.person, required this.actionLabel, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                if (person == null)
                  const Text('Not assigned yet')
                else
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        child: Text(person!.name.isNotEmpty ? person!.name[0].toUpperCase() : '?'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(person!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(person!.email, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _PlacementTile extends StatelessWidget {
  final Placement? placement;
  final AppUser? industrySupervisor;
  final String? actionLabel;
  final VoidCallback onAction;

  const _PlacementTile({
    required this.placement,
    required this.industrySupervisor,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Placement', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 8),
                if (placement == null)
                  const Text('No placement recorded yet')
                else ...[
                  Text(placement!.companyName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('${placement!.industrySector} • ${placement!.state}', style: Theme.of(context).textTheme.bodySmall),
                  Text('${placement!.startDate} – ${placement!.endDate}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  Text('Industry Supervisor', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  if (industrySupervisor == null)
                    const Text('Not assigned yet')
                  else
                    Text(industrySupervisor!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Text('GPS Location', style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        placement!.hasLocation ? Icons.check_circle_outline : Icons.location_off_outlined,
                        size: 14,
                        color: placement!.hasLocation ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          placement!.hasLocation
                              ? '${placement!.latitude!.toStringAsFixed(5)}, ${placement!.longitude!.toStringAsFixed(5)}'
                              : 'Not set — check-in unavailable until this is registered',
                          style: TextStyle(fontWeight: FontWeight.w600, color: placement!.hasLocation ? null : Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _SupervisorPickerDialog extends StatefulWidget {
  final String title;
  final List<AppUser> options;

  const _SupervisorPickerDialog({required this.title, required this.options});

  @override
  State<_SupervisorPickerDialog> createState() => _SupervisorPickerDialogState();
}

class _SupervisorPickerDialogState extends State<_SupervisorPickerDialog> {
  AppUser? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: DropdownButtonFormField<AppUser>(
        value: _selected,
        isExpanded: true,
        items: [
          for (final option in widget.options)
            DropdownMenuItem(value: option, child: Text(option.name, overflow: TextOverflow.ellipsis)),
        ],
        onChanged: (v) => setState(() => _selected = v),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(context, _selected), child: const Text('Assign')),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }
}

class _PlacementFormDialog extends StatefulWidget {
  final String id;
  final String studentId;
  final List<AppUser> industrySupervisors;
  final Placement? existing;

  const _PlacementFormDialog({
    required this.id,
    required this.studentId,
    required this.industrySupervisors,
    this.existing,
  });

  @override
  State<_PlacementFormDialog> createState() => _PlacementFormDialogState();
}

class _PlacementFormDialogState extends State<_PlacementFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _companyCtrl = TextEditingController(text: widget.existing?.companyName);
  late final _addressCtrl = TextEditingController(text: widget.existing?.companyAddress);
  late final _stateCtrl = TextEditingController(text: widget.existing?.state);
  late final _sectorCtrl = TextEditingController(text: widget.existing?.industrySector);
  final _location = LocationService();
  late DateTime _startDate = _tryParseDate(widget.existing?.startDate) ?? DateTime.now();
  late DateTime _endDate = _tryParseDate(widget.existing?.endDate) ?? DateTime.now().add(const Duration(days: 180));
  late AppUser? _industrySupervisor = _findById(widget.industrySupervisors, widget.existing?.industrySupervisorId);
  late double? _latitude = widget.existing?.latitude;
  late double? _longitude = widget.existing?.longitude;
  bool _locating = false;
  String? _locationError;

  static DateTime? _tryParseDate(String? value) => value == null ? null : DateTime.tryParse(value);

  static AppUser? _findById(List<AppUser> options, String? id) {
    if (id == null) return null;
    for (final option in options) {
      if (option.id == id) return option;
    }
    return null;
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _addressCtrl.dispose();
    _stateCtrl.dispose();
    _sectorCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = picked : _endDate = picked);
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _locationError = null;
    });
    try {
      final position = await _location.getCurrentPosition();
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    } catch (e) {
      setState(() => _locationError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('yyyy-MM-dd');
    final colorScheme = Theme.of(context).colorScheme;
    final locationSet = _latitude != null;
    final locationColor = locationSet ? Colors.green : Colors.amber;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.business_center_rounded, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.existing == null ? 'Create Placement' : 'Edit Placement',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SectionLabel('Company Details'),
              const SizedBox(height: 10),
              TextFormField(
                controller: _companyCtrl,
                decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.apartment_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(labelText: 'Company Address', prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stateCtrl,
                decoration: const InputDecoration(labelText: 'State', prefixIcon: Icon(Icons.map_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sectorCtrl,
                decoration: const InputDecoration(labelText: 'Industry Sector', prefixIcon: Icon(Icons.category_outlined)),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Duration'),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _pickDate(isStart: true),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Start Date', prefixIcon: Icon(Icons.event_outlined)),
                  child: Text(fmt.format(_startDate)),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _pickDate(isStart: false),
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'End Date', prefixIcon: Icon(Icons.event_available_outlined)),
                  child: Text(fmt.format(_endDate)),
                ),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('Supervision'),
              const SizedBox(height: 10),
              DropdownButtonFormField<AppUser?>(
                value: _industrySupervisor,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Industry Supervisor', prefixIcon: Icon(Icons.person_outline)),
                items: [
                  for (final option in widget.industrySupervisors)
                    DropdownMenuItem(value: option, child: Text(option.name, overflow: TextOverflow.ellipsis)),
                ],
                validator: (v) => v == null ? 'Required' : null,
                onChanged: (v) => setState(() => _industrySupervisor = v),
              ),
              const SizedBox(height: 20),
              const _SectionLabel('GPS Location'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: locationColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: locationColor.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          locationSet ? Icons.check_circle_outline : Icons.location_off_outlined,
                          size: 18,
                          color: locationColor.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationSet
                                ? 'Captured: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                                : "Not set — students can't check in until this is captured on-site.",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: locationColor.shade900),
                          ),
                        ),
                      ],
                    ),
                    if (_locationError != null) ...[
                      const SizedBox(height: 8),
                      Text(_locationError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _locating ? null : _useCurrentLocation,
                      icon: _locating
                          ? const SizedBox(height: 14, width: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location, size: 16),
                      label: Text(_locating ? 'Locating…' : (locationSet ? 'Update Location' : 'Use Current Location')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              Placement(
                id: widget.id,
                studentId: widget.studentId,
                companyName: _companyCtrl.text.trim(),
                companyAddress: _addressCtrl.text.trim(),
                state: _stateCtrl.text.trim(),
                industrySector: _sectorCtrl.text.trim(),
                startDate: fmt.format(_startDate),
                endDate: fmt.format(_endDate),
                industrySupervisorId: _industrySupervisor?.id,
                latitude: _latitude,
                longitude: _longitude,
              ),
            );
          },
          icon: const Icon(Icons.check, size: 18),
          label: Text(widget.existing == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}

class _EntryReviewCard extends StatelessWidget {
  final LogbookEntry entry;
  final bool showActions;
  final VoidCallback onApprove;
  final VoidCallback onFlag;

  const _EntryReviewCard({
    required this.entry,
    required this.showActions,
    required this.onApprove,
    required this.onFlag,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(entry.entryDate);
    Color statusColor;
    IconData statusIcon;
    switch (entry.status) {
      case 'reviewed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'flagged':
        statusColor = Colors.red;
        statusIcon = Icons.warning_amber_outlined;
        break;
      default:
        statusColor = Colors.amber.shade700;
        statusIcon = Icons.schedule;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 16),
                const SizedBox(width: 8),
                Text(date != null ? DateFormat('MMM d, yyyy').format(date) : entry.entryDate,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), color: Theme.of(context).colorScheme.surfaceContainerHighest),
                  child: Text('Week ${entry.weekNumber}', style: Theme.of(context).textTheme.labelSmall),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(entry.status[0].toUpperCase() + entry.status.substring(1),
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.content),
                if (entry.supervisorComment != null && entry.supervisorComment!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.chat_bubble_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Industry Supervisor Comment',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text(entry.supervisorComment!),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          ),
                          onPressed: onApprove,
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Approve Entry', maxLines: 1, softWrap: false),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                          onPressed: onFlag,
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Request Changes', maxLines: 1, softWrap: false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckInTile extends StatelessWidget {
  final AttendanceCheckIn checkIn;

  const _CheckInTile({required this.checkIn});

  Future<void> _openMap() async {
    final uri = Uri.parse('https://www.google.com/maps?q=${checkIn.latitude},${checkIn.longitude}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(checkIn.date);
    final checkedInAt = DateTime.fromMillisecondsSinceEpoch(checkIn.checkedInAt);
    final color = checkIn.withinRange ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(checkIn.withinRange ? Icons.verified_outlined : Icons.error_outline, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date != null ? DateFormat('EEEE, MMMM d, yyyy').format(date) : checkIn.date,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${DateFormat('h:mm a').format(checkedInAt)} • '
                  '${checkIn.withinRange ? 'On-site' : '${checkIn.distanceMeters.round()}m from placement'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'View on map',
            icon: const Icon(Icons.map_outlined, size: 20),
            onPressed: _openMap,
          ),
        ],
      ),
    );
  }
}
