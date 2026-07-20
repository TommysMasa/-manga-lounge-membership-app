import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat SDK configuration
///
/// Handles SDK initialization and linking purchases to the
/// authenticated Firebase user.
class RevenueCatConfig {
  /// RevenueCat Test Store key, used for local development (simulator)
  /// where real App Store products are not available.
  static const String _testStoreApiKey = 'test_ghzFagzcrWtdhwXoanQEHLwMDCt';

  /// Production App Store key
  static const String _appleApiKey = 'appl_lGubBRJryDHzETUhPFsiJBdIGzu';

  /// Production Google Play key
  static const String _googleApiKey = 'goog_LRBVrqemDWbLqCYVscghXARfZmr';

  static String get _apiKey {
    // Debug builds keep using the Test Store so the paywall works on the
    // simulator/emulator. Release builds talk to the real stores.
    if (kDebugMode) return _testStoreApiKey;
    if (Platform.isIOS) return _appleApiKey;
    if (Platform.isAndroid) return _googleApiKey;
    return _testStoreApiKey;
  }

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
