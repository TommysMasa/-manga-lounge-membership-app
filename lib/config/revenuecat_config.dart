import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat SDK configuration
///
/// Handles SDK initialization and linking purchases to the
/// authenticated Firebase user.
class RevenueCatConfig {
  // TODO: 本番リリース前に RevenueCat ダッシュボードの本番キー
  // (iOS: appl_ / Android: goog_ プレフィックス) に差し替えること
  static const String _apiKey = 'test_ghzFagzcrWtdhwXoanQEHLwMDCt';

  /// Entitlement identifier configured in the RevenueCat dashboard
  static const String entitlementId = 'Manga Lounge Memberapp Pro';

  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    if (kDebugMode) {
      await Purchases.setLogLevel(LogLevel.debug);
    }

    await Purchases.configure(PurchasesConfiguration(_apiKey));
  }

  /// Link the RevenueCat user to the app's authenticated user (Firebase UID).
  ///
  /// Purchase state syncing is non-critical, so failures are swallowed.
  static Future<void> logIn(String userId) async {
    try {
      if (!await Purchases.isConfigured) return;
      await Purchases.logIn(userId);
    } catch (e) {
      debugPrint('RevenueCat logIn failed: $e');
    }
  }

  /// Unlink on sign out
  static Future<void> logOut() async {
    try {
      if (!await Purchases.isConfigured) return;
      // logOut throws if the current RevenueCat user is already anonymous
      if (await Purchases.isAnonymous) return;
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logOut failed: $e');
    }
  }
}
