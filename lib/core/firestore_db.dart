import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

/// The Firestore instance for the SIWES backend. This project uses a named
/// (non-default) database, so every read/write must go through this getter
/// rather than `FirebaseFirestore.instance`.
FirebaseFirestore get siwesFirestore =>
    FirebaseFirestore.instanceFor(app: Firebase.app(), databaseId: kFirestoreDatabaseId);
