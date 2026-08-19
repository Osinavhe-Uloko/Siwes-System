import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/compliance_flag.dart';
import '../providers.dart';
import '../widgets/page_header.dart';

class FlagsScreen extends ConsumerStatefulWidget {
  const FlagsScreen({super.key});

  @override
  ConsumerState<FlagsScreen> createState() => _FlagsScreenState();
}

class _FlagsScreenState extends ConsumerState<FlagsScreen> {
  bool _loading = true;
  List<ComplianceFlag> _flags = [];
  Map<String, String> _studentNames = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final firestore = ref.read(firestoreServiceProvider);
    final flags = await firestore.getFlags(unresolvedOnly: true);
    final students = await firestore.getUsersByIds(flags.map((f) => f.studentId).toList());

    if (!mounted) return;
    setState(() {
      _flags = flags;
      _studentNames = {for (final s in students) s.id: s.name};
      _loading = false;
    });
  }

  Future<void> _resolve(ComplianceFlag flag) async {
    final noteCtrl = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Flag'),
        content: TextField(
          controller: noteCtrl,
          decoration: const InputDecoration(labelText: 'Resolution note'),
          autofocus: true,
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, noteCtrl.text), child: const Text('Resolve')),
        ],
      ),
    );
    if (note == null) return;

    final user = ref.read(authServiceProvider).currentUser!;
    await ref.read(firestoreServiceProvider).resolveFlag(
          flag.id,
          user.id,
          note.isNotEmpty ? note : 'Resolved by ${user.name}',
        );
    await _load();
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
            icon: Icons.flag_rounded,
            title: 'Compliance Flags',
            subtitle: 'Unresolved flags requiring attention.',
          ),
          const SizedBox(height: 16),
          if (_flags.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                  SizedBox(height: 8),
                  Text('No active compliance flags. All good!'),
                ],
              ),
            )
          else
            ..._flags.map((flag) => _FlagTile(
                  flag: flag,
                  studentName: _studentNames[flag.studentId] ?? 'Unknown Student',
                  onResolve: () => _resolve(flag),
                )),
        ],
      ),
    );
  }
}

class _FlagTile extends StatelessWidget {
  final ComplianceFlag flag;
  final String studentName;
  final VoidCallback onResolve;

  const _FlagTile({required this.flag, required this.studentName, required this.onResolve});

  IconData get _icon {
    switch (flag.flagType) {
      case 'backdated_cluster':
        return Icons.warning_amber_outlined;
      case 'overdue_review':
        return Icons.hourglass_bottom;
      case 'inactive_supervisor':
        return Icons.person_off_outlined;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final detected = DateTime.fromMillisecondsSinceEpoch(flag.detectedAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(flag.flagType.replaceAll('_', ' ').toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text.rich(TextSpan(children: [
                  const TextSpan(text: 'Student: '),
                  TextSpan(text: studentName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ])),
                const SizedBox(height: 2),
                Text('Detected: ${DateFormat('MMM d, yyyy h:mm a').format(detected)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(onPressed: onResolve, child: const Text('Resolve')),
        ],
      ),
    );
  }
}
