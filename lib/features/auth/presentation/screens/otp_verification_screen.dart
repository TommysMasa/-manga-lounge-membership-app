import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/auth_state.dart';

/// Screen for OTP verification
///
/// Migrated to use Riverpod and clean architecture.
/// Gets verificationId from authState (otpSent state).
class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  String _otpCode = '';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOTP(String verificationId) async {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit code'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    // Call the use case through StateNotifier
    await ref
        .read(authStateProvider.notifier)
        .verifyOTPCode(verificationId: verificationId, otpCode: _otpCode);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen(authStateProvider, (previous, next) {
      next.maybeWhen(
        initial: () {},
        authenticated: (uid) {
          const HomeRoute().go(context);
        },
        orElse: () {},
        error: (message) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        },
      );
    });

    // Watch auth state for UI updates
    final authState = ref.watch(authStateProvider);

    // Extract verification ID and phone number from state
    final verificationData = authState.maybeWhen(
      otpSent: (verificationId, phoneNumber) => (verificationId, phoneNumber),
      orElse: () => (null, null),
    );

    final verificationId = verificationData.$1;
    final phoneNumber = verificationData.$2 ?? '+11111111111';

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // If no verification ID, show error
    if (verificationId == null && !isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No verification ID found'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Title
              const Text(
                'Verify your number',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle with phone number
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Enter the code we\'ve sent by text to\n',
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Change number link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Change number',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Code label
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Code',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // PIN Code Field
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 56,
                  fieldWidth: 48,
                  activeFillColor: Colors.blue.shade50,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  activeColor: AppTheme.primaryBlue,
                  selectedColor: AppTheme.primaryBlue,
                  inactiveColor: Colors.grey.shade400,
                  borderWidth: 2,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (value) {
                  _otpCode = value;
                  if (verificationId != null) {
                    _verifyOTP(verificationId);
                  }
                },
                onChanged: (value) {
                  _otpCode = value;
                },
              ),

              const SizedBox(height: 24),

              // Timer and arrow button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'This code should arrive within 22s',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isLoading || _otpCode.length < 6
                          ? Colors.grey.shade300
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                      onPressed:
                          isLoading ||
                              _otpCode.length < 6 ||
                              verificationId == null
                          ? null
                          : () => _verifyOTP(verificationId),
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
}
