import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_user.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/stat_grid.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard> {
  bool _loading = true;
  int _totalEntries = 0;
  int _pending = 0;
  int _reviewed = 0;
  int _flags = 0;
  int _missedDays = 0;
  AppUser? _institutionSupervisor;
  AppUser? _industrySupervisor;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authServiceProvider).currentUser!;
    final firestore = ref.read(firestoreServiceProvider);

    // These four queries don't depend on each other, so run them
    // concurrently instead of one round trip at a time.
    final results = await (
      firestore.getEntriesForStudent(user.id),
      firestore.getFlagsForStudent(user.id),
      user.institutionSupervisorId != null ? firestore.getUser(user.institutionSupervisorId!) : Future.value(null),
      firestore.getPlacementForStudent(user.id),
    ).wait;
    final entries = results.$1;
    final flags = results.$2;
    final instSup = results.$3;
    final placement = results.$4;
    final unresolvedFlags = flags.where((f) => !f.resolved).length;

    // The industry supervisor id only exists once the placement has
    // loaded, so this one has to wait for the fetch above.
    AppUser? indSup;
    if (placement?.industrySupervisorId != null) {
      indSup = await firestore.getUser(placement!.industrySupervisorId!);
    }

    if (!mounted) return;
    setState(() {
      _totalEntries = entries.length;
      _pending = entries.where((e) => e.status == 'pending').length;
      _reviewed = entries.where((e) => e.status == 'reviewed').length;
      _flags = unresolvedFlags;
      _missedDays = _computeMissedDays(entries.map((e) => e.entryDate));
      _institutionSupervisor = instSup;
      _industrySupervisor = indSup;
      _loading = false;
    });
  }

  /// Full calendar days that have passed with no logbook entry at all,
  /// counting back from the most recent entry date to yesterday (today
  /// itself doesn't count as missed until it's over). Zero if the student
  /// has an entry for today or yesterday.
  static int _computeMissedDays(Iterable<String> entryDates) {
    final parsed = entryDates.map(DateTime.tryParse).whereType<DateTime>();
    if (parsed.isEmpty) return 0;
    final lastEntry = parsed.reduce((a, b) => a.isAfter(b) ? a : b);
    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final lastDateOnly = DateTime(lastEntry.year, lastEntry.month, lastEntry.day);
    final gap = todayDateOnly.difference(lastDateOnly).inDays;
    return gap > 1 ? gap - 1 : 0;
  }

  bool get _hasNoEntries => _totalEntries == 0;
  bool get _hasMissedDays => _missedDays > 0;

  MaterialColor get _statusColor {
    if (_hasNoEntries) return Colors.blueGrey;
    return (_flags > 0 || _hasMissedDays) ? Colors.red : Colors.green;
  }

  IconData get _statusIcon {
    if (_hasNoEntries) return Icons.info_outline;
    return (_flags > 0 || _hasMissedDays) ? Icons.warning_amber_outlined : Icons.check_circle_outline;
  }

  String get _statusTitle {
    if (_hasNoEntries) return 'No Entries Yet';
    if (_hasMissedDays) return 'Missed Entries';
    return _flags > 0 ? 'Action Required' : 'Good Standing';
  }

  String get _statusMessage {
    if (_hasNoEntries) {
      return "You haven't submitted any logbook entries yet. Add your first entry to get started.";
    }
    if (_hasMissedDays) {
      final dayWord = _missedDays == 1 ? 'day' : 'days';
      return "You've gone $_missedDays $dayWord without a logbook entry. Submit one as soon as possible to stay compliant.";
    }
    if (_flags > 0) {
      return 'You have $_flags active compliance flag(s). Please review your notifications or contact your supervisor.';
    }
    return 'Your logbook entries are up to date and compliant. Keep it up!';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final user = ref.watch(authServiceProvider).currentUser!;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Text('Welcome, ${user.name}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StatGrid(
            children: [
              StatCard(label: 'Total Entries', value: '$_totalEntries', icon: Icons.menu_book_outlined, color: Colors.teal),
              StatCard(label: 'Pending Review', value: '$_pending', icon: Icons.schedule, color: Colors.amber.shade700),
              StatCard(label: 'Reviewed', value: '$_reviewed', icon: Icons.check_circle_outline, color: Colors.green),
              StatCard(label: 'Active Flags', value: '$_flags', icon: Icons.warning_amber_outlined, color: Colors.red),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go(Routes.logbook),
            icon: const Icon(Icons.add),
            label: const Text('Add New Logbook Entry'),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_statusIcon, color: _statusColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_statusTitle, style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor)),
                      const SizedBox(height: 4),
                      Text(_statusMessage, style: TextStyle(color: _statusColor.shade900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('My Supervisors', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _SupervisorTile(label: 'Institution Supervisor', supervisor: _institutionSupervisor),
          const SizedBox(height: 12),
          _SupervisorTile(label: 'Industry Supervisor', supervisor: _industrySupervisor),
        ],
      ),
    );
  }
}

class _SupervisorTile extends StatelessWidget {
  final String label;
  final AppUser? supervisor;

  const _SupervisorTile({required this.label, required this.supervisor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 10),
          if (supervisor == null)
            const Text('Not assigned yet')
          else
            Row(
              children: [
                CircleAvatar(child: Text(supervisor!.name.isNotEmpty ? supervisor!.name[0].toUpperCase() : '?')),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(supervisor!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text(supervisor!.email, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
