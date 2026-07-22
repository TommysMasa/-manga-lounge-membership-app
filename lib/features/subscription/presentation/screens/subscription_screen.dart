import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../config/push_notification_config.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/launch_url.dart';
import '../providers/subscription_providers.dart';

/// Gold accent used for the Pro branding
const Color kProGold = Color(0xFFE6A817);
const Color kProGoldDark = Color(0xFFB8860B);

/// Soft blue-gray background for this screen
const Color _kScreenBg = Color(0xFFF0F3F7);

/// Subscription paywall screen
///
/// Shows the monthly plan fetched from RevenueCat with the Pro benefits,
/// and lets the user subscribe or restore a previous purchase.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen>
    with WidgetsBindingObserver {
  bool _isPurchasing = false;

  /// Null while the notification permission state is being loaded.
  bool? _notificationsOn;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshNotificationState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Coming back from the Settings app: pick up the new permission state.
    if (state == AppLifecycleState.resumed) _refreshNotificationState();
  }

  Future<void> _refreshNotificationState() async {
    final granted = await PushNotificationConfig.isPermissionGranted();
    if (mounted) setState(() => _notificationsOn = granted);
  }

  /// Shows the OS permission dialog; if permission was permanently denied,
  /// sends the user to the app's notification settings instead.
  Future<void> _enableNotifications() async {
    final granted = await PushNotificationConfig.requestPermission();
    if (!mounted) return;
    setState(() => _notificationsOn = granted);
    if (granted) {
      AppTheme.showNotification(context, message: 'Notifications are on!');
    } else {
      // Already denied at the OS level: the dialog won't re-appear, so the
      // only way to enable is the Settings app.
      try {
        await launchURL('app-settings:');
      } catch (_) {
        if (mounted) {
          AppTheme.showNotification(
            context,
            message:
                'Please allow notifications for Manga Lounge '
                'in the Settings app.',
            isError: true,
          );
        }
      }
    }
  }

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
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) return;

      if (mounted) {
        // The purchase may have succeeded server-side even when the
        // response is lost, so don't claim failure on network issues.
        final isNetworkIssue =
            errorCode == PurchasesErrorCode.networkError ||
            errorCode == PurchasesErrorCode.offlineConnectionError ||
            errorCode == PurchasesErrorCode.apiEndpointBlocked ||
            errorCode == PurchasesErrorCode.unknownBackendError ||
            errorCode == PurchasesErrorCode.unknownError;
        AppTheme.showNotification(
          context,
          message: isNetworkIssue
              ? 'Connection issue. If your payment went through, Pro will '
                    'be activated automatically. Please restart the app in '
                    'a few minutes to check.'
              : 'Purchase failed: ${e.message}',
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
      backgroundColor: _kScreenBg,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: _kScreenBg,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
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
          const SizedBox(height: 24),

          // Benefits recap
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              'Your benefits',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          _buildBenefitsCard(),

          const SizedBox(height: 12),

          // Event info is delivered via push notifications, so nudge Pro
          // members to turn them on.
          _buildNotificationCard(),

          const SizedBox(height: 24),

          // Cancel subscription (opens Apple's subscription management)
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _openSubscriptionManagement,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                ),
              ),
              child: const Center(
                child: Text(
                  'Cancel Subscription',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Contact link for questions
          CupertinoButton(
            onPressed: () => launchURL('https://tally.so/r/0Qrdvj'),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.question_circle,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Have a question? Contact us',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Opens Apple's subscription management page, preferring the URL
  /// RevenueCat provides for the current customer.
  Future<void> _openSubscriptionManagement() async {
    final customerInfo = ref.read(customerInfoProvider).value;
    final url =
        customerInfo?.managementURL ??
        'https://apps.apple.com/account/subscriptions';
    try {
      await launchURL(url);
    } catch (_) {
      if (mounted) {
        AppTheme.showNotification(
          context,
          message: 'Could not open subscription settings.',
          isError: true,
        );
      }
    }
  }

  /// Card telling Pro members that event info arrives via notifications,
  /// with a button to turn them on (hidden once granted).
  Widget _buildNotificationCard() {
    final on = _notificationsOn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kProGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              CupertinoIcons.bell_fill,
              color: kProGoldDark,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Event notifications',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  on == true
                      ? 'Notifications are on. Pre-sale info will '
                            'be sent to this device.'
                      : 'Turn on notifications so you don\'t miss '
                            'event pre-sale info.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (on == false) ...[
            const SizedBox(width: 8),
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: kProGold,
              borderRadius: BorderRadius.circular(20),
              onPressed: _enableNotifications,
              child: const Text(
                'Turn On',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ] else if (on == true) ...[
            const SizedBox(width: 8),
            const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: CupertinoColors.systemGreen,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
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
            subtitle:
                'Visit as often as you like, every day. '
                'Unlimited drinks are included as always. '
                'You still check in and out with your QR code '
                'on every visit, but no per-visit payment is '
                'needed anymore.',
          ),
          SizedBox(height: 16),
          _BenefitRow(
            icon: CupertinoIcons.person_2_fill,
            title: 'Free guest passes',
            subtitle:
                'Bring friends for free, 2 slots per month. '
                'Use them one at a time on separate visits, or '
                'bring two guests at once. Just let our staff '
                'know at the front desk when using a pass.',
          ),
          SizedBox(height: 16),
          _BenefitRow(
            icon: CupertinoIcons.ticket_fill,
            title: 'Event ticket pre-sale',
            subtitle:
                'Early access to event tickets. '
                'We share the ticket link with you one day '
                'before public sale starts. Event information is '
                'delivered through app notifications.',
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
                _buildBenefitsCard(),
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

                // Contact link for questions
                CupertinoButton(
                  onPressed: () => launchURL('https://tally.so/r/0Qrdvj'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.question_circle,
                        color: AppTheme.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Have a question? Contact us',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
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
                'least 24 hours before the end of the current period. '
                'By subscribing, you agree to receive event pre-sale '
                'information through app notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              // Apple requires links to the Terms of Use and Privacy Policy
              // on the subscription screen.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    onPressed: () =>
                        launchURL(AppConstants.termsAndConditionsUrl),
                    child: const Text(
                      'Terms of Use',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    onPressed: () => launchURL(AppConstants.privacyPolicyUrl),
                    child: const Text(
                      'Privacy Policy',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Benefit list row that expands on tap to reveal the detail text.
class _BenefitRow extends StatefulWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  State<_BenefitRow> createState() => _BenefitRowState();
}

class _BenefitRowState extends State<_BenefitRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: kProGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(widget.icon, color: kProGoldDark, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  CupertinoIcons.chevron_down,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(left: 58, top: 6, right: 24),
              child: Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
