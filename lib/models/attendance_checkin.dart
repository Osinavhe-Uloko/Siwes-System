/// A student's GPS check-in at their placement for a given calendar day.
/// One valid (within-range) check-in is required before that day's logbook
/// entry can be submitted.
class AttendanceCheckIn {
  AttendanceCheckIn({
    required this.id,
    required this.studentId,
    required this.placementId,
    required this.date,
    required this.checkedInAt,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.withinRange,
  });

  final String id;
  final String studentId;
  final String placementId;
  // yyyy-MM-dd, matches LogbookEntry.entryDate's format.
  final String date;
  final int checkedInAt;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool withinRange;

  factory AttendanceCheckIn.fromFirestore(Map<String, dynamic> data, String id) {
    return AttendanceCheckIn(
      id: id,
      studentId: data['student_id']?.toString() ?? '',
      placementId: data['placement_id']?.toString() ?? '',
      date: data['date']?.toString() ?? '',
      checkedInAt: data['checked_in_at'] is int ? data['checked_in_at'] as int : 0,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      distanceMeters: (data['distance_meters'] as num?)?.toDouble() ?? 0,
      withinRange: data['within_range'] == true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'placement_id': placementId,
      'date': date,
      'checked_in_at': checkedInAt,
      'latitude': latitude,
      'longitude': longitude,
      'distance_meters': distanceMeters,
      'within_range': withinRange,
    };
  }
}
