import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/app_user.dart';
import '../providers.dart';
import '../routes.dart';
import '../widgets/page_header.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  bool _loading = true;
  List<AppUser> _students = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final students = await ref.read(firestoreServiceProvider).getStudents();
    if (!mounted) return;
    setState(() {
      _students = students;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _students.where((s) {
      final q = _search.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.email.toLowerCase().contains(q) ||
          (s.matricNumber?.toLowerCase().contains(q) ?? false);
    }).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(
            icon: Icons.school_rounded,
            title: 'Students',
            subtitle: 'Monitor and manage students on industrial attachment.',
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search students...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No students found matching your search.')),
            )
          else
            ...filtered.map((student) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(student.name.isNotEmpty ? student.name[0].toUpperCase() : '?')),
                    title: Text(student.name),
                    subtitle: Text(
                        '${student.matricNumber ?? 'N/A'} • ${student.department ?? 'N/A'} • ${student.level ?? 'N/A'}L'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(Routes.studentProfile(student.id)),
                  ),
                )),
        ],
      ),
    );
  }
}
