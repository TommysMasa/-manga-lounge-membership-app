import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// FCM push notification setup.
///
/// The OS permission prompt is intentionally NOT shown at login: it appears
/// the first time the user checks in (see CheckInTimerFlow). Until then,
/// token registration silently no-ops.
///
/// Topics used for sending from the Firebase Console (or Cloud Functions):
/// - `all`: every device that granted notification permission
/// - `pro`: devices belonging to active Pro members
///
/// The device's FCM token is also mirrored to `users/{uid}.fcmToken` so
/// individual users can be targeted later if needed.
class PushNotificationConfig {
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _uid;
  static FirebaseFirestore? _firestore;

  /// Global, auth-independent setup. Call once at app startup.
  static Future<void> initialize() async {
    // Show notifications while the app is in the foreground on iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Remembers the user and, if notification permission was already granted
  /// in a previous session, saves the device token and subscribes to the
  /// `all` topic. Call after the user is authenticated.
  ///
  /// Never shows the OS permission dialog.
  ///
  /// Notifications are a nice-to-have, so all failures are swallowed.
  static Future<void> registerForUser(
    String uid,
    FirebaseFirestore firestore,
  ) async {
    _uid = uid;
    _firestore = firestore;
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (_isGranted(settings)) {
        await _register();
      }
    } catch (e) {
      debugPrint('Push notification registration failed: $e');
    }
  }

  /// Shows the OS permission dialog (unless already decided) and returns
  /// whether notifications are allowed. On grant, completes the FCM
  /// registration that was skipped at login.
  static Future<bool> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      final granted = _isGranted(settings);
      if (granted) {
        // Fire-and-forget: getToken() can take a while (or never resolve on
        // the simulator, which has no APNs), and callers are UI flows that
        // must not block on it.
        unawaited(_register());
      }
      return granted;
    } catch (e) {
      debugPrint('Notification permission request failed: $e');
      return false;
    }
  }

  static bool _isGranted(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  static Future<void> _register() async {
    final uid = _uid;
    final firestore = _firestore;
    if (uid == null || firestore == null) return;

    try {
      final messaging = FirebaseMessaging.instance;

      Future<void> saveToken(String token) async {
        // Skip if the user changed while the token was being fetched
        if (_uid != uid) return;
        await firestore.collection('users').doc(uid).set({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      final token = await messaging.getToken();
      if (token != null) await saveToken(token);

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) {
        saveToken(token);
      });

      await messaging.subscribeToTopic('all');
    } catch (e) {
      debugPrint('Push notification registration failed: $e');
    }
  }

  /// Stops writing tokens for the previous user. Call on sign out.
  ///
  /// The `all` topic subscription is intentionally kept: general
  /// announcements are not user-specific.
  static Future<void> unregister() async {
    _uid = null;
    _firestore = null;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('pro');
    } catch (e) {
      debugPrint('Push notification unregister failed: $e');
    }
  }

  /// Keeps the `pro` topic subscription in sync with the user's Pro status.
  static Future<void> setProTopic(bool isPro) async {
    try {
      if (isPro) {
        await FirebaseMessaging.instance.subscribeToTopic('pro');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('pro');
      }
    } catch (e) {
      debugPrint('Pro topic update failed: $e');
    }
  }
}
