class SupervisorVisitLog {
  SupervisorVisitLog({
    required this.id,
    required this.institutionSupervisorId,
    required this.studentId,
    required this.visitDate,
    required this.mode,
    required this.notes,
  });

  final String id;
  final String institutionSupervisorId;
  final String studentId;
  final String visitDate;
  final String mode;
  final String notes;

  factory SupervisorVisitLog.fromFirestore(Map<String, dynamic> data, String id) {
    return SupervisorVisitLog(
      id: id,
      institutionSupervisorId: data['institution_supervisor_id']?.toString() ?? '',
      studentId: data['student_id']?.toString() ?? '',
      visitDate: data['visit_date']?.toString() ?? '',
      mode: data['mode']?.toString() ?? 'physical',
      notes: data['notes']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'institution_supervisor_id': institutionSupervisorId,
      'student_id': studentId,
      'visit_date': visitDate,
      'mode': mode,
      'notes': notes,
    };
  }
}
