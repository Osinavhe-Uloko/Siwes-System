import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has completed the first-run onboarding flow, so
/// it's only ever shown once (before the first login) rather than every
/// time the app is opened signed-out.
class OnboardingService {
  static const _prefsKey = 'onboarding_complete';

  bool completed;

  OnboardingService._(this.completed);

  /// For widget tests, which don't need onboarding state persisted.
  OnboardingService.forTesting() : completed = true;

  static Future<OnboardingService> load() async {
    final prefs = await SharedPreferences.getInstance();
    return OnboardingService._(prefs.getBool(_prefsKey) ?? false);
  }

  Future<void> markComplete() async {
    completed = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  /// Called on sign-out: only the persisted flag is cleared, not this
  /// session's in-memory [completed] — so the current session still goes
  /// straight to the login screen, but the *next* cold start (e.g. after
  /// the app is closed from the app tray) shows onboarding again.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, false);
  }
}
