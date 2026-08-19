import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

/// Restricts [child] to signed-in users whose role is in [allowedRoles].
/// Mirrors the web app's `ProtectedRoute allowedRoles=[...]`.
class RoleGuard extends ConsumerWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuard({super.key, required this.allowedRoles, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authServiceProvider);
    final role = auth.currentUser?.role;
    if (role == null || !allowedRoles.contains(role)) {
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              "You don't have permission to view this page.",
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return child;
  }
}
