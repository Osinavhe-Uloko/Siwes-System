class Placement {
  Placement({
    required this.id,
    required this.studentId,
    required this.companyName,
    required this.companyAddress,
    required this.state,
    required this.industrySector,
    required this.startDate,
    required this.endDate,
    this.industrySupervisorId,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String studentId;
  final String companyName;
  final String companyAddress;
  final String state;
  final String industrySector;
  final String startDate;
  final String endDate;
  final String? industrySupervisorId;
  // Registered GPS location of the placement, used to verify a student
  // checked in on-site before submitting that day's logbook entry.
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;

  factory Placement.fromFirestore(Map<String, dynamic> data, String id) {
    return Placement(
      id: id,
      studentId: data['student_id']?.toString() ?? '',
      companyName: data['company_name']?.toString() ?? '',
      companyAddress: data['company_address']?.toString() ?? '',
      state: data['state']?.toString() ?? '',
      industrySector: data['industry_sector']?.toString() ?? '',
      startDate: data['start_date']?.toString() ?? '',
      endDate: data['end_date']?.toString() ?? '',
      industrySupervisorId: data['industry_supervisor_id']?.toString(),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'company_name': companyName,
      'company_address': companyAddress,
      'state': state,
      'industry_sector': industrySector,
      'start_date': startDate,
      'end_date': endDate,
      'industry_supervisor_id': industrySupervisorId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
