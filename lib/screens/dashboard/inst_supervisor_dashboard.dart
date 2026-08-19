import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/app_user.dart';
import '../../models/logbook_entry.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/stat_grid.dart';

class _StudentActivity {
  final AppUser student;
  final LogbookEntry? latestEntry;

  const _StudentActivity(this.student, this.latestEntry);
}

class InstSupervisorDashboard extends ConsumerStatefulWidget {
  const InstSupervisorDashboard({super.key});

  @override
  ConsumerState<InstSupervisorDashboard> createState() => _InstSupervisorDashboardState();
}

class _InstSupervisorDashboardState extends ConsumerState<InstSupervisorDashboard> {
  bool _loading = true;
  List<_StudentActivity> _activity = [];
  int _flagCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final firestore = ref.read(firestoreServiceProvider);

    // Institution supervisors currently oversee all students — there's no
    // feature yet to assign specific students to a specific institution
    // supervisor, so filtering by that field silently hid students who
    // were never assigned.
    final results = await (
      firestore.getStudents(),
      firestore.getFlags(unresolvedOnly: true),
    ).wait;
    final students = results.$1;
    final count = results.$2.length;

    final activity = await Future.wait(students.map((student) async {
      final recent = await firestore.getRecentEntriesForStudent(student.id, 1);
      return _StudentActivity(student, recent.isEmpty ? null : recent.first);
    }));

    // Students who submitted most recently surface first, so a supervisor
    // can see at a glance who's actively logging; students with no entries
    // at all sort to the bottom.
    activity.sort((a, b) {
      final aTime = a.latestEntry?.submittedAt;
      final bTime = b.latestEntry?.submittedAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    if (!mounted) return;
    setState(() {
      _activity = activity;
      _flagCount = count;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Text('Institution Supervisor Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StatGrid(
            children: [
              StatCard(label: 'Total Students', value: '${_activity.length}', icon: Icons.people_outline, color: Colors.teal),
              StatCard(label: 'Flags to Review', value: '$_flagCount', icon: Icons.warning_amber_outlined, color: Colors.red),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Students', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () => context.go(Routes.students), child: const Text('View All')),
            ],
          ),
          if (_activity.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No students found.')),
            )
          else
            ..._activity.take(5).map((a) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(a.student.name),
                    subtitle: Text(_activitySubtitle(a)),
                    trailing: TextButton(
                      onPressed: () => context.go(Routes.studentProfile(a.student.id)),
                      child: const Text('View Logbook'),
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  String _activitySubtitle(_StudentActivity a) {
    final matric = a.student.matricNumber ?? 'N/A';
    final entry = a.latestEntry;
    if (entry == null) return '$matric • No entries yet';
    final submitted = DateTime.fromMillisecondsSinceEpoch(entry.submittedAt);
    return '$matric • Last entry ${DateFormat('MMM d, yyyy').format(submitted)}';
  }
}
