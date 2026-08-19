class LogbookEntry {
  LogbookEntry({
    required this.id,
    required this.studentId,
    required this.entryDate,
    required this.submittedAt,
    required this.content,
    required this.weekNumber,
    required this.status,
    this.supervisorComment,
    this.grade,
  });

  final String id;
  final String studentId;
  final String entryDate;
  final int submittedAt;
  final String content;
  final int weekNumber;
  final String status;
  final String? supervisorComment;
  final String? grade;

  factory LogbookEntry.fromFirestore(Map<String, dynamic> data, String id) {
    return LogbookEntry(
      id: id,
      studentId: data['student_id']?.toString() ?? '',
      entryDate: data['entry_date']?.toString() ?? '',
      submittedAt: data['submitted_at'] is int ? data['submitted_at'] as int : 0,
      content: data['content']?.toString() ?? '',
      weekNumber: data['week_number'] is int ? data['week_number'] as int : 0,
      status: data['status']?.toString() ?? 'pending',
      supervisorComment: data['supervisor_comment']?.toString(),
      grade: data['grade']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'entry_date': entryDate,
      'submitted_at': submittedAt,
      'content': content,
      'week_number': weekNumber,
      'status': status,
      'supervisor_comment': supervisorComment,
      'grade': grade,
    };
  }
}
