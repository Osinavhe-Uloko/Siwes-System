import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/placement.dart';
import '../providers.dart';
import '../widgets/page_header.dart';

class PlacementScreen extends ConsumerStatefulWidget {
  const PlacementScreen({super.key});

  @override
  ConsumerState<PlacementScreen> createState() => _PlacementScreenState();
}

class _PlacementScreenState extends ConsumerState<PlacementScreen> {
  bool _loading = true;
  Placement? _studentPlacement;
  AppUser? _industrySupervisor;
  List<Placement> _supervisedPlacements = [];
  Map<String, AppUser> _studentsById = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = ref.read(authServiceProvider).currentUser!;
    final firestore = ref.read(firestoreServiceProvider);

    if (user.role == 'student') {
      final placement = await firestore.getPlacementForStudent(user.id);
      AppUser? supervisor;
      if (placement?.industrySupervisorId != null) {
        supervisor = await firestore.getUser(placement!.industrySupervisorId!);
      }
      if (!mounted) return;
      setState(() {
        _studentPlacement = placement;
        _industrySupervisor = supervisor;
        _loading = false;
      });
    } else {
      final placements = await firestore.getPlacementsForSupervisor(user.id);
      final students = await firestore.getUsersByIds(placements.map((p) => p.studentId).toList());
      if (!mounted) return;
      setState(() {
        _supervisedPlacements = placements;
        _studentsById = {for (final s in students) s.id: s};
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final user = ref.watch(authServiceProvider).currentUser!;

    if (user.role == 'student') {
      return RefreshIndicator(onRefresh: _load, child: _StudentPlacementView(placement: _studentPlacement, supervisor: _industrySupervisor));
    }
    return RefreshIndicator(onRefresh: _load, child: _SupervisorPlacementsView(placements: _supervisedPlacements, studentsById: _studentsById));
  }
}

class _StudentPlacementView extends StatelessWidget {
  final Placement? placement;
  final AppUser? supervisor;

  const _StudentPlacementView({required this.placement, required this.supervisor});

  @override
  Widget build(BuildContext context) {
    if (placement == null) {
      return ListView(
        children: [
          const SizedBox(height: 48),
          Column(
            children: [
              Icon(Icons.business_center_outlined, size: 48, color: Theme.of(context).colorScheme.outline),
              const SizedBox(height: 12),
              const Text('No placement recorded yet.', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Your coordinator will assign your industrial attachment placement.'),
            ],
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(
          icon: Icons.business_center_rounded,
          title: 'Placement Details',
          subtitle: 'Information regarding your current industrial attachment.',
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.apartment, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(placement!.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(placement!.industrySector, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _InfoRow(icon: Icons.location_on_outlined, label: 'Location', value: '${placement!.companyAddress}, ${placement!.state}'),
              const SizedBox(height: 12),
              _InfoRow(icon: Icons.calendar_today_outlined, label: 'Duration', value: '${placement!.startDate} – ${placement!.endDate}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Industry Supervisor', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
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
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _SupervisorPlacementsView extends StatelessWidget {
  final List<Placement> placements;
  final Map<String, AppUser> studentsById;

  const _SupervisorPlacementsView({required this.placements, required this.studentsById});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(
          icon: Icons.business_center_rounded,
          title: 'Placements',
          subtitle: 'Students you are supervising on industrial attachment.',
        ),
        const SizedBox(height: 20),
        if (placements.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: Text('No students currently assigned to you.')),
          )
        else
          ...placements.map((p) {
            final student = studentsById[p.studentId];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student?.name ?? 'Student ${p.studentId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${p.companyName} • ${p.industrySector}', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text('${p.startDate} – ${p.endDate}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            );
          }),
      ],
    );
  }
}
