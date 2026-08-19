import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// The name of the (non-default) Firestore database this project uses.
/// Must be passed to `FirebaseFirestore.instanceFor(databaseId: ...)` since
/// this backend was provisioned by AI Studio with a named database rather
/// than the `(default)` one.
const String kFirestoreDatabaseId = 'ai-studio-4b28ff61-ab2d-456e-8995-0b5700116beb';

/// Shared with the SIWES Monitoring System web app so mobile and web read
/// and write the same Firebase project/data.
///
/// The web values below are copied verbatim from the web app's
/// `firebase-applet-config.json` (a Firebase *web* API key, safe to embed in
/// client code and meant to be restricted via Firestore security rules, not
/// kept secret). Android/iOS reuse the same project credentials as a
/// best-effort default: Auth and Firestore work fine with this, but for a
/// fully correct native setup (Analytics, Crashlytics, Google Sign-In,
/// push notifications) you should run `flutterfire configure
/// --project=gen-lang-client-0234189232` to register real Android/iOS apps
/// and regenerate this file.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyDKCH1UVDW4O9sNj_UmmF4Trti0LcN_bcY',
        appId: '1:112440424904:web:bac22602849c05967068fd',
        messagingSenderId: '112440424904',
        projectId: 'gen-lang-client-0234189232',
        authDomain: 'gen-lang-client-0234189232.firebaseapp.com',
        storageBucket: 'gen-lang-client-0234189232.firebasestorage.app',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDKCH1UVDW4O9sNj_UmmF4Trti0LcN_bcY',
          appId: '1:112440424904:web:bac22602849c05967068fd',
          messagingSenderId: '112440424904',
          projectId: 'gen-lang-client-0234189232',
          storageBucket: 'gen-lang-client-0234189232.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDKCH1UVDW4O9sNj_UmmF4Trti0LcN_bcY',
          appId: '1:112440424904:web:bac22602849c05967068fd',
          messagingSenderId: '112440424904',
          projectId: 'gen-lang-client-0234189232',
          storageBucket: 'gen-lang-client-0234189232.firebasestorage.app',
          iosBundleId: 'com.example.siwesMonitor',
        );
      default:
        return const FirebaseOptions(
          apiKey: 'AIzaSyDKCH1UVDW4O9sNj_UmmF4Trti0LcN_bcY',
          appId: '1:112440424904:web:bac22602849c05967068fd',
          messagingSenderId: '112440424904',
          projectId: 'gen-lang-client-0234189232',
          storageBucket: 'gen-lang-client-0234189232.firebasestorage.app',
        );
    }
  }
}
