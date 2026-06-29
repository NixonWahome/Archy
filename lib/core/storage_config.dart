/// Configuration for the free, no-credit-card file host (Cloudinary).
///
/// Why Cloudinary: the free tier needs **no credit card**, gives ~25 GB storage
/// + 25 GB/month bandwidth, serves public HTTPS URLs (which Android Scene Viewer
/// / model_viewer_plus can load directly), and supports **unsigned uploads** so
/// the app never embeds a secret key.
///
/// ── One-time setup (≈2 min, free, no card) ──────────────────────────────────
/// 1. Create an account at https://cloudinary.com/users/register_free
/// 2. Dashboard → copy your **Cloud name** → paste into [cloudName] below.
/// 3. Settings (gear) → **Upload** → Upload presets → **Add upload preset**:
///       • Signing Mode: **Unsigned**
///       • Save, then copy its name → paste into [uploadPreset] below.
/// 4. (Optional) In the preset, set a folder like `archy` to keep things tidy.
///
/// That's it — no billing, no service account. Until these are filled in,
/// [StorageConfig.isConfigured] is false and uploads surface a clear message
/// instead of silently failing.
class StorageConfig {
  /// Your Cloudinary cloud name (Dashboard → "Cloud name").
  static const String cloudName = 'YOUR_CLOUD_NAME';

  /// An **unsigned** upload preset name (Settings → Upload → Upload presets).
  static const String uploadPreset = 'YOUR_UNSIGNED_PRESET';

  static bool get isConfigured =>
      cloudName != 'YOUR_CLOUD_NAME' &&
      uploadPreset != 'YOUR_UNSIGNED_PRESET' &&
      cloudName.isNotEmpty &&
      uploadPreset.isNotEmpty;
}
