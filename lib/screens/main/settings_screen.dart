import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_edit_screen.dart';

/// Settings screen with simple list
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Profile
          ListTile(
            leading: Icon(
              Icons.person_outline,
              color: AppTheme.accentPurple,
              size: 28,
            ),
            title: const Text(
              'Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileEditScreen(),
                ),
              );
            },
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Contact
          ListTile(
            leading: Icon(
              Icons.mail_outline,
              color: AppTheme.accentPurple,
              size: 28,
            ),
            title: const Text(
              'Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () {
              _launchURL('mailto:support@mangalounge.com');
            },
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Privacy Policy
          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: AppTheme.accentPurple,
              size: 28,
            ),
            title: const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () {
              _launchURL('https://mangalounge.com/privacy');
            },
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          // Terms & Conditions
          ListTile(
            leading: Icon(
              Icons.description_outlined,
              color: AppTheme.accentPurple,
              size: 28,
            ),
            title: const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
            onTap: () {
              _launchURL('https://mangalounge.com/terms');
            },
          ),

          Divider(height: 1, color: Colors.grey.shade200),

          const SizedBox(height: 32),

          // Sign Out Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: OutlinedButton(
              onPressed: () async {
                // Show confirmation dialog
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                        ),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/phone-input',
                      (route) => false,
                    );
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
