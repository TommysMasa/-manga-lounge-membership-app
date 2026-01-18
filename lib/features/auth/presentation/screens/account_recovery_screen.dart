import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';

/// Screen for account recovery when user lost access to phone number
///
/// Flow:
/// 1. User enters their registered email address
/// 2. System sends magic link to that email
/// 3. User clicks link to login
/// 4. User can then update their phone number in settings
class AccountRecoveryScreen extends ConsumerStatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  ConsumerState<AccountRecoveryScreen> createState() =>
      _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends ConsumerState<AccountRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      _isValid = _isValidEmail(value);
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _sendRecoveryLink() async {
    if (!_isValid || _emailController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final authRepo = ref.read(authRepositoryProvider);

      // Store email in SharedPreferences for later retrieval
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emailForSignIn', email);

      // Send magic link to email
      final result = await authRepo.sendSignInLinkToEmail(
        email: email,
        continueUrl: 'https://simpleapp-5c1c6.firebaseapp.com/auth/callback/',
      );

      if (!mounted) return;

      final error = result.fold((l) => l, (r) => null);
      if (error != null) {
        setState(() => _isLoading = false);
        AppTheme.showNotification(
          context,
          message: error.message,
          isError: true,
        );
        return;
      }

      // Success - navigate to email sent screen
      setState(() => _isLoading = false);
      Navigator.of(context).push(
        CupertinoPageRoute(
          builder: (context) => _EmailSentScreen(email: email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      AppTheme.showNotification(
        context,
        message: 'Failed to send recovery link: ${e.toString()}',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        ),
        middle: const Text(
          'Account Recovery',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      child: Material(
        color: AppTheme.backgroundColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              const SizedBox(height: 48),

              // Title
              const Text(
                'Lost access to your phone number?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              const Text(
                'Enter your registered email address and we\'ll send you a login link.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Email input
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Enter your email address',
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CupertinoColors.systemGrey4,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                prefix: const Padding(
                  padding: EdgeInsets.only(left: 16.0),
                  child: Icon(
                    CupertinoIcons.mail,
                    color: AppTheme.textSecondary,
                  ),
                ),
                onChanged: _onEmailChanged,
              ),

              const Spacer(),

              // Send button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _isValid && !_isLoading ? _sendRecoveryLink : null,
                  color: _isValid && !_isLoading
                      ? AppTheme.primaryBlue
                      : CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : const Text(
                          'Send Recovery Link',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Email sent confirmation screen
class _EmailSentScreen extends StatelessWidget {
  final String email;

  const _EmailSentScreen({required this.email});

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    final visibleChars = username.substring(0, 1);
    return '$visibleChars***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Go back to phone input screen (pop twice)
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Success icon
              const Icon(
                CupertinoIcons.mail_solid,
                size: 80,
                color: AppTheme.primaryBlue,
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Check your email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'We\'ve sent a login link to\n${_maskEmail(email)}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What to do next:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Open your email inbox\n'
                      '2. Click the login link in the email\n'
                      '3. Update your phone number in settings',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Done button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: () {
                    // Go back to phone input screen (pop twice)
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
