import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';

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
  // 6 controllers for 6 OTP digits
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  static const int _initialCountdown = 30;
  int _remainingSeconds = _initialCountdown;
  Timer? _timer;

  String get _otpCode => _controllers.map((c) => c.text).join();

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
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _resendCode(String phoneNumber) async {
    await ref.read(authStateProvider.notifier).sendOTPCode(phoneNumber);
    _startTimer();
  }

  Future<void> _verifyOTP(String verificationId) async {
    if (_otpCode.length != 6) {
      AppTheme.showNotification(
        context,
        message: 'Please enter a 6-digit code',
        isError: true,
      );
      return;
    }

    // Call the use case through StateNotifier
    await ref
        .read(authStateProvider.notifier)
        .verifyOTPCode(verificationId: verificationId, otpCode: _otpCode);
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      // Deleted digit, move to previous field
      _focusNodes[index - 1].requestFocus();
    }
    // Check if all fields are filled
    if (_otpCode.length == 6) {
      final authState = ref.read(authStateProvider);
      final verificationId = authState.maybeWhen(
        otpSent: (vId, _) => vId,
        orElse: () => null,
      );
      if (verificationId != null) {
        _verifyOTP(verificationId);
      }
    }
    setState(() {}); // Trigger rebuild to update button state
  }

  void _onKeyPressed(int index, KeyEvent event) {
    // Handle backspace to move to previous field
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
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
    final phoneNumber = verificationData.$2 ?? '+11111111111';

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
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

                // Custom OTP Input
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 48,
                      height: 56,
                      child: KeyboardListener(
                        focusNode: FocusNode(),
                        onKeyEvent: (event) => _onKeyPressed(index, event),
                        child: CupertinoTextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          autofocus: index == 0,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          keyboardType: TextInputType.number,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          maxLength: 1,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _controllers[index].text.isNotEmpty
                                ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                                : CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _focusNodes[index].hasFocus
                                  ? AppTheme.primaryBlue
                                  : CupertinoColors.systemGrey4,
                              width: _focusNodes[index].hasFocus ? 2 : 1,
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          onChanged: (value) => _onDigitChanged(index, value),
                        ),
                      ),
                    );
                  }),
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
                        color: isLoading || _otpCode.length < 6
                            ? CupertinoColors.systemGrey4
                            : CupertinoColors.systemGrey3,
                        shape: BoxShape.circle,
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed:
                            isLoading ||
                                _otpCode.length < 6 ||
                                verificationId == null
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
