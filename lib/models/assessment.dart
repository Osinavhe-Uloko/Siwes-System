class Assessment {
  Assessment({
    required this.id,
    required this.studentId,
    this.industryScore,
    this.institutionScore,
    this.finalGrade,
    this.comments,
  });

  final String id;
  final String studentId;
  final num? industryScore;
  final num? institutionScore;
  final String? finalGrade;
  final String? comments;

  factory Assessment.fromFirestore(Map<String, dynamic> data, String id) {
    return Assessment(
      id: id,
      studentId: data['student_id']?.toString() ?? '',
      industryScore: data['industry_score'],
      institutionScore: data['institution_score'],
      finalGrade: data['final_grade']?.toString(),
      comments: data['comments']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'student_id': studentId,
      'industry_score': industryScore,
      'institution_score': institutionScore,
      'final_grade': finalGrade,
      'comments': comments,
    };
  }
}
