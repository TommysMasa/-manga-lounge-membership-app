import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/core/error/result.dart';
import 'package:manga_lounge/core/models/country_code.dart';
import 'package:manga_lounge/core/router/app_routes.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:manga_lounge/features/auth/presentation/providers/phone_input_notifier.dart';
import 'package:manga_lounge/shared/constants/country_codes.dart';
import 'package:manga_lounge/shared/navigation.dart';
import 'package:manga_lounge/shared/utils/launch_url.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/auth_state.dart';

/// Screen for phone number input with country selection
///
/// Supports multiple countries via dropdown selector.
/// Country-specific formatting and validation handled by PhoneInputNotifier.
/// Auth redirect logic is handled by the router, not this screen.
class PhoneInputScreen extends ConsumerWidget {
  const PhoneInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch phone input state
    final phoneState = ref.watch(phoneInputProvider);
    final phoneNotifier = ref.read(phoneInputProvider.notifier);

    // Watch auth state for loading indicator
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // Send OTP handler
    Future<void> sendOTP() async {
      if (!phoneState.isValid) return;

      // Read all providers synchronously BEFORE the await
      final authNotifier = ref.read(authStateProvider.notifier);
      final nav = ref.read(navigationProvider);

      final res = await authNotifier.sendOTPCode(phoneState.e164PhoneNumber);

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

    // Show country selection modal
    Future<void> showCountryPicker() async {
      final selected = await showCupertinoModalPopup<CountryCode>(
        context: context,
        builder: (context) =>
            _CountrySelection(selectCountry: phoneState.selectedCountry),
      );
      if (selected != null) {
        phoneNotifier.selectCountry(selected);
      }
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.white,
      child: SafeArea(
        child: Padding(
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

              // Phone Number Input with Country Selector
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country selector dropdown
                  GestureDetector(
                    onTap: showCountryPicker,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGrey6,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CupertinoColors.systemGrey4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            phoneState.country.flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            phoneState.country.dialCode,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            CupertinoIcons.chevron_down,
                            color: AppTheme.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Phone number field
                  Expanded(
                    child: _PhoneTextField(
                      phoneNumber: phoneState.phoneNumber,
                      placeholder: phoneState.country.formatHint,
                      onChanged: phoneNotifier.updatePhoneNumber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Terms and Conditions
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                  children: [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () =>
                            launchURL('https://mangalounge.com/terms'),
                    ),
                    TextSpan(text: ' and '),

                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
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
                  onPressed: isLoading || !phoneState.isValid ? null : sendOTP,
                  color: phoneState.isValid
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
            ],
          ),
        ),
      ),
    );
  }
}

class _CountrySelection extends StatelessWidget {
  const _CountrySelection({required this.selectCountry});

  final CountryCode? selectCountry;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoColors.separator.resolveFrom(context),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Country',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
          // Country list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: availableCountryCodes.length,
              separatorBuilder: (context, index) => Container(
                height: 0.5,
                color: CupertinoColors.separator.resolveFrom(context),
              ),
              itemBuilder: (context, index) {
                final country = availableCountryCodes[index];
                final isSelected = country == selectCountry;
                return CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  onPressed: () => Navigator.pop(context, country),
                  child: Row(
                    children: [
                      Text(
                        country.flagEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          country.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textLight,
                          ),
                        ),
                      ),
                      Text(
                        country.dialCode,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppTheme.textLight,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Icon(
                          CupertinoIcons.checkmark,
                          color: AppTheme.primaryBlue,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Stateful text field for phone number input
///
/// Needed because CupertinoTextField requires a controller,
/// but we want to manage state in the notifier.
class _PhoneTextField extends StatefulWidget {
  const _PhoneTextField({
    required this.phoneNumber,
    required this.placeholder,
    required this.onChanged,
  });

  final String phoneNumber;
  final String placeholder;
  final void Function(String) onChanged;

  @override
  State<_PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<_PhoneTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void didUpdateWidget(_PhoneTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controller with external state (e.g., after autofill processing)
    if (widget.phoneNumber != _controller.text) {
      _controller.text = widget.phoneNumber;
      _controller.selection = TextSelection.collapsed(
        offset: widget.phoneNumber.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTextField(
      controller: _controller,
      placeholder: widget.placeholder,
      placeholderStyle: TextStyle(color: CupertinoColors.placeholderText.color),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemGrey4.color),
      ),
      keyboardType: TextInputType.phone,
      autofillHints: const [AutofillHints.telephoneNumber],
      onChanged: widget.onChanged,
    );
  }
}
