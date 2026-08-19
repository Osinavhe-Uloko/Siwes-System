import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'services/auth_service.dart';
import 'services/compliance_service.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/onboarding_service.dart';

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  return AuthService();
});

/// Overridden in main() with the instance loaded (and already threaded into
/// the router) at startup — see [OnboardingService.load].
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  throw UnimplementedError('onboardingServiceProvider must be overridden in main()');
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

final complianceServiceProvider = Provider<ComplianceService>((ref) {
  return ComplianceService(ref.watch(firestoreServiceProvider));
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService();
  ref.onDispose(service.dispose);
  return service;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});
