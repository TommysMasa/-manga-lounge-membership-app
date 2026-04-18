import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/core/error/result.dart';
import 'package:manga_lounge/core/router/app_routes.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:manga_lounge/shared/navigation.dart';
import 'package:manga_lounge/shared/utils/launch_url.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/auth_state.dart';
import 'account_recovery_screen.dart';

/// Screen for international phone number input
///
/// Supports all countries with iOS autofill using phone_form_field package.
/// Auth redirect logic is handled by the router, not this screen.
class PhoneInputScreen extends ConsumerStatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  ConsumerState<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends ConsumerState<PhoneInputScreen> {
  PhoneNumber? _phoneNumber;
  bool _isValid = false;

  void _onPhoneChanged(PhoneNumber? value) {
    setState(() {
      _phoneNumber = value;
      _isValid = value?.isValid() ?? false;
    });
  }

  // Send OTP handler
  Future<void> _sendOTP() async {
    if (!_isValid || _phoneNumber == null) return;

    // Get E.164 formatted number
    final completeNumber = _phoneNumber!.international;

    // Read all providers synchronously BEFORE the await
    final authNotifier = ref.read(authStateProvider.notifier);
    final nav = ref.read(navigationProvider);

    final res = await authNotifier.sendOTPCode(completeNumber);

    // Use rootContext from nav (read before await)
    final rootContext = nav.rootContext;
    if (res.isSuccess && rootContext.mounted) {
      OTPRoute().push(rootContext);
    }
    if (res.isFailure && rootContext.mounted) {
      AppTheme.showNotification(
        rootContext,
        message: res.failureOrNull?.message ?? '',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state for loading indicator
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            final nav = ref.read(navigationProvider);
            final rootContext = nav.rootContext;
            if (rootContext.mounted) {
              SplashRoute().go(rootContext);
            }
          },
          child: const Icon(CupertinoIcons.back),
        ),
        backgroundColor: CupertinoColors.white,
        border: null,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),

              // Title
              const Text(
                'My number is',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'We\'ll send a verification code to this number',
                style: TextStyle(fontSize: 16, color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Phone Number Input (International)
              Material(
                color: Colors.transparent,
                child: PhoneFormField(
                  autofillHints: const [AutofillHints.telephoneNumber],
                  initialValue: const PhoneNumber(isoCode: IsoCode.US, nsn: ''),
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: CupertinoColors.systemGrey4.color,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: CupertinoColors.systemGrey4.color,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryBlue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: CupertinoColors.systemGrey6.color,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _onPhoneChanged,
                ),
              ),

              const SizedBox(height: 32),

              // Terms and Conditions
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  children: [
                    const TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            launchURL('https://mangalounge.com/terms'),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            launchURL('https://mangalounge.com/privacy'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: isLoading || !_isValid ? null : _sendOTP,
                  color: _isValid
                      ? AppTheme.primaryBlue
                      : CupertinoColors.systemGrey3,
                  borderRadius: BorderRadius.circular(30),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Account recovery link
              Center(
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => const AccountRecoveryScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Lost access to your phone?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.primaryBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
