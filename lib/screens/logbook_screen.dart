import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/attendance_checkin.dart';
import '../models/compliance_flag.dart';
import '../models/logbook_entry.dart';
import '../models/placement.dart';
import '../providers.dart';
import '../services/location_service.dart';
import '../widgets/page_header.dart';

class LogbookScreen extends ConsumerStatefulWidget {
  const LogbookScreen({super.key});

  @override
  ConsumerState<LogbookScreen> createState() => _LogbookScreenState();
}

class _LogbookScreenState extends ConsumerState<LogbookScreen> {
  static const _uuid = Uuid();

  bool _loading = true;
  bool _showForm = false;
  bool _submitting = false;
  bool _checkingIn = false;
  String? _checkInError;
  List<LogbookEntry> _entries = [];
  Placement? _placement;
  AttendanceCheckIn? _todayCheckIn;

  final _formKey = GlobalKey<FormState>();
  final _contentCtrl = TextEditingController();
  final _weekCtrl = TextEditingController(text: '1');
  DateTime _entryDate = DateTime.now();

  String get _today => DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool get _checkedInToday => _todayCheckIn?.withinRange == true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    _weekCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = ref.read(authServiceProvider).currentUser!;
    final firestore = ref.read(firestoreServiceProvider);
    final results = await (
      firestore.getEntriesForStudent(user.id),
      firestore.getPlacementForStudent(user.id),
      firestore.getCheckInForDate(user.id, _today),
    ).wait;
    if (!mounted) return;
    setState(() {
      _entries = results.$1;
      _placement = results.$2;
      _todayCheckIn = results.$3;
      _loading = false;
    });
    _updateWeekNumber();
  }

  /// Fills the week-number field with how many weeks into the placement
  /// [_entryDate] falls on (week 1 = the placement's start date and the six
  /// days after it), instead of always defaulting to 1. Still a plain text
  /// field, so the student can override it if a week genuinely needs to be
  /// logged differently.
  void _updateWeekNumber() {
    final start = DateTime.tryParse(_placement?.startDate ?? '');
    if (start == null) return;
    final startDateOnly = DateTime(start.year, start.month, start.day);
    final entryDateOnly = DateTime(_entryDate.year, _entryDate.month, _entryDate.day);
    final daysSinceStart = entryDateOnly.difference(startDateOnly).inDays;
    final week = (daysSinceStart / 7).floor() + 1;
    _weekCtrl.text = '${week < 1 ? 1 : week}';
  }

  Future<void> _checkIn() async {
    final placement = _placement;
    if (placement == null || !placement.hasLocation) return;

    setState(() {
      _checkingIn = true;
      _checkInError = null;
    });
    try {
      final user = ref.read(authServiceProvider).currentUser!;
      final firestore = ref.read(firestoreServiceProvider);
      final location = ref.read(locationServiceProvider);

      final position = await location.getCurrentPosition();
      final distance = location.distanceMeters(
        lat1: position.latitude,
        lng1: position.longitude,
        lat2: placement.latitude!,
        lng2: placement.longitude!,
      );
      final withinRange = distance <= kCheckInRadiusMeters;

      final checkIn = AttendanceCheckIn(
        id: const Uuid().v4(),
        studentId: user.id,
        placementId: placement.id,
        date: _today,
        checkedInAt: DateTime.now().millisecondsSinceEpoch,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceMeters: distance,
        withinRange: withinRange,
      );
      await firestore.addCheckIn(checkIn);

      if (!mounted) return;
      setState(() => _todayCheckIn = checkIn);
      if (!withinRange) {
        setState(() => _checkInError =
            'You appear to be ${distance.round()}m from your placement (needs to be within ${kCheckInRadiusMeters.round()}m). Move closer and try again.');
      }
    } catch (e) {
      if (mounted) setState(() => _checkInError = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _checkingIn = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) {
      setState(() => _entryDate = picked);
      _updateWeekNumber();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final user = ref.read(authServiceProvider).currentUser!;
      final firestore = ref.read(firestoreServiceProvider);
      final now = DateTime.now().millisecondsSinceEpoch;
      final thirtyMinAgo = now - (30 * 60 * 1000);

      // Anomaly detection: 3+ entries submitted within 30 minutes.
      final recentCount = await firestore.countEntriesSince(user.id, thirtyMinAgo);

      final entry = LogbookEntry(
        id: _uuid.v4(),
        studentId: user.id,
        entryDate: DateFormat('yyyy-MM-dd').format(_entryDate),
        submittedAt: now,
        content: _contentCtrl.text.trim(),
        weekNumber: int.tryParse(_weekCtrl.text) ?? 1,
        status: 'pending',
      );
      await firestore.addEntry(entry);

      if (recentCount >= 2) {
        await firestore.addFlag(ComplianceFlag(
          id: _uuid.v4(),
          studentId: user.id,
          logbookEntryId: entry.id,
          flagType: 'backdated_cluster',
          detectedAt: now,
          resolved: false,
        ));
      }

      _contentCtrl.clear();
      setState(() => _showForm = false);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit entry: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PageHeader(
            icon: Icons.menu_book_rounded,
            title: 'My Logbook',
            subtitle: 'Your weekly SIWES activity log.',
            trailing: _checkedInToday
                ? FilledButton.icon(
                    onPressed: () => setState(() => _showForm = !_showForm),
                    icon: Icon(_showForm ? Icons.close : Icons.add),
                    label: Text(_showForm ? 'Cancel' : 'Add Entry'),
                  )
                : null,
          ),
          const SizedBox(height: 16),
          _CheckInGateCard(
            placement: _placement,
            checkedInToday: _checkedInToday,
            checkingIn: _checkingIn,
            error: _checkInError,
            onCheckIn: _checkIn,
          ),
          if (_showForm) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('New Logbook Entry', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date of Activity'),
                        child: Text(DateFormat('EEEE, MMMM d, yyyy').format(_entryDate)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _weekCtrl,
                      decoration: const InputDecoration(labelText: 'Week Number'),
                      keyboardType: TextInputType.number,
                      validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter a valid week number' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Activity Description',
                        helperText: 'Detailed description of tasks performed.',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _submitting ? null : _submit,
                        child: _submitting
                            ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Submit Entry'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Note: The server permanently records the exact time of submission. Submitting multiple entries in quick succession may flag your account for backdating.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_entries.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  const Icon(Icons.menu_book_outlined, size: 48),
                  const SizedBox(height: 12),
                  const Text('No entries yet', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Get started by creating a new logbook entry.'),
                ],
              ),
            )
          else
            ..._entries.map((entry) => _EntryCard(entry: entry)),
        ],
      ),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final LogbookEntry entry;

  const _EntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(entry.entryDate);
    final submitted = DateTime.fromMillisecondsSinceEpoch(entry.submittedAt);

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Week ${entry.weekNumber} • ${date != null ? DateFormat('EEEE, MMMM d, yyyy').format(date) : entry.entryDate}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Submitted: ${DateFormat('MMM d, yyyy h:mm a').format(submitted)}',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                _StatusChip(status: entry.status),
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
                              Text('Supervisor Comment',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
                              Text(entry.supervisorComment!),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _CheckInGateCard extends StatelessWidget {
  final Placement? placement;
  final bool checkedInToday;
  final bool checkingIn;
  final String? error;
  final VoidCallback onCheckIn;

  const _CheckInGateCard({
    required this.placement,
    required this.checkedInToday,
    required this.checkingIn,
    required this.error,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    if (placement == null) {
      return const _InfoBanner(
        icon: Icons.info_outline,
        color: Colors.blueGrey,
        title: 'No placement yet',
        message: "Your coordinator hasn't set up your placement yet, so daily GPS check-in isn't available.",
      );
    }
    if (!placement!.hasLocation) {
      return const _InfoBanner(
        icon: Icons.location_off_outlined,
        color: Colors.blueGrey,
        title: 'Placement location not set',
        message: "Ask your coordinator or industry supervisor to register your placement's GPS location.",
      );
    }
    if (checkedInToday) {
      return const _InfoBanner(
        icon: Icons.verified_outlined,
        color: Colors.green,
        title: 'Checked in today',
        message: "You're verified on-site. You can submit today's logbook entry.",
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_searching, color: Colors.amber.shade800),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Check in at your placement to unlock today's logbook entry.",
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                ),
              ),
            ],
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.red, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: checkingIn ? null : onCheckIn,
            icon: checkingIn
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.my_location),
            label: Text(checkingIn ? 'Checking in…' : 'Check In at Placement'),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final MaterialColor color;
  final String title;
  final String message;

  const _InfoBanner({required this.icon, required this.color, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color.shade900)),
                const SizedBox(height: 2),
                Text(message, style: TextStyle(color: color.shade900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color color;
    late final IconData icon;
    switch (status) {
      case 'reviewed':
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
      case 'flagged':
        color = Colors.red;
        icon = Icons.warning_amber_outlined;
        break;
      default:
        color = Colors.amber.shade700;
        icon = Icons.schedule;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(status[0].toUpperCase() + status.substring(1), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
