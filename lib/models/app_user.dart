class AppUser {
  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
    this.matricNumber,
    this.department,
    this.level,
    this.institutionSupervisorId,
    this.placementId,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final int createdAt;
  final String? matricNumber;
  final String? department;
  final String? level;
  final String? institutionSupervisorId;
  final String? placementId;

  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      id: id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      role: data['role']?.toString() ?? 'student',
      createdAt: data['created_at'] is int ? data['created_at'] as int : 0,
      matricNumber: data['matric_number']?.toString(),
      department: data['department']?.toString(),
      level: data['level']?.toString(),
      institutionSupervisorId: data['institution_supervisor_id']?.toString(),
      placementId: data['placement_id']?.toString(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'created_at': createdAt,
      'matric_number': matricNumber,
      'department': department,
      'level': level,
      'institution_supervisor_id': institutionSupervisorId,
      'placement_id': placementId,
    };
  }
}
