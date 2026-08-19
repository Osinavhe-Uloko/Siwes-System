import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/firestore_db.dart';
import '../models/assessment.dart';
import '../models/attendance_checkin.dart';
import '../models/compliance_flag.dart';
import '../models/logbook_entry.dart';
import '../models/placement.dart';
import '../models/app_user.dart';
import '../models/supervisor_visit_log.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = siwesFirestore;

  CollectionReference<Map<String, dynamic>> get _usersRef => _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _placementsRef => _firestore.collection('placements');
  CollectionReference<Map<String, dynamic>> get _logbookEntriesRef => _firestore.collection('logbook_entries');
  CollectionReference<Map<String, dynamic>> get _flagsRef => _firestore.collection('compliance_flags');
  CollectionReference<Map<String, dynamic>> get _visitLogsRef => _firestore.collection('supervisor_visit_logs');
  CollectionReference<Map<String, dynamic>> get _assessmentsRef => _firestore.collection('assessments');
  CollectionReference<Map<String, dynamic>> get _checkInsRef => _firestore.collection('attendance_checkins');

  Future<AppUser?> getUser(String id) async {
    final snapshot = await _usersRef.doc(id).get();
    if (!snapshot.exists) return null;
    return AppUser.fromFirestore(snapshot.data()!, snapshot.id);
  }

  Future<void> setUser(AppUser user) async {
    await _usersRef.doc(user.id).set(user.toFirestore());
  }

  Future<List<AppUser>> getStudents() async {
    final snapshot = await _usersRef.where('role', isEqualTo: 'student').get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<AppUser>> getSupervisors() async {
    final snapshot = await _usersRef.where('role', whereIn: ['institution_supervisor', 'industry_supervisor']).get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<AppUser>> getUsersByRole(String role) async {
    final snapshot = await _usersRef.where('role', isEqualTo: role).get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc.data(), doc.id)).toList();
  }

  /// Assigns (or reassigns) a student's institution supervisor.
  Future<void> assignInstitutionSupervisor(String studentId, String supervisorId) async {
    await _usersRef.doc(studentId).update({'institution_supervisor_id': supervisorId});
  }

  /// Stores this device's FCM token on the user's profile so a future
  /// server-side sender (e.g. Cloud Functions, once on a Blaze plan) can
  /// target it for real push notifications.
  Future<void> updateFcmToken(String userId, String token) async {
    await _usersRef.doc(userId).update({'fcm_token': token});
  }

  Future<List<LogbookEntry>> getEntriesForStudent(String studentId) async {
    final snapshot = await _logbookEntriesRef.where('student_id', isEqualTo: studentId).orderBy('entry_date', descending: true).get();
    return snapshot.docs.map((doc) => LogbookEntry.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<LogbookEntry>> getRecentEntriesForStudent(String studentId, int limit) async {
    final snapshot = await _logbookEntriesRef.where('student_id', isEqualTo: studentId).orderBy('submitted_at', descending: true).limit(limit).get();
    return snapshot.docs.map((doc) => LogbookEntry.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<ComplianceFlag>> getFlags({bool unresolvedOnly = false}) async {
    Query<Map<String, dynamic>> query = _flagsRef;
    if (unresolvedOnly) {
      query = query.where('resolved', isEqualTo: false);
    }
    final snapshot = await query.orderBy('detected_at', descending: true).get();
    return snapshot.docs.map((doc) => ComplianceFlag.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<List<ComplianceFlag>> getFlagsForStudent(String studentId) async {
    final snapshot = await _flagsRef.where('student_id', isEqualTo: studentId).orderBy('detected_at', descending: true).get();
    return snapshot.docs.map((doc) => ComplianceFlag.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> addFlag(ComplianceFlag flag) async {
    await _flagsRef.doc(flag.id).set(flag.toFirestore());
  }

  Future<void> resolveFlag(String id, String resolvedBy, String note) async {
    await _flagsRef.doc(id).update({
      'resolved': true,
      'resolved_by': resolvedBy,
      'resolution_note': note,
    });
  }

  Future<Placement?> getPlacementForStudent(String studentId) async {
    final snapshot = await _placementsRef.where('student_id', isEqualTo: studentId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return Placement.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Future<List<Placement>> getPlacementsForSupervisor(String supervisorId) async {
    final snapshot = await _placementsRef.where('industry_supervisor_id', isEqualTo: supervisorId).get();
    return snapshot.docs.map((doc) => Placement.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> setPlacement(Placement placement) async {
    await _placementsRef.doc(placement.id).set(placement.toFirestore());
  }

  Future<void> addEntry(LogbookEntry entry) async {
    await _logbookEntriesRef.doc(entry.id).set(entry.toFirestore());
  }

  Future<void> updateEntry(String id, Map<String, Object?> updates) async {
    await _logbookEntriesRef.doc(id).update(updates);
  }

  Future<void> addVisitLog(SupervisorVisitLog log) async {
    await _visitLogsRef.doc(log.id).set(log.toFirestore());
  }

  Future<List<SupervisorVisitLog>> getVisitLogsForStudent(String studentId) async {
    final snapshot = await _visitLogsRef.where('student_id', isEqualTo: studentId).orderBy('visit_date', descending: true).get();
    return snapshot.docs.map((doc) => SupervisorVisitLog.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<Assessment?> getAssessmentForStudent(String studentId) async {
    final snapshot = await _assessmentsRef.where('student_id', isEqualTo: studentId).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return Assessment.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Future<void> setAssessment(Assessment assessment) async {
    await _assessmentsRef.doc(assessment.id).set(assessment.toFirestore());
  }


  /// Number of entries a student has submitted at/after [sinceMs]. Used for
  /// backdated-cluster anomaly detection (3+ entries within a short window).
  Future<int> countEntriesSince(String studentId, int sinceMs) async {
    final snapshot = await _logbookEntriesRef
        .where('student_id', isEqualTo: studentId)
        .where('submitted_at', isGreaterThanOrEqualTo: sinceMs)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// The student's GPS check-in for a specific day (yyyy-MM-dd), if any —
  /// used to gate that day's logbook entry submission.
  Future<AttendanceCheckIn?> getCheckInForDate(String studentId, String date) async {
    final snapshot =
        await _checkInsRef.where('student_id', isEqualTo: studentId).where('date', isEqualTo: date).limit(1).get();
    if (snapshot.docs.isEmpty) return null;
    return AttendanceCheckIn.fromFirestore(snapshot.docs.first.data(), snapshot.docs.first.id);
  }

  Future<List<AttendanceCheckIn>> getCheckInsForStudent(String studentId) async {
    final snapshot = await _checkInsRef.where('student_id', isEqualTo: studentId).orderBy('checked_in_at', descending: true).get();
    return snapshot.docs.map((doc) => AttendanceCheckIn.fromFirestore(doc.data(), doc.id)).toList();
  }

  Future<void> addCheckIn(AttendanceCheckIn checkIn) async {
    await _checkInsRef.doc(checkIn.id).set(checkIn.toFirestore());
  }

  /// Fetches users by id, chunking into groups of 10 to respect Firestore's
  /// `whereIn` limit.
  Future<List<AppUser>> getUsersByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final unique = ids.toSet().toList();
    final chunks = <List<String>>[
      for (var i = 0; i < unique.length; i += 10)
        unique.sublist(i, i + 10 > unique.length ? unique.length : i + 10),
    ];
    final snapshots = await Future.wait(
      chunks.map((chunk) => _usersRef.where(FieldPath.documentId, whereIn: chunk).get()),
    );
    return [
      for (final snapshot in snapshots)
        ...snapshot.docs.map((doc) => AppUser.fromFirestore(doc.data(), doc.id)),
    ];
  }
}
