import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// FCM push notification setup.
///
/// Topics used for sending from the Firebase Console (or Cloud Functions):
/// - `all`: every device that granted notification permission
/// - `pro`: devices belonging to active Pro members
///
/// The device's FCM token is also mirrored to `users/{uid}.fcmToken` so
/// individual users can be targeted later if needed.
class PushNotificationConfig {
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static String? _registeredUid;

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

  /// Asks for permission, saves the device token, and subscribes to the
  /// `all` topic. Call after the user is authenticated.
  ///
  /// Notifications are a nice-to-have, so all failures are swallowed.
  static Future<void> registerForUser(
    String uid,
    FirebaseFirestore firestore,
  ) async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }

      _registeredUid = uid;

      Future<void> saveToken(String token) async {
        final registeredUid = _registeredUid;
        if (registeredUid == null) return;
        await firestore.collection('users').doc(registeredUid).set({
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
    _registeredUid = null;
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
