import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_db.dart';
import '../models/app_user.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = siwesFirestore;

  AppUser? _currentUser;
  bool _isInitializing = true;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isInitializing;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? fbUser) async {
    if (fbUser == null) {
      _currentUser = null;
      _isInitializing = false;
      notifyListeners();
      return;
    }

    final doc = await _db.collection('users').doc(fbUser.uid).get();
    if (doc.exists) {
      _currentUser = AppUser.fromFirestore(doc.data()!, doc.id);
    } else {
      _currentUser = null;
    }
    _isInitializing = false;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final doc = await _db.collection('users').doc(cred.user!.uid).get();
      if (!doc.exists) {
        await _auth.signOut();
        throw Exception('User profile not found in database.');
      }
      _currentUser = AppUser.fromFirestore(doc.data()!, doc.id);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Unable to sign in.');
    }
  }

  /// Self-service registration always creates a `student` account, matching
  /// the web app's Register flow. Other roles (coordinator, supervisors) are
  /// provisioned directly in Firestore/the web app.
  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String matricNumber,
    required String department,
    required String level,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = AppUser(
        id: cred.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'student',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        matricNumber: matricNumber,
        department: department,
        level: level,
      );
      await _db.collection('users').doc(user.id).set(user.toFirestore());
      _currentUser = user;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Unable to register.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  bool hasRole(String role) => _currentUser?.role == role;
}
