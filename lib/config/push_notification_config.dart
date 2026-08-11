import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// FCM push notification setup.
///
/// The OS permission prompt is not shown at login. Pro members can enable
/// notifications from the subscription screen; until permission is granted,
/// token registration silently no-ops.
///
/// Topics used for sending from the Firebase Console (or Cloud Functions):
/// - `all`: every device that granted notification permission
/// - `pro`: devices belonging to active Pro members
///
/// The device's FCM token is mirrored to `users/{uid}.fcmToken` only after
/// a profile document exists (update, never create), so signup routing is
/// not confused by a token-only stub doc.
/// Opens the in-app event flyer for an FCM `type=event` payload.
typedef EventNotificationOpener =
    void Function({
      required String imageUrl,
      required String ticketUrl,
      required String title,
    });

/// Opens the in-app waitlist screen for an FCM `type=waitlist_called` payload.
typedef WaitlistNotificationOpener =
    void Function(Map<String, dynamic> data);

class PushNotificationConfig {
  static StreamSubscription<String>? _tokenRefreshSubscription;
  static StreamSubscription<RemoteMessage>? _openedAppSubscription;
  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static String? _uid;
  static FirebaseFirestore? _firestore;
  static EventNotificationOpener? _onEventOpen;
  static WaitlistNotificationOpener? _onWaitlistOpen;

  /// Global, auth-independent setup. Call once at app startup.
  static Future<void> initialize() async {
    // Show notifications while the app is in the foreground on iOS
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    // Foreground pushes: iOS shows the native banner (options above), but
    // Android shows nothing and a muted iPhone stays silent. A double
    // haptic buzz makes the phone felt in hand in every case, so a push
    // that arrives while the customer is using the app still registers
    // (e.g. the checkout coupon push, announced by staff at the counter).
    await _foregroundSubscription?.cancel();
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
  }

  /// Broadcast of pushes received while the app is in the foreground, for
  /// widgets that want to refresh on arrival (e.g. the home coupon card on
  /// `type=coupon_acquired`).
  static final StreamController<RemoteMessage> _foregroundMessages =
      StreamController<RemoteMessage>.broadcast();
  static Stream<RemoteMessage> get foregroundMessages =>
      _foregroundMessages.stream;

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.notification == null && message.data.isEmpty) return;
    _foregroundMessages.add(message);
    try {
      await HapticFeedback.vibrate();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      await HapticFeedback.vibrate();
    } catch (_) {
      // Haptics are best-effort; never let them break message handling.
    }
  }

  /// Listens for notification taps that should open the event flyer.
  ///
  /// Firebase Console custom data for event announcements:
  /// - `type`: `event`
  /// - `imageUrl`: HTTPS image URL
  /// - `ticketUrl`: ticket page URL
  /// - `title` (optional): screen title
  static Future<void> listenForEventOpens(EventNotificationOpener onOpen) async {
    _onEventOpen = onOpen;
    await _openedAppSubscription?.cancel();

    // App launched from a terminated state by tapping a notification
    try {
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _handleOpenedMessage(initial);
    } catch (e) {
      debugPrint('getInitialMessage failed: $e');
    }

    // App opened from background by tapping a notification
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleOpenedMessage,
    );
  }

  /// Registers the handler for `type=waitlist_called` notification taps.
  /// Call once alongside [listenForEventOpens] (which owns the message
  /// subscriptions).
  static void listenForWaitlistOpens(WaitlistNotificationOpener onOpen) {
    _onWaitlistOpen = onOpen;
  }

  static void _handleOpenedMessage(RemoteMessage message) {
    final data = message.data;

    if (data['type'] == 'waitlist_called') {
      _onWaitlistOpen?.call(Map<String, dynamic>.from(data));
      return;
    }

    final opener = _onEventOpen;
    if (opener == null) return;

    if (data['type'] != 'event') return;

    final imageUrl = (data['imageUrl'] ?? '').trim();
    final ticketUrl = (data['ticketUrl'] ?? '').trim();
    if (imageUrl.isEmpty || ticketUrl.isEmpty) {
      debugPrint('Event notification missing imageUrl or ticketUrl');
      return;
    }

    final title = (data['title'] ?? message.notification?.title ?? 'Event')
        .trim();
    opener(imageUrl: imageUrl, ticketUrl: ticketUrl, title: title);
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

  /// Whether notification permission is currently granted (never prompts).
  static Future<bool> isPermissionGranted() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      return _isGranted(settings);
    } catch (e) {
      debugPrint('Notification settings check failed: $e');
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
        // update() (not set/merge) so we never create a bare users/{uid}
        // doc before profile registration. A missing profile throws and is
        // swallowed below — call registerForUser again after signup.
        await firestore.collection('users').doc(uid).update({
          'fcmToken': token,
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Simulator / missing APNs can hang forever on getToken().
      final token = await messaging.getToken().timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (token != null) await saveToken(token);

      await _tokenRefreshSubscription?.cancel();
      _tokenRefreshSubscription = messaging.onTokenRefresh.listen((token) {
        saveToken(token);
      });

      await messaging.subscribeToTopic('all').timeout(
        const Duration(seconds: 8),
        onTimeout: () {},
      );
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
