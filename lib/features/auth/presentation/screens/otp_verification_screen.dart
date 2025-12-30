import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:pinput/pinput.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/auth_state.dart';

/// Screen for OTP verification
///
/// Uses pinput package for proper SMS autofill support.
/// Gets verificationId from authState (otpSent state).
class OTPVerificationScreen extends ConsumerStatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  ConsumerState<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends ConsumerState<OTPVerificationScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();

  static const int _initialCountdown = 30;
  int _remainingSeconds = _initialCountdown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _remainingSeconds = _initialCountdown;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _resendCode(String phoneNumber) async {
    await ref.read(authStateProvider.notifier).sendOTPCode(phoneNumber);
    _startTimer();
  }

  Future<void> _verifyOTP(String verificationId) async {
    final otpCode = _pinController.text;
    if (otpCode.length != 6) {
      AppTheme.showNotification(
        context,
        message: 'Please enter a 6-digit code',
        isError: true,
      );
      return;
    }

    await ref
        .read(authStateProvider.notifier)
        .verifyOTPCode(verificationId: verificationId, otpCode: otpCode);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state for error notifications
    // Navigation is handled by the router's redirect logic
    ref.listen(authStateProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          AppTheme.showNotification(context, message: message, isError: true);
        },
        orElse: () {},
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
    final phoneNumber = verificationData.$2;

    // If no verification data, redirect back (invalid state)
    if (verificationId == null || phoneNumber == null) {
      return const CupertinoPageScaffold(
        child: Center(
          child: CupertinoActivityIndicator(color: AppTheme.primaryBlue),
        ),
      );
    }

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: Material(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
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
                  child: CupertinoButton(
                    onPressed: () {
                      context.pop();
                    },
                    padding: EdgeInsets.zero,
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

                // OTP Input with Pinput - handles SMS autofill correctly
                Pinput(
                  length: 6,
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  autofocus: true,
                  autofillHints: const [AutofillHints.oneTimeCode],
                  keyboardType: TextInputType.number,
                  defaultPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryBlue, width: 2),
                    ),
                  ),
                  submittedPinTheme: PinTheme(
                    width: 48,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: CupertinoColors.systemGrey4,
                        width: 1,
                      ),
                    ),
                  ),
                  onCompleted: (pin) => _verifyOTP(verificationId),
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 24),

                // Timer and arrow button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_remainingSeconds > 0)
                      Text(
                        'This code should arrive within ${_remainingSeconds}s',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      )
                    else
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: isLoading
                            ? null
                            : () => _resendCode(phoneNumber),
                        child: const Text(
                          'Resend code',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isLoading || _pinController.text.length < 6
                            ? CupertinoColors.systemGrey4
                            : CupertinoColors.systemGrey3,
                        shape: BoxShape.circle,
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: isLoading || _pinController.text.length < 6
                            ? null
                            : () => _verifyOTP(verificationId),
                        child: isLoading
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : const Icon(
                                CupertinoIcons.arrow_right,
                                color: CupertinoColors.white,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
