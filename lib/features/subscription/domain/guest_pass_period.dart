import 'entities/subscription_status.dart';

/// Must stay in sync with entry-scanner `GUEST_PASSES_PER_PERIOD`.
const int kGuestPassesPerPeriod = 2;

/// Billing-period key and renew date for Pro free guest passes.
///
/// Mirrors entry-scanner `guestPassBillingPeriodKey` /
/// `addCalendarMonths` / `formatLocalYmd` exactly so remaining counts match
/// what staff see at the counter.
class GuestPassPeriod {
  const GuestPassPeriod({required this.key, required this.renewsAt});

  /// e.g. `bill:2026-06-22_2026-07-22` or `cal:2026-07`
  final String key;

  /// End of the current quota period (when the next allotment starts).
  final DateTime renewsAt;

  /// Derives the current period from [subscriptions/{uid}] (or calendar
  /// fallback when [status] is null / missing [expiresAt]).
  factory GuestPassPeriod.fromSubscription(
    SubscriptionStatus? status, {
    DateTime? now,
  }) {
    final n = now ?? DateTime.now();
    final exp = status?.expiresAt;
    if (exp == null) {
      final nextMonth = DateTime(n.year, n.month + 1, 1);
      return GuestPassPeriod(
        key: 'cal:${_monthKey(n)}',
        renewsAt: nextMonth,
      );
    }
    final start = addCalendarMonths(exp, -1);
    return GuestPassPeriod(
      key: 'bill:${_ymd(start)}_${_ymd(exp)}',
      renewsAt: exp,
    );
  }
}

/// Add calendar months, clamping day-of-month (e.g. Mar 31 − 1 → Feb 28/29).
DateTime addCalendarMonths(DateTime date, int deltaMonths) {
  final day = date.day;
  final firstOfMonth = DateTime(
    date.year,
    date.month,
    1,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
  final shifted = DateTime(
    firstOfMonth.year,
    firstOfMonth.month + deltaMonths,
    1,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
  final lastDay = DateTime(shifted.year, shifted.month + 1, 0).day;
  return DateTime(
    shifted.year,
    shifted.month,
    day < lastDay ? day : lastDay,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
}

String _ymd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

String _monthKey(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  return '$y-$m';
}
