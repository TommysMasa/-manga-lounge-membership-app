import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manga_lounge/core/di/providers.dart';
import 'package:manga_lounge/features/coupons/presentation/providers/coupon_providers.dart';
import 'package:manga_lounge/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:manga_lounge/features/user/domain/entities/user.dart';
import 'package:manga_lounge/features/user/presentation/screens/home_screen.dart';
import 'package:manga_lounge/shared/widgets/branded_loading_screen.dart';

class FakeFunctions extends Mock implements FirebaseFunctions {}

void main() {
  testWidgets('member Home renders while coupon fetch is still pending', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final pendingCoupon = Completer<Map<String, dynamic>?>();
    final user = User(
      uid: 'synthetic',
      firstName: 'Test',
      lastName: 'Member',
      gender: 'Other',
      dateOfBirth: DateTime.utc(2000),
      createdAt: DateTime.utc(2026),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userStreamProvider.overrideWith((_) => Stream.value(user)),
          myCouponProvider.overrideWith((_) => pendingCoupon.future),
          isProProvider.overrideWithValue(false),
          functionsProvider.overrideWithValue(FakeFunctions()),
        ],
        child: const CupertinoApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(pendingCoupon.isCompleted, isFalse);
    expect(find.byType(BrandedLoadingScreen), findsNothing);
    expect(find.textContaining('Test'), findsWidgets);
    await tester.pumpWidget(const SizedBox.shrink());
    pendingCoupon.complete(null);
  });
}
