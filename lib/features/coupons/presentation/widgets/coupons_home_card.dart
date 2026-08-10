import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';

/// Home-screen card surfacing the member's best current coupon (or an
/// invitation when there is none). Tap opens the full coupon wallet.
class CouponsHomeCard extends ConsumerStatefulWidget {
  const CouponsHomeCard({super.key});

  @override
  ConsumerState<CouponsHomeCard> createState() => _CouponsHomeCardState();
}

class _CouponsHomeCardState extends ConsumerState<CouponsHomeCard> {
  /// Debug builds only: sample coupon so the design can be previewed on the
  /// simulator even when the signed-in account has none. Never shows in
  /// release/TestFlight builds.
  static final Map<String, dynamic>? _debugSample = kDebugMode
      ? {
          'kind': 'percent',
          'percent': 30,
          'state': 'come-back',
          'lastValidDate': 'Aug 15',
          'daysLeft': 3,
        }
      : null;

  Map<String, dynamic>? _top;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    try {
      final callable = ref
          .read(functionsProvider)
          .httpsCallable(
            'getMyCoupons',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 10)),
          );
      final result = await callable.call<Map<dynamic, dynamic>>({});
      if (!mounted) return;
      final list = (result.data['coupons'] as List<dynamic>? ?? [])
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
      setState(() => _top = list.isEmpty ? _debugSample : list.first);
    } catch (_) {
      // No coupon shown on failure; the card simply stays hidden.
      if (mounted && _debugSample != null) setState(() => _top = _debugSample);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = _top;

    // No coupon (or still loading): take up no space at all. The card
    // appearing IS the notification that a coupon exists.
    if (top == null) return const SizedBox.shrink();

    final String title;
    final String subtitle;
    if (top['state'] == 'use-today') {
      title = top['kind'] == 'free_return'
          ? 'This visit is free!'
          : '${top['percent']}% off today';
      subtitle = 'Applied automatically at checkout';
    } else {
      final daysLeft = top['daysLeft'] as int? ?? 0;
      title = top['kind'] == 'free_return'
          ? 'Free return visit waiting'
          : '${top['percent']}% off your next visit';
      subtitle = daysLeft <= 0
          ? 'Last day: today!'
          : 'Valid through ${top['lastValidDate']} ($daysLeft day${daysLeft == 1 ? '' : 's'} left)';
    }

    return GestureDetector(
      onTap: () => const CouponsRoute().push<void>(context),
      child: Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primaryOrange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                CupertinoIcons.ticket_fill,
                color: AppTheme.primaryOrange,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_forward,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
