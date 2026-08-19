import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../providers.dart';
import '../widgets/page_header.dart';

class SupervisorsScreen extends ConsumerStatefulWidget {
  const SupervisorsScreen({super.key});

  @override
  ConsumerState<SupervisorsScreen> createState() => _SupervisorsScreenState();
}

class _SupervisorsScreenState extends ConsumerState<SupervisorsScreen> {
  bool _loading = true;
  List<AppUser> _supervisors = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final supervisors = await ref.read(firestoreServiceProvider).getSupervisors();
    if (!mounted) return;
    setState(() {
      _supervisors = supervisors;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final filtered = _supervisors.where((s) {
      final q = _search.toLowerCase();
      return s.name.toLowerCase().contains(q) || s.email.toLowerCase().contains(q);
    }).toList();

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(
            icon: Icons.people_rounded,
            title: 'Supervisors',
            subtitle: 'Manage industry and institutional supervisors.',
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(hintText: 'Search supervisors...', prefixIcon: Icon(Icons.search)),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: Text('No supervisors found matching your search.')),
            )
          else
            ...filtered.map((supervisor) {
              final isInstitution = supervisor.role == 'institution_supervisor';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(supervisor.name.isNotEmpty ? supervisor.name[0].toUpperCase() : '?'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(supervisor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(supervisor.email, style: Theme.of(context).textTheme.bodySmall),
                          Text(supervisor.phone, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: (isInstitution ? Colors.blue : Colors.indigo).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isInstitution ? 'Institution' : 'Industry',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isInstitution ? Colors.blue.shade800 : Colors.indigo.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
