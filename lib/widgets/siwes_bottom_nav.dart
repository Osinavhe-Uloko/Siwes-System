import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../routes.dart';

class _TabItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _TabItem(this.route, this.label, this.icon, this.activeIcon);
}

/// Primary content sections per role, kept to 3-4 entries so the bar never
/// feels cramped. Notifications and Settings live in the app bar instead
/// (they're utility actions, not primary navigation destinations).
final Map<String, List<_TabItem>> _tabsForRole = {
  'student': const [
    _TabItem(Routes.dashboard, 'Home', Icons.dashboard_outlined, Icons.dashboard_rounded),
    _TabItem(Routes.logbook, 'Logbook', Icons.menu_book_outlined, Icons.menu_book_rounded),
    _TabItem(Routes.placement, 'Placement', Icons.business_center_outlined, Icons.business_center_rounded),
  ],
  'institution_supervisor': const [
    _TabItem(Routes.dashboard, 'Home', Icons.dashboard_outlined, Icons.dashboard_rounded),
    _TabItem(Routes.students, 'Students', Icons.school_outlined, Icons.school_rounded),
    _TabItem(Routes.flags, 'Flags', Icons.flag_outlined, Icons.flag_rounded),
  ],
  'industry_supervisor': const [
    _TabItem(Routes.dashboard, 'Home', Icons.dashboard_outlined, Icons.dashboard_rounded),
    _TabItem(Routes.placement, 'Placement', Icons.business_center_outlined, Icons.business_center_rounded),
    _TabItem(Routes.students, 'Students', Icons.school_outlined, Icons.school_rounded),
  ],
  'coordinator': const [
    _TabItem(Routes.dashboard, 'Home', Icons.dashboard_outlined, Icons.dashboard_rounded),
    _TabItem(Routes.students, 'Students', Icons.school_outlined, Icons.school_rounded),
    _TabItem(Routes.supervisors, 'Supervisors', Icons.people_outline, Icons.people_rounded),
    _TabItem(Routes.flags, 'Flags', Icons.flag_outlined, Icons.flag_rounded),
  ],
};

class SiwesBottomNav extends ConsumerWidget {
  const SiwesBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(authServiceProvider).currentUser?.role;
    final tabs = _tabsForRole[role] ?? const [];
    if (tabs.isEmpty) return const SizedBox.shrink();

    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = tabs.indexWhere(
      (t) => location == t.route || (t.route != Routes.dashboard && location.startsWith(t.route)),
    );

    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++)
              Expanded(
                child: _NavItem(
                  tab: tabs[i],
                  selected: i == selectedIndex,
                  onTap: () => context.go(tabs[i].route),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final _TabItem tab;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({required this.tab, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: selected ? colorScheme.primary.withValues(alpha: 0.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  selected ? tab.activeIcon : tab.icon,
                  size: 22,
                  color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              // The label sits below the icon so it gets the tab's full
              // slot width instead of sharing it with the icon. FittedBox
              // scales the font down on the rare narrow slot (e.g. 4 tabs
              // on a small phone) instead of truncating or overflowing —
              // the full word always shows.
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  tab.label,
                  style: TextStyle(
                    color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
