import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/app_user.dart';
import '../../models/placement.dart';
import '../../providers.dart';
import '../../routes.dart';

class IndSupervisorDashboard extends ConsumerStatefulWidget {
  const IndSupervisorDashboard({super.key});

  @override
  ConsumerState<IndSupervisorDashboard> createState() => _IndSupervisorDashboardState();
}

class _IndSupervisorDashboardState extends ConsumerState<IndSupervisorDashboard> {
  bool _loading = true;
  List<Placement> _placements = [];
  Map<String, AppUser> _studentsById = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authServiceProvider).currentUser!;
    final firestore = ref.read(firestoreServiceProvider);

    final placements = await firestore.getPlacementsForSupervisor(user.id);
    final students = await firestore.getUsersByIds(placements.map((p) => p.studentId).toList());

    if (!mounted) return;
    setState(() {
      _placements = placements;
      _studentsById = {for (final s in students) s.id: s};
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
          Text('Industry Supervisor Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text('Students on Placement', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_placements.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No students currently assigned to you.')),
            )
          else
            ..._placements.map((placement) {
              final student = _studentsById[placement.studentId];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(student?.name ?? 'Student ${placement.studentId}'),
                  subtitle: Text('Started: ${placement.startDate}'),
                  trailing: student == null
                      ? null
                      : TextButton(
                          onPressed: () => context.go(Routes.studentProfile(student.id)),
                          child: const Text('View'),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
