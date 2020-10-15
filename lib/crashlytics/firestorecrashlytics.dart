part of masamune.firebase.mobile;

/// Manage Firebase Crashlytics.
///
/// Please execute before [runApp] of [main()] function.
class FirestoreCrashlytics {
  /// Manage Firebase Crashlytics.
  ///
  /// Please execute before [runApp] of [main()] function.
  static void initialize() {
    if (Log.isDebugBuild) return;
    // Set `enableInDevMode` to true to see reports while in debug mode
    // This is only to be used for confirming that reports are being
    // submitted as expected. It is not intended to be used for everyday
    // development.
    FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(Log.isDebugBuild);
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  }
}
