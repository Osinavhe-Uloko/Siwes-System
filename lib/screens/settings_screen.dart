import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme_provider.dart';
import '../providers.dart';
import '../routes.dart';
import '../widgets/page_header.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    final themeMode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(
          icon: Icons.settings_rounded,
          title: 'Settings',
          subtitle: 'Manage your account and app preferences.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                child: Text(user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(user?.email ?? '', style: Theme.of(context).textTheme.bodySmall),
                    Text(user?.role.replaceAll('_', ' ') ?? '', style: Theme.of(context).textTheme.bodySmall),
                    if (user?.matricNumber != null) ...[
                      const SizedBox(height: 4),
                      Text('Matric: ${user!.matricNumber}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text('Appearance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System default'),
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light'),
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark'),
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            ref.read(authServiceProvider).signOut();
            ref.read(onboardingServiceProvider).reset();
            context.go(Routes.login);
          },
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
        ),
      ],
    );
  }
}
