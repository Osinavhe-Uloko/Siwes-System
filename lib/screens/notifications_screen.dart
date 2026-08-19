import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/compliance_flag.dart';
import '../models/logbook_entry.dart';
import '../models/placement.dart';
import '../providers.dart';
import '../routes.dart';
import '../widgets/page_header.dart';

class _NotificationItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final int timestamp;
  final VoidCallback? onTap;

  const _NotificationItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.onTap,
  });
}

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _loading = true;
  List<_NotificationItem> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authServiceProvider).currentUser!;
    final firestore = ref.read(firestoreServiceProvider);
    final items = <_NotificationItem>[];

    if (user.role == 'student') {
      final results = await (
        firestore.getEntriesForStudent(user.id),
        firestore.getFlagsForStudent(user.id),
      ).wait;
      for (final e in results.$1.where((e) => e.status != 'pending')) {
        items.add(_reviewedEntryItem(e));
      }
      for (final f in results.$2.where((f) => !f.resolved)) {
        items.add(_flagItem(f, null));
      }
    } else {
      // Institution supervisors currently oversee all students (there's no
      // per-supervisor assignment feature yet), so no extra filtering there.
      final isIndustrySupervisor = user.role == 'industry_supervisor';
      final results = await (
        firestore.getFlags(unresolvedOnly: true),
        isIndustrySupervisor ? firestore.getPlacementsForSupervisor(user.id) : Future<List<Placement>>.value(const []),
      ).wait;
      List<ComplianceFlag> flags = results.$1;
      if (isIndustrySupervisor) {
        final ids = results.$2.map((p) => p.studentId).toSet();
        flags = flags.where((f) => ids.contains(f.studentId)).toList();
      }
      final students = await firestore.getUsersByIds(flags.map((f) => f.studentId).toList());
      final namesById = {for (final s in students) s.id: s.name};
      for (final f in flags) {
        items.add(_flagItem(f, namesById[f.studentId]));
      }
    }

    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  _NotificationItem _flagItem(ComplianceFlag flag, String? studentName) {
    return _NotificationItem(
      icon: Icons.warning_amber_outlined,
      color: Colors.red,
      title: flag.flagType.replaceAll('_', ' ').toUpperCase(),
      subtitle: studentName != null ? 'Student: $studentName' : 'New compliance flag detected',
      timestamp: flag.detectedAt,
      onTap: () => context.go(Routes.flags),
    );
  }

  _NotificationItem _reviewedEntryItem(LogbookEntry entry) {
    final isFlagged = entry.status == 'flagged';
    return _NotificationItem(
      icon: isFlagged ? Icons.warning_amber_outlined : Icons.check_circle_outline,
      color: isFlagged ? Colors.red : Colors.green,
      title: isFlagged ? 'Entry flagged for changes' : 'Logbook entry reviewed',
      subtitle: 'Week ${entry.weekNumber} • ${entry.entryDate}',
      timestamp: entry.submittedAt,
      onTap: () => context.go(Routes.logbook),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: 'Recent updates on your logbook and compliance.',
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.notifications_none, size: 48),
                  SizedBox(height: 8),
                  Text("You're all caught up."),
                ],
              ),
            )
          else
            ..._items.map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(item.icon, color: item.color),
                    title: Text(item.title),
                    subtitle: Text(
                        '${item.subtitle}\n${DateFormat('MMM d, yyyy h:mm a').format(DateTime.fromMillisecondsSinceEpoch(item.timestamp))}'),
                    isThreeLine: true,
                    onTap: item.onTap,
                  ),
                )),
        ],
      ),
    );
  }
}
