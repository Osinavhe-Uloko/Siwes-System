class Routes {
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const logbook = '/dashboard/logbook';
  static const placement = '/dashboard/placement';
  static const students = '/dashboard/students';
  static String studentProfile(String id) => '/dashboard/students/$id';
  static const studentProfilePattern = '/dashboard/students/:id';
  static const supervisors = '/dashboard/supervisors';
  static const flags = '/dashboard/flags';
  static const notifications = '/dashboard/notifications';
  static const settings = '/dashboard/settings';
}
