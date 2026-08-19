import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/firestore_db.dart';
import 'firebase_options.dart';
import 'providers.dart';
import 'services/onboarding_service.dart';

/// Runs Firebase/SharedPreferences startup work *after* the first frame is
/// already on screen, instead of blocking `runApp()` on it. The native splash
/// only stays up until Flutter draws something — so drawing this loading
/// screen immediately lets it dismiss right away, replaced by our own
/// (much faster, fully in our control) in-app spinner while the real app
/// finishes booting in the background.
class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key});

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  OnboardingService? _onboarding;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final results = await (
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      OnboardingService.load(),
    ).wait;
    siwesFirestore.settings = const Settings(persistenceEnabled: true);
    if (!mounted) return;
    setState(() => _onboarding = results.$2);
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = _onboarding;
    if (onboarding == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return ProviderScope(
      overrides: [onboardingServiceProvider.overrideWithValue(onboarding)],
      child: SiwesApp(onboarding: onboarding),
    );
  }
}
