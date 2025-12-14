import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/features/user/presentation/providers/user_state_notifier.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import 'profile_edit_screen.dart';

/// Settings screen with simple list
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
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
          // Clear user state
          ref.read(userStateProvider.notifier).clear();
          // Navigate to phone input screen
          const PhoneInputRoute().go(context);
        },
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: const Text(
          'Settings',
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Profile
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ProfileEditScreen(),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.person,
                      color: AppTheme.accentPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_forward, color: AppTheme.textSecondary, size: 20),
                  ],
                ),
              ),
            ),

            Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 16), color: CupertinoColors.separator),

            // Contact
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _launchURL('mailto:support@mangalounge.com'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.mail,
                      color: AppTheme.accentPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Contact',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_forward, color: AppTheme.textSecondary, size: 20),
                  ],
                ),
              ),
            ),

            Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 16), color: CupertinoColors.separator),

            // Privacy Policy
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _launchURL('https://mangalounge.com/privacy'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      color: AppTheme.accentPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_forward, color: AppTheme.textSecondary, size: 20),
                  ],
                ),
              ),
            ),

            Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 16), color: CupertinoColors.separator),

            // Terms & Conditions
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _launchURL('https://mangalounge.com/terms'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      color: AppTheme.accentPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Icon(CupertinoIcons.chevron_forward, color: AppTheme.textSecondary, size: 20),
                  ],
                ),
              ),
            ),

            Container(height: 0.5, margin: const EdgeInsets.symmetric(horizontal: 16), color: CupertinoColors.separator),

            const SizedBox(height: 32),

            // Sign Out Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CupertinoButton(
                onPressed: () => _handleSignOut(context, ref),
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.errorColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
