import 'package:flutter/cupertino.dart';

import '../../../../shared/theme/app_theme.dart';
import 'change_email_address_screen.dart';
import 'change_phone_number_screen.dart';
import 'profile_edit_screen.dart';

/// Menu screen for editing profile information
///
/// Provides three options:
/// - Phone Number: Navigate to phone number change screen
/// - Email Address: Navigate to email address change screen
/// - Other Profile: Navigate to profile edit screen (name, etc.)
class EditProfileMenuScreen extends StatelessWidget {
  const EditProfileMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        border: null,
        middle: const Text(
          'Edit Profile',
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
            // Phone Number
            _buildMenuItem(
              context: context,
              icon: CupertinoIcons.phone,
              title: 'Phone Number',
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ChangePhoneNumberScreen(),
                  ),
                );
              },
            ),

            Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 60),
              color: CupertinoColors.separator,
            ),

            // Email Address
            _buildMenuItem(
              context: context,
              icon: CupertinoIcons.mail,
              title: 'Email Address',
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ChangeEmailAddressScreen(),
                  ),
                );
              },
            ),

            Container(
              height: 0.5,
              margin: const EdgeInsets.only(left: 60),
              color: CupertinoColors.separator,
            ),

            // Other Profile
            _buildMenuItem(
              context: context,
              icon: CupertinoIcons.person,
              title: 'Other Profile',
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (context) => const ProfileEditScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppTheme.accentPurple,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
