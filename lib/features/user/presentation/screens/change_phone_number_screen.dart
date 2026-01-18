import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Colors, Material, InputDecoration, InputBorder;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';

/// Screen for changing phone number for authenticated users
///
/// Flow:
/// 1. User enters new phone number
/// 2. SMS verification code is sent
/// 3. User enters OTP code
/// 4. Firebase Auth phone number is updated
/// 5. Firestore user document is updated
/// 6. Navigate back to profile
class ChangePhoneNumberScreen extends ConsumerStatefulWidget {
  const ChangePhoneNumberScreen({super.key});

  @override
  ConsumerState<ChangePhoneNumberScreen> createState() =>
      _ChangePhoneNumberScreenState();
}

class _ChangePhoneNumberScreenState
    extends ConsumerState<ChangePhoneNumberScreen> {
  PhoneNumber? _phoneNumber;
  bool _isValid = false;
  bool _isLoading = false;
  String _currentPhoneNumber = '';

  // OTP verification state
  String? _verificationId;
  bool _isOTPSent = false;
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentPhoneNumber();
  }

  /// Fetch current phone number from Firebase Auth
  /// Note: No reload() needed because updatePhoneNumber() updates immediately
  void _fetchCurrentPhoneNumber() {
    final authRepo = ref.read(authRepositoryProvider);
    setState(() {
      _currentPhoneNumber = authRepo.getCurrentUserPhoneNumber() ?? 'No phone number';
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onPhoneChanged(PhoneNumber? value) {
    setState(() {
      _phoneNumber = value;
      _isValid = value?.isValid() ?? false;
    });
  }

  Future<void> _sendOTP() async {
    if (!_isValid || _phoneNumber == null) return;

    setState(() {
      _isLoading = true;
    });

    final completeNumber = _phoneNumber!.international;
    final authRepo = ref.read(authRepositoryProvider);

    final result = await authRepo.sendOTP(completeNumber);

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
        });
        AppTheme.showNotification(
          context,
          message: failure.message,
          isError: true,
        );
      },
      (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isOTPSent = true;
          _isLoading = false;
        });
        AppTheme.showNotification(
          context,
          message: 'Verification code sent to ${_phoneNumber!.international}',
        );
      },
    );
  }

  Future<void> _verifyAndUpdatePhoneNumber() async {
    print('DEBUG: _verifyAndUpdatePhoneNumber called');
    if (_verificationId == null || _otpController.text.length != 6) {
      print('DEBUG: Early return');
      return;
    }

    print('DEBUG: Setting loading');
    setState(() {
      _isLoading = true;
    });

    try {
      final authRepo = ref.read(authRepositoryProvider);
      print('DEBUG: Got auth repo');

      print('DEBUG: Step 1 - updatePhoneNumber');
      // Step 1: Update Firebase Auth phone number
      final authResult = await authRepo.updatePhoneNumber(
        verificationId: _verificationId!,
        otpCode: _otpController.text,
      );
      print('DEBUG: Auth update completed');

      if (!mounted) {
        print('DEBUG: Not mounted after auth');
        return;
      }

      // Check auth update result
      final authError = authResult.fold((l) => l, (r) => null);
      if (authError != null) {
        print('DEBUG: Auth error: ${authError.message}');
        setState(() {
          _isLoading = false;
        });
        AppTheme.showNotification(
          context,
          message: authError.message,
          isError: true,
        );
        return;
      }
      print('DEBUG: Auth success');

      // Note: We no longer store phone numbers in Firestore.
      // Phone numbers are managed solely by Firebase Auth.
      // The update is already complete from Step 1.

      // Success!
      print('DEBUG: SUCCESS!');
      setState(() {
        _isLoading = false;
      });
      print('DEBUG: Showing notification');
      await AppTheme.showNotification(
        context,
        message: 'Phone number updated successfully',
      );
      print('DEBUG: Going back');
      // Go back to previous screen
      if (mounted) {
        Navigator.of(context).pop();
      }
      print('DEBUG: After going back');
    } catch (e) {
      print('DEBUG: Exception caught: $e');
      if (!mounted) {
        print('DEBUG: Not mounted in catch');
        return;
      }
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
          'Change Phone Number',
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

              // Current phone number display
              const Text(
                'Current Phone Number',
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
                  _currentPhoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Instruction text
              Text(
                _isOTPSent
                    ? 'Enter the verification code sent to ${_phoneNumber?.international}'
                    : 'Enter your new phone number',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Phone number input or OTP input
              if (!_isOTPSent) ...[
                // Phone number input
                Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: PhoneFormField(
                      controller: PhoneController(),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter phone number',
                        hintStyle: TextStyle(color: CupertinoColors.placeholderText),
                      ),
                      enabled: !_isLoading,
                      onChanged: _onPhoneChanged,
                      autofocus: true,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Send OTP Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _isValid && !_isLoading ? _sendOTP : null,
                    color: _isValid && !_isLoading
                        ? AppTheme.primaryBlue
                        : CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(30),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white)
                        : const Text(
                            'Send Verification Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),
              ] else ...[
                // OTP input
                CupertinoTextField(
                  controller: _otpController,
                  placeholder: 'Enter 6-digit code',
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  enabled: !_isLoading,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  onChanged: (value) {
                    if (value.length == 6) {
                      _verifyAndUpdatePhoneNumber();
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    onPressed: _otpController.text.length == 6 && !_isLoading
                        ? _verifyAndUpdatePhoneNumber
                        : null,
                    color: _otpController.text.length == 6 && !_isLoading
                        ? AppTheme.primaryBlue
                        : CupertinoColors.systemGrey3,
                    borderRadius: BorderRadius.circular(30),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _isLoading
                        ? const CupertinoActivityIndicator(
                            color: CupertinoColors.white)
                        : const Text(
                            'Verify & Update',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: CupertinoColors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Resend code button
                CupertinoButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() {
                            _isOTPSent = false;
                            _verificationId = null;
                            _otpController.clear();
                          });
                        },
                  child: const Text('Use different number'),
                ),
              ],

              const SizedBox(height: 32),

              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure you have access to your new phone number to receive the verification code.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlue,
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
    );
  }
}
