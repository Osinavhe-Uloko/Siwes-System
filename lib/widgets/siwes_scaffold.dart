import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../routes.dart';
import 'siwes_bottom_nav.dart';

class SiwesScaffold extends StatelessWidget {
  final Widget body;
  final Widget? floatingActionButton;

  const SiwesScaffold({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No title here — each screen owns its own PageHeader in the body, so
      // this stays a slim, blended utility strip instead of repeating the
      // page name a second time.
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        actions: [
          _AppBarAction(
            icon: Icons.notifications_outlined,
            tooltip: 'Notifications',
            onTap: () => context.go(Routes.notifications),
          ),
          const SizedBox(width: 8),
          _AppBarAction(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: () => context.go(Routes.settings),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: body,
        ),
      ),
      bottomNavigationBar: const SiwesBottomNav(),
      floatingActionButton: floatingActionButton,
    );
  }
}

/// A soft, pill-shaped icon button matching the bottom nav's rounded
/// aesthetic, used for the AppBar's utility actions (notifications, settings)
/// instead of bare Material IconButtons.
class _AppBarAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarAction({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}
