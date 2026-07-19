import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/features/user/presentation/providers/user_state_notifier.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extensions/date_time_extensions.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/launch_url.dart';
import '../../../subscription/presentation/providers/subscription_providers.dart';
import '../../../subscription/presentation/widgets/premium_widgets.dart';
import 'qr_code_screen.dart';
import 'settings_screen.dart';

/// Home screen with quick access to main features
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider);
    final isPro = ref.watch(isProProvider);
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
        error: (error, _) => Center(
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
              const SizedBox(height: 16),
              CupertinoButton.filled(
                onPressed: () => ref.invalidate(userStreamProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
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

              const SizedBox(height: 40),

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
                    color: isPro ? kPremiumCardBg : AppTheme.primaryBlue,
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
                                    ? kPremiumGold.withValues(alpha: 0.9)
                                    : CupertinoColors.white.withOpacity(0.9),
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
                            builder: (context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isPro ? kPremiumCardBg : AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withValues(alpha: 0.2),
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
                                    ? kPremiumGold.withValues(alpha: 0.9)
                                    : CupertinoColors.white.withValues(alpha: 0.9),
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
                          await launchURL('https://www.libib.com/u/mangaloungemo');
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
                          color: isPro ? kPremiumCardBg : AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white.withValues(alpha: 0.2),
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
                                    ? kPremiumGold.withValues(alpha: 0.9)
                                    : CupertinoColors.white.withValues(alpha: 0.9),
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

              const Spacer(),

              // Status Row
              Row(
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
                          Icon(
                            CupertinoIcons.person_2,
                            color: AppTheme.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Status',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.isCheckedIn ? 'Checked In' : 'Checked Out',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
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
                          Icon(
                            CupertinoIcons.time,
                            color: AppTheme.textSecondary,
                            size: 32,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Entry Time',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.activeEntryTime?.toHHmm() ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
