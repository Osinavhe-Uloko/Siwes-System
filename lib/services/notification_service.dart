import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../core/firestore_db.dart';
import '../models/app_user.dart';
import 'firestore_service.dart';

const _channelId = 'siwes_updates';

/// Shows system notification banners for logbook/compliance events while the
/// app process is alive, driven by realtime Firestore listeners rather than
/// a server push — there's no backend (Cloud Functions) wired up yet to send
/// real FCM pushes, so nothing arrives while the app is fully closed. The
/// FCM token is still registered on the user's profile so a future
/// server-side sender can start targeting it without any client changes.
class NotificationService {
  final FirebaseFirestore _db = siwesFirestore;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  int _notificationId = 0;
  StreamSubscription? _tokenRefreshSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _entriesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _flagsSub;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;

    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      'SIWES Updates',
      description: 'Logbook reviews and compliance flag alerts',
      importance: Importance.high,
    );
    await _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await FirebaseMessaging.instance.requestPermission();
    await _local
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _show({required String title, required String body}) {
    return _local.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, 'SIWES Updates', importance: Importance.high, priority: Priority.high),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> registerToken(AppUser user, FirestoreService firestore) async {
    await _ensureInitialized();
    final token = await FirebaseMessaging.instance.getToken();
    if (token != null) {
      await firestore.updateFcmToken(user.id, token);
    }
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      firestore.updateFcmToken(user.id, newToken);
    });
  }

  Future<void> startListening(AppUser user) async {
    await _ensureInitialized();
    await stopListening();

    if (user.role == 'student') {
      _entriesSub = _firstSnapshotSkipped(
        _db.collection('logbook_entries').where('student_id', isEqualTo: user.id).snapshots(),
      ).listen((snapshot) {
        for (final change in snapshot.docChanges) {
          if (change.type != DocumentChangeType.modified) continue;
          final data = change.doc.data();
          if (data == null || data['status'] == 'pending') continue;
          final flagged = data['status'] == 'flagged';
          _show(
            title: flagged ? 'Entry flagged for changes' : 'Logbook entry reviewed',
            body: 'Week ${data['week_number']} • ${data['entry_date']}',
          );
        }
      });

      _flagsSub = _firstSnapshotSkipped(
        _db.collection('compliance_flags').where('student_id', isEqualTo: user.id).where('resolved', isEqualTo: false).snapshots(),
      ).listen((snapshot) => _notifyNewFlags(snapshot));
      return;
    }

    if (user.role == 'coordinator' || user.role == 'institution_supervisor') {
      _flagsSub = _firstSnapshotSkipped(
        _db.collection('compliance_flags').where('resolved', isEqualTo: false).snapshots(),
      ).listen((snapshot) => _notifyNewFlags(snapshot));
      return;
    }

    if (user.role == 'industry_supervisor') {
      final placements = await _db.collection('placements').where('industry_supervisor_id', isEqualTo: user.id).get();
      final studentIds = placements.docs.map((d) => d.data()['student_id']?.toString()).whereType<String>().toSet();
      if (studentIds.isEmpty) return;

      _flagsSub = _firstSnapshotSkipped(
        _db.collection('compliance_flags').where('resolved', isEqualTo: false).snapshots(),
      ).listen((snapshot) => _notifyNewFlags(snapshot, onlyStudentIds: studentIds));
    }
  }

  void _notifyNewFlags(QuerySnapshot<Map<String, dynamic>> snapshot, {Set<String>? onlyStudentIds}) {
    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;
      final data = change.doc.data();
      if (data == null) continue;
      if (onlyStudentIds != null && !onlyStudentIds.contains(data['student_id'])) continue;
      final flagType = (data['flag_type'] as String? ?? 'compliance_flag').replaceAll('_', ' ').toUpperCase();
      _show(title: flagType, body: 'New compliance flag detected');
    }
  }

  /// Firestore's `.snapshots()` replays the entire current result set as
  /// `added` changes the moment a listener attaches — without this, every
  /// pre-existing flag/entry would re-notify on every cold start. Dropping
  /// that first snapshot establishes a silent baseline instead.
  Stream<QuerySnapshot<Map<String, dynamic>>> _firstSnapshotSkipped(Stream<QuerySnapshot<Map<String, dynamic>>> source) {
    var seenFirst = false;
    return source.where((snapshot) {
      if (!seenFirst) {
        seenFirst = true;
        return false;
      }
      return true;
    });
  }

  Future<void> stopListening() async {
    await _entriesSub?.cancel();
    await _flagsSub?.cancel();
    _entriesSub = null;
    _flagsSub = null;
  }

  Future<void> dispose() async {
    await stopListening();
    await _tokenRefreshSub?.cancel();
  }
}
