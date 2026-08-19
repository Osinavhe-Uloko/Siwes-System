import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/compliance_flag.dart';
import '../../providers.dart';
import '../../routes.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/stat_grid.dart';

const _flagColors = [Colors.red, Colors.amber, Colors.blue, Colors.teal, Colors.purple];

class CoordinatorDashboard extends ConsumerStatefulWidget {
  const CoordinatorDashboard({super.key});

  @override
  ConsumerState<CoordinatorDashboard> createState() => _CoordinatorDashboardState();
}

class _CoordinatorDashboardState extends ConsumerState<CoordinatorDashboard> {
  bool _loading = true;
  bool _detecting = false;
  int _totalStudents = 0;
  int _flaggedStudents = 0;
  int _activeFlags = 0;
  Map<String, int> _flagsByType = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Renders from the two stat queries only — fast, so the dashboard
  /// paints immediately instead of waiting on a full compliance scan.
  Future<void> _load() async {
    final firestore = ref.read(firestoreServiceProvider);

    final results = await (
      firestore.getStudents(),
      firestore.getFlags(unresolvedOnly: true),
    ).wait;
    final students = results.$1;
    final flags = results.$2;

    _applyStats(students.length, flags);
    if (_loading) setState(() => _loading = false);

    // The compliance scan (which can create new flags) runs quietly after
    // the first paint rather than blocking it; if it finds anything new,
    // the stats are refreshed a second time without another spinner.
    unawaited(_runDetectionThenRefresh());
  }

  Future<void> _runDetectionThenRefresh() async {
    if (_detecting) return;
    _detecting = true;
    try {
      await ref.read(complianceServiceProvider).runCoordinatorDetection();
      if (!mounted) return;
      final firestore = ref.read(firestoreServiceProvider);
      final results = await (
        firestore.getStudents(),
        firestore.getFlags(unresolvedOnly: true),
      ).wait;
      _applyStats(results.$1.length, results.$2);
    } catch (e) {
      // Best-effort background scan — a transient failure here shouldn't
      // disrupt the dashboard the user is already looking at.
      debugPrint('Compliance detection failed: $e');
    } finally {
      _detecting = false;
    }
  }

  void _applyStats(int totalStudents, List<ComplianceFlag> flags) {
    final flaggedStudentIds = <String>{};
    final byType = <String, int>{};
    for (final flag in flags) {
      flaggedStudentIds.add(flag.studentId);
      byType[flag.flagType] = (byType[flag.flagType] ?? 0) + 1;
    }

    if (!mounted) return;
    setState(() {
      _totalStudents = totalStudents;
      _flaggedStudents = flaggedStudentIds.length;
      _activeFlags = flags.length;
      _flagsByType = byType;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final compliant = _totalStudents - _flaggedStudents;
    final flagEntries = _flagsByType.entries.toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Text('Monitoring Dashboard', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StatGrid(
            children: [
              StatCard(label: 'Total Students', value: '$_totalStudents', icon: Icons.people_outline, color: Colors.teal),
              StatCard(label: 'Compliant', value: '$compliant', icon: Icons.shield_outlined, color: Colors.green),
              StatCard(label: 'Flagged Students', value: '$_flaggedStudents', icon: Icons.warning_amber_outlined, color: Colors.red),
              StatCard(label: 'Active Flags', value: '$_activeFlags', icon: Icons.flag_outlined, color: Colors.amber.shade700),
            ],
          ),
          const SizedBox(height: 24),
          Text('Active Flags by Type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (flagEntries.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('No active flags. All clear!'),
            )
          else ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    for (var i = 0; i < flagEntries.length; i++)
                      PieChartSectionData(
                        value: flagEntries[i].value.toDouble(),
                        color: _flagColors[i % _flagColors.length],
                        title: '${flagEntries[i].value}',
                        radius: 60,
                      ),
                  ],
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < flagEntries.length; i++)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, color: _flagColors[i % _flagColors.length]),
                      const SizedBox(width: 6),
                      Text('${flagEntries[i].key.replaceAll('_', ' ')} (${flagEntries[i].value})'),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.go(Routes.flags),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('View All Flags'),
          ),
        ],
      ),
    );
  }
}
