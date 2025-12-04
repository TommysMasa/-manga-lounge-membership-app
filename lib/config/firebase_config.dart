import 'package:firebase_core/firebase_core.dart';
import 'package:manga_lounge/firebase_options.dart';

/// Firebase initialization and configuration
class FirebaseConfig {
  /// Initialize Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Check if Firebase is initialized
  static bool get isInitialized {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
