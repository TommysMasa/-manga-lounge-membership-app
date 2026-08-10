import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';

/// Home-screen coupon card: the member's current coupon rendered in full
/// (bold brand-orange), straight on the home screen. No separate wallet
/// screen; the ladder grants at most one active coupon at a time. Renders
/// nothing when there is no coupon.
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

  Map<String, dynamic>? _coupon;

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
      setState(() => _coupon = list.isEmpty ? _debugSample : list.first);
    } catch (_) {
      // No coupon shown on failure; the card simply stays hidden.
      if (mounted && _debugSample != null) {
        setState(() => _coupon = _debugSample);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final coupon = _coupon;
    if (coupon == null) return const SizedBox.shrink();

    final isFree = coupon['kind'] == 'free_return';
    final percent = coupon['percent'] as int? ?? 0;
    final useToday = coupon['state'] == 'use-today';
    final lastValidDate = coupon['lastValidDate'] as String? ?? '';
    final daysLeft = coupon['daysLeft'] as int? ?? 0;

    final String pillLabel;
    if (useToday) {
      pillLabel = 'Use today';
    } else if (daysLeft <= 0) {
      pillLabel = 'Last day!';
    } else if (daysLeft == 1) {
      pillLabel = '1 day left';
    } else {
      pillLabel = '$daysLeft days left';
    }

    final String subtitle;
    if (useToday) {
      subtitle = isFree ? 'This visit is on us' : 'This visit';
    } else {
      subtitle = 'Your next visit · valid through $lastValidDate';
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.primaryOrange,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: isFree
                        ? const [
                            TextSpan(
                              text: 'FREE',
                              style: TextStyle(fontSize: 40),
                            ),
                            TextSpan(
                              text: ' VISIT',
                              style: TextStyle(fontSize: 18),
                            ),
                          ]
                        : [
                            TextSpan(
                              text: '$percent',
                              style: const TextStyle(fontSize: 40),
                            ),
                            const TextSpan(
                              text: '% ',
                              style: TextStyle(fontSize: 22),
                            ),
                            const TextSpan(
                              text: 'OFF',
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                  ),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0x48000000),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  pillLabel,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFFFFE3C4)),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x59FFFFFF)),
              ),
            ),
            child: const Text(
              'Applied automatically at checkout',
              style: TextStyle(fontSize: 11, color: Color(0xFFFFD5A6)),
            ),
          ),
        ],
      ),
    );
  }
}
