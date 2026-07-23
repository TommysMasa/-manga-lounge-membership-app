import 'package:flutter_test/flutter_test.dart';
import 'package:manga_lounge/features/subscription/domain/entities/subscription_status.dart';
import 'package:manga_lounge/features/subscription/domain/guest_pass_period.dart';

void main() {
  group('addCalendarMonths', () {
    test('subtracts one month with day clamping', () {
      final mar31 = DateTime(2026, 3, 31, 15, 30);
      final feb = addCalendarMonths(mar31, -1);
      expect(feb.year, 2026);
      expect(feb.month, 2);
      expect(feb.day, 28);
      expect(feb.hour, 15);
      expect(feb.minute, 30);
    });
  });

  group('GuestPassPeriod.fromSubscription', () {
    test('uses billing window from expiresAt', () {
      final expires = DateTime(2026, 7, 22, 12);
      final period = GuestPassPeriod.fromSubscription(
        SubscriptionStatus(isPro: true, expiresAt: expires),
      );
      expect(period.key, 'bill:2026-06-22_2026-07-22');
      expect(period.renewsAt, expires);
    });

    test('falls back to calendar month when expiresAt is missing', () {
      final now = DateTime(2026, 7, 15);
      final period = GuestPassPeriod.fromSubscription(null, now: now);
      expect(period.key, 'cal:2026-07');
      expect(period.renewsAt, DateTime(2026, 8, 1));
    });
  });
}
