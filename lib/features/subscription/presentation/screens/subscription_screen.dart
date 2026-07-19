import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../shared/theme/app_theme.dart';
import '../providers/subscription_providers.dart';

/// Gold accent used for the Pro branding
const Color kProGold = Color(0xFFE6A817);
const Color kProGoldDark = Color(0xFFB8860B);

/// Subscription paywall screen
///
/// Shows the monthly plan fetched from RevenueCat with the Pro benefits,
/// and lets the user subscribe or restore a previous purchase.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isPurchasing = false;

  Future<void> _handlePurchase(Package package) async {
    setState(() => _isPurchasing = true);

    try {
      await Purchases.purchase(PurchaseParams.package(package));
      // customerInfoProvider updates automatically via the listener.
      if (mounted) {
        AppTheme.showNotification(
          context,
          message: 'Welcome to Manga Lounge Pro!',
        );
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      // User closing the payment sheet is not an error
      if (errorCode != PurchasesErrorCode.purchaseCancelledError && mounted) {
        AppTheme.showNotification(
          context,
          message: 'Purchase failed: ${e.message}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isPurchasing = true);

    try {
      await Purchases.restorePurchases();
      if (mounted) {
        AppTheme.showNotification(context, message: 'Purchases restored.');
      }
    } on PlatformException catch (e) {
      if (mounted) {
        AppTheme.showNotification(
          context,
          message: 'Restore failed: ${e.message}',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(isProProvider);
    final offerings = ref.watch(offeringsProvider);
    final package = ref.watch(monthlyPackageProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        middle: const Text(
          'Manga Lounge Pro',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        ),
      ),
      child: SafeArea(
        child: isPro
            ? _buildSubscribedView()
            : offerings.when(
                loading: () =>
                    const Center(child: CupertinoActivityIndicator()),
                error: (error, _) => _buildErrorView(),
                data: (_) => package == null
                    ? _buildErrorView()
                    : _buildPaywall(package),
              ),
      ),
    );
  }

  Widget _buildSubscribedView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kProGold, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kProGold, kProGoldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: CupertinoColors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'You are a Pro member',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'All Pro benefits are unlocked.\nThank you for supporting Manga Lounge!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Manage or cancel your subscription anytime\nin your App Store account settings.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 16),
          const Text(
            'Plans are currently unavailable.\nPlease try again later.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          CupertinoButton(
            onPressed: () => ref.invalidate(offeringsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaywall(Package package) {
    final product = package.storeProduct;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero
                Container(
                  width: 88,
                  height: 88,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kProGold, kProGoldDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.star_fill,
                    color: CupertinoColors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Become a Pro Member',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Get the most out of Manga Lounge\nwith a monthly membership.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),

                // Benefits
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      _BenefitRow(
                        icon: CupertinoIcons.house_fill,
                        title: 'Unlimited lounge access',
                        subtitle: 'Visit as often as you like, every day',
                      ),
                      SizedBox(height: 16),
                      _BenefitRow(
                        icon: CupertinoIcons.book_fill,
                        title: 'Full manga library',
                        subtitle: 'Read everything in our collection',
                      ),
                      SizedBox(height: 16),
                      _BenefitRow(
                        icon: CupertinoIcons.star_lefthalf_fill,
                        title: 'Pro member card',
                        subtitle: 'Exclusive Pro badge on your QR card',
                      ),
                      SizedBox(height: 16),
                      _BenefitRow(
                        icon: CupertinoIcons.gift_fill,
                        title: 'Member perks',
                        subtitle: 'Discounts and member-only events',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Price card
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kProGold, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Plan',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Auto-renews monthly. Cancel anytime.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        product.priceString,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        '/mo',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // Bottom CTA area
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CupertinoButton(
                onPressed: _isPurchasing
                    ? null
                    : () => _handlePurchase(package),
                color: kProGold,
                borderRadius: BorderRadius.circular(30),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _isPurchasing
                    ? const CupertinoActivityIndicator(
                        color: CupertinoColors.white,
                      )
                    : Text(
                        'Subscribe for ${product.priceString}/month',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: CupertinoColors.white,
                        ),
                      ),
              ),
              CupertinoButton(
                onPressed: _isPurchasing ? null : _handleRestore,
                child: const Text(
                  'Restore Purchases',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              const Text(
                'Payment will be charged to your Apple ID account. '
                'The subscription renews automatically unless cancelled at '
                'least 24 hours before the end of the current period.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: kProGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: kProGoldDark, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
      ],
    );
  }
}
