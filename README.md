# 📘 SIWES Monitor

**A real-time, GPS-verified mobile platform for supervising Students' Industrial Work Experience Scheme (SIWES) placements — built with Flutter and Firebase.**

SIWES Monitor replaces the paper logbook. Students log their daily industrial training activity from their phone, supervisors review and flag entries instantly, and GPS-based attendance checks confirm a student was actually on-site before they're allowed to submit that day's entry.

---

## ✨ Features

### For Students
- 📓 **Digital logbook** — submit daily entries with auto-calculated week numbers based on placement start date
- 📍 **GPS check-in gate** — must check in within range of the registered placement location before submitting a logbook entry for the day (hard-gated, not just tracked)
- 📊 **Standing dashboard** — live status (Good Standing / Flagged / Missed Entries) computed from actual entry history, not a static field
- 🔔 **Push + in-app notifications** — instant alerts when a supervisor approves or flags an entry

### For Institutional & Industry Supervisors
- ✅ **One-tap review** — approve or flag logbook entries with optimistic, sub-second UI updates
- 🗺️ **Attendance history** — see each student's daily GPS check-ins, distance from placement, and a direct link to view the location on a map
- 🏢 **Placement management** — register a placement's company details, supervision assignment, and GPS coordinates
- 🚩 **Flag review queue** — centralized view of all unresolved flags across supervised students

### For Coordinators / Admins
- 👥 Manage students and supervisor accounts
- 🧭 Automated compliance detection — flags students who go quiet or miss logbook entries
- 🔐 Role-based access enforced end-to-end via Firestore Security Rules

### Platform
- 🚀 **Onboarding flow** shown on first run (and again after logout)
- 🔑 Email/password auth with password-visibility toggles
- 🎨 Custom app icon and adaptive launch experience
- ⚡ Every screen loads its data via parallelized queries — no sequential waterfalls

---

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart 3) |
| State management | [Riverpod](https://riverpod.dev) |
| Routing | [go_router](https://pub.dev/packages/go_router) |
| Backend | [Firebase](https://firebase.google.com) — Auth, Cloud Firestore, Cloud Messaging |
| Location | [geolocator](https://pub.dev/packages/geolocator) (Haversine distance check-ins) |
| Notifications | `firebase_messaging` + `flutter_local_notifications` |
| Local persistence | `shared_preferences` |
| Charts | `fl_chart` |

---

## 📂 Project Structure

```
lib/
├── core/            # Router, app-wide utilities
├── models/          # AppUser, Placement, LogbookEntry, Flag, AttendanceCheckIn, ...
├── services/        # FirestoreService, AuthService, LocationService, NotificationService
├── screens/         # Role-aware screens (student/coordinator/institution/industry dashboards, logbook, flags, placements, students, supervisors, settings)
├── widgets/          # Shared UI components (scaffold, page header, etc.)
├── bootstrap.dart   # Fast first-frame boot + async Firebase/onboarding init
├── app.dart         # MaterialApp + auth/notification lifecycle wiring
├── providers.dart   # Riverpod provider definitions
└── routes.dart      # Route name constants
```

The repository also contains `web_app/`, a companion React web client backed by the same Firebase project.

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart ^3.8.0)
- A Firebase project with **Authentication**, **Cloud Firestore**, and **Cloud Messaging** enabled
- Android Studio / Xcode for platform builds (or `flutter run` on a connected device)

### Setup

```bash
# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Run static analysis
flutter analyze

# Build a release APK
flutter build apk --release
```

Firebase configuration lives in `lib/firebase_options.dart` (generated via the FlutterFire CLI) and is already wired to this project's Firebase backend. Firestore Security Rules are defined in [`firestore.rules`](./firestore.rules) — role checks (`isCoordinator`, `isInstitutionSupervisor`, `isIndustrySupervisor`, `isStudent`) gate every collection.

### GPS Attendance Setup
For the GPS check-in gate to work, each placement needs its coordinates registered:
1. Sign in as a coordinator or supervisor
2. Open a student's profile → **Placement** section
3. Create/edit the placement and set its GPS location
4. Students within the configured radius of that location can then check in and unlock the day's logbook entry

---

## 🔒 Security

- All data access is enforced server-side via Firestore Security Rules — the client never trusts its own role claims.
- GPS check-ins are written only by the authenticated student for themselves and are immutable once created.
- Passwords are never stored or logged; auth is delegated entirely to Firebase Authentication.

---

## 📄 License

This project is private and intended for institutional SIWES supervision use.
