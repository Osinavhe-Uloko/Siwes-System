import 'package:geolocator/geolocator.dart';

/// The registered placement location is only considered a match if the
/// device is within this many meters of it — loose enough to absorb typical
/// consumer-GPS drift, tight enough to rule out "checked in from home."
const kCheckInRadiusMeters = 200.0;

class LocationService {
  /// Resolves the device's current GPS position, walking through the
  /// service-enabled/permission checks geolocator requires first. Throws a
  /// plain [Exception] with a message safe to show directly to the user.
  Future<Position> getCurrentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services are turned off. Enable GPS and try again.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission was denied. Grant it to check in.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission is permanently denied. Enable it from app settings to check in.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  double distanceMeters({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }
}
