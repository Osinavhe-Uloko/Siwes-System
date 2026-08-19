class ComplianceFlag {
  ComplianceFlag({
    required this.id,
    required this.studentId,
    required this.flagType,
    required this.detectedAt,
    required this.resolved,
    this.logbookEntryId,
    this.resolvedBy,
    this.resolutionNote,
  });

  final String id;
  final String studentId;
  final String? logbookEntryId;
  final String flagType;
  final int detectedAt;
  final bool resolved;
  final String? resolvedBy;
  final String? resolutionNote;

  factory ComplianceFlag.fromFirestore(Map<String, dynamic> data, String id) {
    return ComplianceFlag(
      id: id,
      studentId: data['student_id']?.toString() ?? '',
      logbookEntryId: data['logbook_entry_id']?.toString(),
      flagType: data['flag_type']?.toString() ?? '',
      detectedAt: data['detected_at'] is int ? data['detected_at'] as int : 0,
      resolved: data['resolved'] is bool ? data['resolved'] as bool : false,
      resolvedBy: data['resolved_by']?.toString(),
      resolutionNote: data['resolution_note']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'logbook_entry_id': logbookEntryId,
      'flag_type': flagType,
      'detected_at': detectedAt,
      'resolved': resolved,
      'resolved_by': resolvedBy,
      'resolution_note': resolutionNote,
    };
  }
}
