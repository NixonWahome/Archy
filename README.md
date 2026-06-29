# Archy

A cross-platform **architecture & real-estate collaboration platform** that lets architects
publish 3D building designs, diaspora clients tour them remotely (virtual + on-device AR) and
approve milestone payments, and developers list and sell properties — all on a single
real-time backend.

Built with **Flutter**, **Firebase**, **Unity AR**, and a **.NET** model-processing service.

---

## What it does

Three role-based dashboards on top of one shared, real-time data layer:

| Role | Capabilities |
|------|--------------|
| **Architect** | Create projects, assign a diaspora client by email, define milestones & budgets, run a budget simulator, chat with the client |
| **Diaspora client** | Virtual + AR site visits of assigned projects, real-time co-presence walkthroughs, approve/reject/pay milestones, chat |
| **Developer** | List properties with media, view live listings, capture sales & leads |

Cross-cutting: email/password auth with role onboarding, a co-presence walkthrough where
participants see each other live (Firestore-backed sessions), and project chat.

## Architecture

- **`lib/`** — Flutter app (the bulk of the code)
  - `core/services/` — `AuthService`, `DatabaseService` (Firestore), `SessionService`
    (real-time co-presence), `StorageService` (Cloudinary uploads)
  - `core/models/` — `User`, `Project`, `Property`, `Message`
  - `core/design/` — a small design system ("Clay & Blueprint" light + "Midnight" dark
    palettes): tokens, theming, shared widgets, and a common dashboard scaffold so all three
    dashboards stay visually consistent
  - `screens/` — auth flow + the three role dashboards and their detail/form screens
- **Unity AR** — a Mobile-AR-Template Unity project (AR Foundation + ARCore) bridged into
  Flutter via `flutter_unity_widget`. A runtime `ModelLoader` fetches a glTF model by URL
  (glTFast), places it in AR, and normalizes its scale. The generated Android export is **not**
  committed (it's ~5 GB of native libs); it is regenerated from the Unity project via
  *Flutter → Export Android*. The non-Unity AR path uses `model_viewer_plus` / Scene Viewer.
- **`backend/`** — a small ASP.NET Core service that post-processes uploaded 3D models
  (Blender headless), with Hangfire for background jobs.
- **Firebase** — Auth + Cloud Firestore (security rules in `firestore.rules`, enforcing
  per-role / per-owner access). File storage uses **Cloudinary** (unsigned uploads — no
  embedded secret) instead of Firebase Storage.

## Tech stack

Flutter · Dart · Firebase Auth · Cloud Firestore · Provider · Unity (AR Foundation, ARCore,
glTFast) · `flutter_unity_widget` · `model_viewer_plus` · Cloudinary · ASP.NET Core (.NET 8) ·
Hangfire · Blender (headless).

## Running it

```bash
flutter pub get
flutter run        # or: flutter build apk
```

**Notes for a fresh clone**
- Firebase config is not committed. Run `flutterfire configure` to generate your own
  `firebase_options.dart`, and drop your `google-services.json` / `GoogleService-Info.plist`
  into place (see the `*.example` templates).
- File uploads require a free Cloudinary cloud name + unsigned upload preset in
  `lib/core/storage_config.dart`.
- The AR (Unity) path requires re-exporting the Unity Android library; the `model_viewer_plus`
  AR path works without it.

---

*Personal full-stack project — Flutter mobile, real-time Firebase backend, Unity AR, and a .NET microservice.*
