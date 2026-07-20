import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../config/push_notification_config.dart';
import '../../../shared/theme/app_theme.dart';
import '../../user/domain/entities/user.dart';
import 'providers/checkin_timer_provider.dart';

/// Check-in visit timer prompt.
///
/// When the user gets checked in at the counter, a popup offers to set a
/// timer (1/2/3 hours). If accepted, notification permission is requested
/// (first time only) and a local notification is scheduled.
///
/// Each check-in session (identified by its entry time) is only prompted
/// once, and a pending timer is cancelled automatically on checkout.
class CheckInTimerFlow {
  static const _promptedEntryKey = 'checkin_timer_prompted_entry';
  static bool _inFlight = false;

  /// Reacts to the latest user snapshot. Safe to call repeatedly.
  static Future<void> onUserChanged(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    if (_inFlight) return;
    _inFlight = true;
    try {
      if (!user.isCheckedIn) {
        // Checked out: a pending timer is no longer useful.
        if (ref.read(checkInTimerProvider) != null) {
          await ref.read(checkInTimerProvider.notifier).cancel();
        }
        return;
      }

      final entryTime = user.activeEntryTime;
      if (entryTime == null) return;

      final prefs = await SharedPreferences.getInstance();
      final entryMillis = entryTime.millisecondsSinceEpoch;
      if (prefs.getInt(_promptedEntryKey) == entryMillis) return;
      // Mark before showing so the prompt never re-appears for this visit,
      // even if the user dismisses it or the app restarts mid-flow.
      await prefs.setInt(_promptedEntryKey, entryMillis);

      if (!context.mounted) return;
      await _runPrompt(context, ref);
    } finally {
      _inFlight = false;
    }
  }

  static Future<void> _runPrompt(BuildContext context, WidgetRef ref) async {
    final wantsTimer = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Set a Timer?'),
        content: const Text(
          'Welcome to Manga Lounge! Would you like to be '
          'notified after a set amount of time?',
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    if (wantsTimer != true || !context.mounted) return;

    // Shows the OS permission dialog if not yet determined.
    final granted = await PushNotificationConfig.requestPermission();
    if (!context.mounted) return;
    if (!granted) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) => CupertinoAlertDialog(
          title: const Text('Notifications Are Off'),
          content: const Text(
            'To use the timer, please allow notifications for '
            'Manga Lounge in the Settings app.',
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final duration = await showCupertinoModalPopup<Duration>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Notify me in...'),
        actions: [
          for (final hours in [1, 2, 3])
            CupertinoActionSheetAction(
              onPressed: () =>
                  Navigator.of(sheetContext).pop(Duration(hours: hours)),
              child: Text(hours == 1 ? '1 hour' : '$hours hours'),
            ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(sheetContext).pop(),
          child: const Text('Cancel'),
        ),
      ),
    );
    if (duration == null || !context.mounted) return;

    await ref.read(checkInTimerProvider.notifier).start(duration);
    if (context.mounted) {
      final hours = duration.inHours;
      AppTheme.showNotification(
        context,
        message:
            'Timer set. We\'ll notify you in '
            '${hours == 1 ? '1 hour' : '$hours hours'}.',
      );
    }
  }
}
