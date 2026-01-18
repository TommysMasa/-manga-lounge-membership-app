import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../../../shared/theme/app_theme.dart';

/// Screen for changing email address for authenticated users
///
/// Flow:
/// 1. User enters new email address
/// 2. Firebase Auth sends verification email to new address (verifyBeforeUpdateEmail)
/// 3. User clicks link in email to confirm
/// 4. Firestore user document is updated
/// 5. Navigate back to profile
class ChangeEmailAddressScreen extends ConsumerStatefulWidget {
  const ChangeEmailAddressScreen({super.key});

  @override
  ConsumerState<ChangeEmailAddressScreen> createState() =>
      _ChangeEmailAddressScreenState();
}

class _ChangeEmailAddressScreenState
    extends ConsumerState<ChangeEmailAddressScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isValid = false;
  bool _isLoading = false;
  String _currentEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentEmail();
  }

  /// Fetch current email from cached Firebase Auth user data
  void _fetchCurrentEmail() {
    final authRepo = ref.read(authRepositoryProvider);
    setState(() {
      _currentEmail = authRepo.getCurrentUserEmail() ?? 'No email';
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onEmailChanged(String value) {
    setState(() {
      // Simple email validation
      _isValid = _isValidEmail(value);
    });
  }

  bool _isValidEmail(String email) {
    // Basic email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _updateEmail() async {
    if (!_isValid || _emailController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Send verification email to new address
      final authUpdateResult = await authRepo.updateEmail(
        newEmail: _emailController.text,
      );

      if (!mounted) return;

      final authUpdateError = authUpdateResult.fold((l) => l, (r) => null);
      if (authUpdateError != null) {
        setState(() {
          _isLoading = false;
        });

        // Check if error is requires-recent-login
        if (authUpdateError is ReauthenticationRequiredFailure) {
          // Start reauthentication flow
          await _startReauthenticationFlow();
          return;
        }

        AppTheme.showNotification(
          context,
          message: authUpdateError.message,
          isError: true,
        );
        return;
      }

      // Success!
      setState(() {
        _isLoading = false;
      });
      await AppTheme.showNotification(
        context,
        message: 'Verification email sent to ${_emailController.text}. Please check your inbox and click the link to confirm. Your email will be updated after confirmation.',
      );
      // Go back to previous screen
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      AppTheme.showNotification(
        context,
        message: 'Unexpected error: ${e.toString()}',
        isError: true,
      );
    }
  }

  Future<void> _startReauthenticationFlow() async {
    // Show confirmation dialog
    final wantsToReauth = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Verification Required'),
        content: const Text(
          'For security, we need to verify your phone number before changing your email.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    if (wantsToReauth != true) return;

    // Send OTP to current phone number
    final authRepo = ref.read(authRepositoryProvider);
    final phoneNumber = authRepo.getCurrentUserPhoneNumber();

    if (phoneNumber == null) {
      if (!mounted) return;
      AppTheme.showNotification(
        context,
        message: 'No phone number found. Please contact support.',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final otpResult = await authRepo.sendOTP(phoneNumber);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final otpError = otpResult.fold((l) => l, (r) => null);
    if (otpError != null) {
      AppTheme.showNotification(
        context,
        message: 'Failed to send verification code: ${otpError.message}',
        isError: true,
      );
      return;
    }

    final verificationId = otpResult.fold((l) => '', (r) => r);
    if (verificationId.isEmpty) return;

    // Show OTP input dialog
    _showOTPDialog(verificationId, phoneNumber);
  }

  Future<void> _showOTPDialog(String verificationId, String phoneNumber) async {
    final otpController = TextEditingController();

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Enter Verification Code'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'A 6-digit code has been sent to $phoneNumber',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Container(
                constraints: const BoxConstraints(maxWidth: 200),
                child: CupertinoTextField(
                  controller: otpController,
                  placeholder: '000000',
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Verify'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      otpController.dispose();
      return;
    }

    final otpCode = otpController.text.trim();
    otpController.dispose();

    if (otpCode.length != 6) {
      if (!mounted) return;
      AppTheme.showNotification(
        context,
        message: 'Please enter a valid 6-digit code',
        isError: true,
      );
      return;
    }

    // Reauthenticate with OTP
    await _reauthenticate(verificationId, otpCode);
  }

  Future<void> _reauthenticate(String verificationId, String otpCode) async {
    setState(() {
      _isLoading = true;
    });

    final authRepo = ref.read(authRepositoryProvider);
    final reauthResult = await authRepo.reauthenticateWithPhoneNumber(
      verificationId: verificationId,
      otpCode: otpCode,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    final reauthError = reauthResult.fold((l) => l, (r) => null);
    if (reauthError != null) {
      AppTheme.showNotification(
        context,
        message: 'Verification failed: ${reauthError.message}',
        isError: true,
      );
      return;
    }

    // Reauthentication successful, retry email update
    await AppTheme.showNotification(
      context,
      message: 'Verification successful! Updating email...',
    );

    // Retry email update
    await _updateEmail();
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
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppTheme.primaryBlue),
        ),
        middle: const Text(
          'Change Email Address',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Current email display
              const Text(
                'Current Email',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentEmail,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Note about email update display
              const Text(
                'Note: After changing your email address, the old address may still be displayed on this screen. If this happens, please log out and log back in to see the update.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Instruction text
              const Text(
                'Enter your new email address. A verification link will be sent to confirm the change.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Email input
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Enter new email address',
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
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

              const SizedBox(height: 24),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: _isValid && !_isLoading ? _updateEmail : null,
                  color: _isValid && !_isLoading
                      ? AppTheme.primaryBlue
                      : CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : const Text(
                          'Update Email Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
