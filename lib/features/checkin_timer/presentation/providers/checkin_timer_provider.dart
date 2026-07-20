import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/local_notification_config.dart';

/// End time of the active check-in visit timer, or null when no timer is set.
///
/// The timer itself is a device-local scheduled notification; this provider
/// only tracks the end time so the UI can show a countdown and offer
/// cancellation. Persisted so the countdown survives app restarts.
final checkInTimerProvider = NotifierProvider<CheckInTimerNotifier, DateTime?>(
  CheckInTimerNotifier.new,
);

class CheckInTimerNotifier extends Notifier<DateTime?> {
  static const _endKey = 'checkin_timer_end';

  @override
  DateTime? build() {
    _restore();
    return null;
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_endKey);
    if (millis == null) return;

    final end = DateTime.fromMillisecondsSinceEpoch(millis);
    if (end.isAfter(DateTime.now())) {
      state = end;
    } else {
      await prefs.remove(_endKey);
    }
  }

  /// Schedules the timer notification and starts the countdown.
  Future<void> start(Duration duration) async {
    final hours = duration.inHours;
    final label = hours == 1 ? '1 hour' : '$hours hours';
    await LocalNotificationConfig.scheduleCheckInTimer(
      duration: duration,
      body: 'Your $label timer is up!',
    );

    final end = DateTime.now().add(duration);
    state = end;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_endKey, end.millisecondsSinceEpoch);
  }

  /// Cancels the pending notification and clears the countdown.
  Future<void> cancel() async {
    await LocalNotificationConfig.cancelCheckInTimer();
    await _clear();
  }

  /// Clears the countdown once the timer has fired (the notification has
  /// already been shown by the OS, nothing to cancel).
  Future<void> clearIfExpired() async {
    final end = state;
    if (end != null && !end.isAfter(DateTime.now())) {
      await _clear();
    }
  }

  Future<void> _clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_endKey);
  }
}
