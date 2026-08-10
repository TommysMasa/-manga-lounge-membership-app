import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:manga_lounge/features/user/presentation/providers/user_state_notifier.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/home_decorations.dart';
import '../../../subscription/domain/guest_pass_quota.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../subscription/presentation/screens/subscription_screen.dart';
import '../../../coupons/presentation/widgets/coupons_home_card.dart';
import '../../../subscription/presentation/widgets/premium_widgets.dart';
import '../../../waitlist/presentation/widgets/waitlist_home_card.dart';
import 'qr_code_screen.dart';

/// Home screen with quick access to main features
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final isPro = ref.watch(isProProvider);
    final guestPassQuota = ref.watch(guestPassQuotaProvider).value;

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
        data: (user) => Stack(
          children: [
            LayoutBuilder(
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
                        // Vertically centered so the cards do not cling to
                        // the top of the screen
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Coupon: the one thing we most want seen
                          // (renders nothing when there is no coupon)
                          const CouponsHomeCard(),

                          // Member card: welcome + membership QR in one
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => const QRCodeScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isPro
                                    ? kPremiumCardBg
                                    : AppTheme.primaryBlue,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    if (!isPro)
                                      const Positioned.fill(
                                        child: CustomPaint(
                                          painter: MembershipBlobsPainter(),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Welcome back,',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: isPro
                                                            ? kPremiumGold
                                                                  .withValues(
                                                                    alpha: 0.9,
                                                                  )
                                                            : const Color(
                                                                0xFFC9D6EA,
                                                              ),
                                                      ),
                                                    ),
                                                    Text(
                                                      user.fullName,
                                                      style: TextStyle(
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: isPro
                                                            ? kPremiumGold
                                                            : CupertinoColors
                                                                  .white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isPro)
                                                const PremiumBadge(),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: CupertinoColors.white
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 44,
                                                  height: 44,
                                                  decoration: BoxDecoration(
                                                    color: isPro
                                                        ? CupertinoColors.white
                                                              .withValues(
                                                                alpha: 0.2,
                                                              )
                                                        : CupertinoColors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    CupertinoIcons.qrcode,
                                                    color: isPro
                                                        ? CupertinoColors.white
                                                        : AppTheme.primaryBlue,
                                                    size: 28,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Membership',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: isPro
                                                              ? kPremiumGold
                                                              : CupertinoColors
                                                                    .white,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        'Show your QR code',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: isPro
                                                              ? kPremiumGold
                                                                    .withValues(
                                                                      alpha:
                                                                          0.85,
                                                                    )
                                                              : const Color(
                                                                  0xFFC9D6EA,
                                                                ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const Icon(
                                                  CupertinoIcons
                                                      .chevron_forward,
                                                  color: CupertinoColors.white,
                                                  size: 18,
                                                ),
                                              ],
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

                          // Free guest passes (Pro only)
                          if (isPro && guestPassQuota != null) ...[
                            const SizedBox(height: 16),
                            _GuestPassQuotaCard(quota: guestPassQuota),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Floating seat/waitlist button, chatbot style
            const Positioned(left: 20, bottom: 16, child: WaitlistHomeCard()),
          ],
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
