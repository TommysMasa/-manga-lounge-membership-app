import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:manga_lounge/features/user/presentation/providers/user_state_notifier.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/launch_url.dart';
import '../../../subscription/domain/guest_pass_quota.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../../subscription/presentation/widgets/premium_widgets.dart';
import '../../../waitlist/presentation/widgets/waitlist_home_card.dart';
import 'qr_code_screen.dart';
import 'settings_screen.dart';

/// Home screen with quick access to main features
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final isPro = ref.watch(isProProvider);
    final guestPassQuota = ref.watch(guestPassQuotaProvider).value;
    final proCap = ref.watch(proCapProvider).value;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        leading: Image.asset(
          'assets/images/logo_Alphabet1.png',
          height: 32,
          fit: BoxFit.contain,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _handleSignOut(context, ref),
          child: Icon(
            CupertinoIcons.square_arrow_right,
            color: AppTheme.primaryOrange,
          ),
        ),
      ),
      child: userAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 48,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  error is Failure ? error.message : '$error',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'If you have not finished signing up, create your profile to continue.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  onPressed: () => const RegisterRoute().go(context),
                  child: const Text('Create Profile'),
                ),
                const SizedBox(height: 8),
                CupertinoButton(
                  onPressed: () => ref.invalidate(userStreamProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        // Scrolls only when the cards don't fit (small screens); on taller
        // screens the Spacer still pins the status row to the bottom.
        data: (user) => LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Welcome back,',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                if (isPro) const PremiumBadge(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.fullName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Live seat availability / waitlist state
                      const SizedBox(height: 16),
                      const WaitlistHomeCard(),

                      // Free guest passes (Pro only)
                      if (isPro && guestPassQuota != null) ...[
                        const SizedBox(height: 16),
                        _GuestPassQuotaCard(quota: guestPassQuota),
                      ],

                      const SizedBox(height: 16),

                      // Membership Card
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            CupertinoPageRoute(
                              builder: (context) => const QRCodeScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          decoration: BoxDecoration(
                            color: isPro
                                ? kPremiumCardBg
                                : AppTheme.primaryBlue,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  CupertinoIcons.qrcode,
                                  color: CupertinoColors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Membership',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isPro
                                            ? kPremiumGold
                                            : CupertinoColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Show your QR code',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isPro
                                            ? kPremiumGold.withValues(
                                                alpha: 0.9,
                                              )
                                            : CupertinoColors.white.withOpacity(
                                                0.9,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: CupertinoColors.white,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Settings and Manga Search Row
                      Row(
                        children: [
                          // Settings Card
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) =>
                                        const SettingsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isPro
                                      ? kPremiumCardBg
                                      : AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.settings,
                                        color: CupertinoColors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Settings',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isPro
                                            ? kPremiumGold
                                            : CupertinoColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Manage account',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isPro
                                            ? kPremiumGold.withValues(
                                                alpha: 0.9,
                                              )
                                            : CupertinoColors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Manga Search Card
                          Expanded(
                            child: GestureDetector(
                              onTap: () async {
                                try {
                                  await launchURL(
                                    'https://www.libib.com/u/mangaloungemo',
                                  );
                                } catch (e) {
                                  if (context.mounted) {
                                    AppTheme.showNotification(
                                      context,
                                      message: 'Could not open manga library',
                                      isError: true,
                                    );
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isPro
                                      ? kPremiumCardBg
                                      : AppTheme.primaryBlue,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        CupertinoIcons.book,
                                        color: CupertinoColors.white,
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Manga Search',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: isPro
                                            ? kPremiumGold
                                            : CupertinoColors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Browse library',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isPro
                                            ? kPremiumGold.withValues(
                                                alpha: 0.9,
                                              )
                                            : CupertinoColors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Upgrade to Pro banner (hidden for Pro members)
                      if (!isPro) ...[
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) =>
                                    const SubscriptionScreen(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: CupertinoColors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: kProGold.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    CupertinoIcons.star_fill,
                                    color: kProGoldDark,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        proCap != null && proCap.isFull
                                            ? 'Pro membership is full'
                                            : 'Upgrade to Pro',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      if (proCap != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          proCap.isFull
                                              ? 'Limited to ${proCap.limit} members'
                                              : '${proCap.remaining} of ${proCap.limit} spots left',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(
                                  CupertinoIcons.chevron_forward,
                                  color: AppTheme.textSecondary,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Status Row — fixed value-line height so Checked In/Out
                      // never changes card size vs Entry Time.
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.person_2,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Status',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 22,
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          user.isCheckedIn
                                              ? 'Checked In'
                                              : 'Checked Out',
                                          maxLines: 1,
                                          softWrap: false,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      CupertinoIcons.time,
                                      color: AppTheme.textSecondary,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Entry Time',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      height: 22,
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          user.activeEntryTime?.toHHmm() ?? '-',
                                          maxLines: 1,
                                          softWrap: false,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await AppTheme.showConfirmation(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      isDestructive: true,
    );

    if (confirm == true && context.mounted) {
      final signOutUseCase = ref.read(signOutProvider);
      final result = await signOutUseCase();

      result.fold(
        (failure) {
          AppTheme.showNotification(
            context,
            message: failure.message,
            isError: true,
          );
        },
        (_) {
          // Clear user state notifier (still used by other screens)
          ref.read(userStateProvider.notifier).clear();
          const SplashRoute().go(context);
        },
      );
    }
  }
}

/// Pro home row: remaining free guest passes and when the allotment renews.
class _GuestPassQuotaCard extends StatelessWidget {
  const _GuestPassQuotaCard({required this.quota});

  final GuestPassQuota quota;

  @override
  Widget build(BuildContext context) {
    final renewLabel = DateFormat('MMM d').format(quota.renewsAt);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kProGold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              CupertinoIcons.person_2_fill,
              color: kProGoldDark,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Free guest passes '),
                      TextSpan(
                        text: '${quota.remaining}/${quota.total}',
                        style: const TextStyle(color: kProGoldDark),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Renews $renewLabel',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
}
