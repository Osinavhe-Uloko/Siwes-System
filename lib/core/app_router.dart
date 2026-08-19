import 'package:go_router/go_router.dart';

import '../routes.dart';
import '../screens/dashboard_screen.dart';
import '../screens/flags_screen.dart';
import '../screens/logbook_screen.dart';
import '../screens/login_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/placement_screen.dart';
import '../screens/register_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/student_profile_screen.dart';
import '../screens/students_screen.dart';
import '../screens/supervisors_screen.dart';
import '../services/auth_service.dart';
import '../services/onboarding_service.dart';
import '../widgets/role_guard.dart';
import '../widgets/siwes_scaffold.dart';

GoRouter createAppRouter(AuthService authService, OnboardingService onboarding) {
  return GoRouter(
    initialLocation: onboarding.completed ? Routes.login : Routes.onboarding,
    refreshListenable: authService,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final bool signedIn = authService.currentUser != null;
      final loc = state.uri.toString();
      final bool onAuthPage = loc == Routes.login || loc == Routes.register;
      final bool onOnboarding = loc == Routes.onboarding;

      if (signedIn) {
        if (onAuthPage || onOnboarding) return Routes.dashboard;
        return null;
      }

      if (!onboarding.completed) {
        return onOnboarding ? null : Routes.onboarding;
      }
      if (onOnboarding) return Routes.login;
      if (!onAuthPage) return Routes.login;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        name: Routes.onboarding,
        path: Routes.onboarding,
        builder: (context, state) => OnboardingScreen(onComplete: onboarding.markComplete),
      ),
      GoRoute(
        name: Routes.login,
        path: Routes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: Routes.register,
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return SiwesScaffold(body: child);
        },
        routes: <RouteBase>[
          GoRoute(
            name: Routes.dashboard,
            path: Routes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            name: Routes.logbook,
            path: Routes.logbook,
            builder: (context, state) => const RoleGuard(
              allowedRoles: ['student'],
              child: LogbookScreen(),
            ),
          ),
          GoRoute(
            name: Routes.placement,
            path: Routes.placement,
            builder: (context, state) => const RoleGuard(
              allowedRoles: ['student', 'industry_supervisor'],
              child: PlacementScreen(),
            ),
          ),
          GoRoute(
            name: Routes.supervisors,
            path: Routes.supervisors,
            builder: (context, state) => const RoleGuard(
              allowedRoles: ['coordinator'],
              child: SupervisorsScreen(),
            ),
          ),
          GoRoute(
            name: Routes.students,
            path: Routes.students,
            builder: (context, state) => const RoleGuard(
              allowedRoles: ['coordinator', 'institution_supervisor', 'industry_supervisor'],
              child: StudentsScreen(),
            ),
          ),
          GoRoute(
            path: Routes.studentProfilePattern,
            builder: (context, state) => RoleGuard(
              allowedRoles: const ['coordinator', 'institution_supervisor', 'industry_supervisor'],
              child: StudentProfileScreen(studentId: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            name: Routes.flags,
            path: Routes.flags,
            builder: (context, state) => const RoleGuard(
              allowedRoles: ['coordinator', 'institution_supervisor'],
              child: FlagsScreen(),
            ),
          ),
          GoRoute(
            name: Routes.notifications,
            path: Routes.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            name: Routes.settings,
            path: Routes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
