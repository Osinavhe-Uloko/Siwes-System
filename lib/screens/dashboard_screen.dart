import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import 'dashboard/coordinator_dashboard.dart';
import 'dashboard/ind_supervisor_dashboard.dart';
import 'dashboard/inst_supervisor_dashboard.dart';
import 'dashboard/student_dashboard.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    if (user == null) return const SizedBox.shrink();

    switch (user.role) {
      case 'student':
        return const StudentDashboard();
      case 'coordinator':
        return const CoordinatorDashboard();
      case 'institution_supervisor':
        return const InstSupervisorDashboard();
      case 'industry_supervisor':
        return const IndSupervisorDashboard();
      default:
        return const Center(child: Text('Invalid role'));
    }
  }
}
