import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';

/// Coupon wallet: every discount this member currently holds, with its
/// deadline. Data comes from the `getMyCoupons` callable so eligibility
/// rules live in one place (the backend).
class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  List<Map<String, dynamic>>? _coupons;
  bool _failed = false;

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
      setState(() {
        // Debug builds preview the card design with a sample when the
        // account has no coupons; release builds never do this.
        _coupons = list.isEmpty && kDebugMode
            ? [
                {
                  'kind': 'percent',
                  'percent': 30,
                  'state': 'come-back',
                  'lastValidDate': 'Aug 15',
                  'daysLeft': 3,
                },
              ]
            : list;
        _failed = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: const CupertinoNavigationBar(middle: Text('My Coupons')),
      child: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_failed) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Could not load your coupons.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            CupertinoButton.filled(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }
    final coupons = _coupons;
    if (coupons == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (coupons.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.ticket,
                size: 56,
                color: AppTheme.textSecondary,
              ),
              SizedBox(height: 16),
              Text(
                'No coupons right now',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                'Come visit us! Return coupons unlock after each visit.',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        for (final coupon in coupons) ...[
          _CouponCard(coupon: coupon),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({required this.coupon});

  final Map<String, dynamic> coupon;

  @override
  Widget build(BuildContext context) {
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
      subtitle = 'Your next visit \u00b7 valid through $lastValidDate';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
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
                    fontWeight: FontWeight.w800,
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
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
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
