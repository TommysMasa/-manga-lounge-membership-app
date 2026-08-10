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
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: coupons.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) => _CouponCard(coupon: coupons[i]),
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

    final String deadlineLine;
    if (useToday) {
      deadlineLine = 'Applies automatically at checkout today';
    } else if (daysLeft <= 0) {
      deadlineLine = 'Last day: today!';
    } else if (daysLeft == 1) {
      deadlineLine = 'Valid through tomorrow ($lastValidDate)';
    } else {
      deadlineLine = 'Valid through $lastValidDate ($daysLeft days left)';
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryOrange, width: 2),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isFree ? 'FREE' : '$percent%',
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryOrange,
                ),
              ),
              Text(
                isFree ? 'visit' : 'off',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFree
                      ? 'Free return visit'
                      : '$percent% off your next visit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  deadlineLine,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: daysLeft <= 1 && !useToday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: daysLeft <= 1 && !useToday
                        ? AppTheme.errorColor
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
