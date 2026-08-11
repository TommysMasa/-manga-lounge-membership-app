import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';

/// The member's current coupon (`getMyCoupons` returns at most one), or null
/// when there is none. Lives here rather than in the card so the home screen
/// can hold its branded loading screen until the first fetch resolves and
/// reveal the whole page at once.
///
/// Bounded at 3.5s: past that we resolve to null so the loading gate can
/// never hang the home screen; the next foreground refresh retries.
final myCouponProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  try {
    final callable = ref
        .read(functionsProvider)
        .httpsCallable(
          'getMyCoupons',
          options: HttpsCallableOptions(timeout: const Duration(seconds: 10)),
        );
    final result = await callable
        .call<Map<dynamic, dynamic>>({})
        .timeout(const Duration(milliseconds: 3500));
    final list = (result.data['coupons'] as List<dynamic>? ?? [])
        .map((c) => Map<String, dynamic>.from(c as Map))
        .toList();
    return list.isEmpty ? null : list.first;
  } catch (_) {
    // No coupon on failure; the card simply stays hidden.
    return null;
  }
});
