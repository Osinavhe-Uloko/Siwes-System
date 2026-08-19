import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'core/theme_provider.dart';
import 'providers.dart';
import 'services/auth_service.dart';
import 'services/onboarding_service.dart';

class SiwesApp extends ConsumerStatefulWidget {
  final OnboardingService onboarding;

  const SiwesApp({super.key, required this.onboarding});

  @override
  ConsumerState<SiwesApp> createState() => _SiwesAppState();
}

class _SiwesAppState extends ConsumerState<SiwesApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(ref.read(authServiceProvider), widget.onboarding);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    // Starts/stops the realtime notification listeners whenever the signed-in
    // user actually changes (login, logout, or switching accounts) — not on
    // every unrelated AuthService notification.
    ref.listen<AuthService>(authServiceProvider, (previous, next) {
      final user = next.currentUser;
      if (user?.id == previous?.currentUser?.id) return;
      final notifications = ref.read(notificationServiceProvider);
      if (user != null) {
        notifications.startListening(user);
        notifications.registerToken(user, ref.read(firestoreServiceProvider));
      } else {
        notifications.stopListening();
      }
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SIWES Monitor',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      routeInformationProvider: _router.routeInformationProvider,
    );
  }
}
