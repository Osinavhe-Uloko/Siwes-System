import 'package:uuid/uuid.dart';

import '../models/compliance_flag.dart';
import '../models/logbook_entry.dart';
import '../services/firestore_service.dart';

class ComplianceService {
  ComplianceService(this._firestoreService);

  final FirestoreService _firestoreService;
  final Uuid _uuid = const Uuid();

  /// Scans all students for missed entries / overdue reviews and files
  /// compliance flags for anything new.
  ///
  /// Fetches each student's entries in parallel (one query per student,
  /// concurrently, instead of the previous per-student *and* per-pending-
  /// entry sequential re-queries) and fetches the full flag list once
  /// up front instead of re-querying it per student/entry.
  Future<void> runCoordinatorDetection() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final results = await (
      _firestoreService.getStudents(),
      _firestoreService.getFlags(),
    ).wait;
    final students = results.$1;
    final allFlags = results.$2;

    final entriesByStudent = await Future.wait(
      students.map((s) => _firestoreService.getEntriesForStudent(s.id)),
    );

    final newFlags = <ComplianceFlag>[];

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final entries = entriesByStudent[i];
      final existingFlags = allFlags.where((f) => f.studentId == student.id).toList();

      if (entries.isNotEmpty) {
        final lastEntry = entries.reduce((a, b) => a.submittedAt > b.submittedAt ? a : b);
        final age = now - lastEntry.submittedAt;
        if (age > 3 * 24 * 60 * 60 * 1000) {
          final hasMissed = existingFlags.any((f) => f.flagType == 'missed_entry' && !f.resolved);
          if (!hasMissed) {
            newFlags.add(ComplianceFlag(
              id: _uuid.v4(),
              studentId: student.id,
              flagType: 'missed_entry',
              detectedAt: now,
              resolved: false,
            ));
          }
        }
      }

      for (final LogbookEntry entry in entries.where((e) => e.status == 'pending')) {
        final age = now - entry.submittedAt;
        if (age > 7 * 24 * 60 * 60 * 1000) {
          final hasOverdue = existingFlags.any(
            (f) => f.flagType == 'overdue_review' && f.logbookEntryId == entry.id && !f.resolved,
          );
          if (!hasOverdue) {
            newFlags.add(ComplianceFlag(
              id: _uuid.v4(),
              studentId: student.id,
              logbookEntryId: entry.id,
              flagType: 'overdue_review',
              detectedAt: now,
              resolved: false,
            ));
          }
        }
      }
    }

    if (newFlags.isNotEmpty) {
      await Future.wait(newFlags.map(_firestoreService.addFlag));
    }
  }

  Future<void> flagBackdatedCluster({required String studentId, required String entryId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existingFlags = await _firestoreService.getFlagsForStudent(studentId);
    final hasBackdated = existingFlags.any((flag) => flag.flagType == 'backdated_cluster' && flag.logbookEntryId == entryId && !flag.resolved);
    if (!hasBackdated) {
      await _firestoreService.addFlag(ComplianceFlag(
        id: _uuid.v4(),
        studentId: studentId,
        logbookEntryId: entryId,
        flagType: 'backdated_cluster',
        detectedAt: now,
        resolved: false,
      ));
    }
  }

  Future<void> flagInactiveSupervisor({required String studentId}) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _firestoreService.addFlag(ComplianceFlag(
      id: _uuid.v4(),
      studentId: studentId,
      flagType: 'inactive_supervisor',
      detectedAt: now,
      resolved: false,
    ));
  }
}
