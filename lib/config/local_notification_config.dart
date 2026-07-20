import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Device-local scheduled notifications (no server involved).
///
/// Used for the check-in visit timer: the notification is scheduled on the
/// device and fires even if the app is closed or offline.
class LocalNotificationConfig {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Notification id for the check-in visit timer (only one at a time).
  static const int checkInTimerId = 1001;

  static const NotificationDetails _timerDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'checkin_timer',
      'Visit Timer',
      channelDescription: 'Reminders you set when checking in',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    ),
    iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
  );

  /// Call once at app startup.
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Permission is requested through firebase_messaging (same OS
      // permission), so don't ask again here.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: settings);
  }

  /// Schedules the check-in timer notification [duration] from now.
  /// Replaces any previously scheduled timer.
  static Future<void> scheduleCheckInTimer({
    required Duration duration,
    required String body,
  }) async {
    await _plugin.zonedSchedule(
      id: checkInTimerId,
      title: 'Manga Lounge',
      body: body,
      // Relative to now, so the absolute instant is correct regardless of
      // which named timezone tz.local points at.
      scheduledDate: tz.TZDateTime.now(tz.local).add(duration),
      notificationDetails: _timerDetails,
      // Inexact is fine for an hour-scale reminder and avoids the Android
      // 12+ exact-alarm permission.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Cancels a pending check-in timer notification, if any.
  static Future<void> cancelCheckInTimer() async {
    try {
      await _plugin.cancel(id: checkInTimerId);
    } catch (e) {
      debugPrint('Failed to cancel timer notification: $e');
    }
  }
}
