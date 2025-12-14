import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:manga_lounge/core/models/country_code.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';
import 'package:manga_lounge/shared/constants/country_codes.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/auth_state.dart';

/// Screen for phone number input with country selection
///
/// Supports multiple countries via dropdown selector.
/// Country-specific formatting and validation handled by CountryCode model.
/// Auth redirect logic is handled by the router, not this screen.
class PhoneInputScreen extends HookConsumerWidget {
  const PhoneInputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hooks for local state management
    final phoneController = useTextEditingController();
    final selectedCountry = useState<CountryCode>(defaultCountryCode);
    final isValidPhone = useState(false);

    // Validate and send OTP
    Future<void> sendOTP() async {
      if (!isValidPhone.value) return;
      final phoneNumber = selectedCountry.value.toE164(phoneController.text);
      await ref.read(authStateProvider.notifier).sendOTPCode(phoneNumber);
      final failure = ref
          .read(authStateProvider)
          .maybeWhen(error: (message) => message, orElse: () => null);
      if (failure != null) {
        if (context.mounted) {
          AppTheme.showNotification(context, message: failure, isError: true);
        }
      }
    }

    // Watch auth state for UI updates
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    // Show country selection modal
    Future<void> showCountryPicker() async {
      final selected = await showCupertinoModalPopup<CountryCode>(
        context: context,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.5,
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                  itemCount: availableCountryCodes.length,
                  separatorBuilder: (context, index) => Container(
                    height: 0.5,
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                  itemBuilder: (context, index) {
                    final country = availableCountryCodes[index];
                    final isSelected = country == selectedCountry.value;
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
        ),
      );
      if (selected != null) {
        selectedCountry.value = selected;
        // Clear phone input when country changes
        phoneController.clear();
        isValidPhone.value = false;
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
                            selectedCountry.value.flagEmoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            selectedCountry.value.dialCode,
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
                    child: CupertinoTextField(
                      controller: phoneController,
                      placeholder: selectedCountry.value.formatHint,
                      placeholderStyle: TextStyle(
                        color: CupertinoColors.placeholderText.color,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: CupertinoColors.systemGrey4),
                      ),
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(
                          selectedCountry.value.phoneLength,
                        ),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final formatted = selectedCountry.value.format(
                            newValue.text,
                          );
                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        isValidPhone.value = selectedCountry.value.isValid(
                          value,
                        );
                      },
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
                  children: const [
                    TextSpan(text: 'By continuing, you agree to our '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  onPressed: isLoading || !isValidPhone.value ? null : sendOTP,
                  color: isValidPhone.value
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
