import 'package:flutter/material.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    }

    // Watch auth state for UI updates
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

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
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Phone Number Input with Country Selector
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Country selector dropdown
                  GestureDetector(
                    onTap: () async {
                      // Show bottom sheet with country selection
                      final selected = await showModalBottomSheet<CountryCode>(
                        context: context,
                        builder: (context) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Header
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                                child: Text(
                                  'Select Country',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const Divider(),
                              // Country list
                              ...availableCountryCodes.map((country) {
                                final isSelected =
                                    country == selectedCountry.value;
                                return ListTile(
                                  leading: Text(
                                    country.flagEmoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                  title: Text(country.name),
                                  trailing: Text(
                                    country.dialCode,
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  selected: isSelected,
                                  selectedTileColor: AppTheme.primaryBlue
                                      .withValues(alpha: 0.1),
                                  onTap: () => Navigator.pop(context, country),
                                );
                              }),
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
                    },
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            selectedCountry.value.flagEmoji,
                            style: const TextStyle(fontSize: 24),
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
                            Icons.arrow_drop_down,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Phone number field
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        hintText: selectedCountry.value.formatHint,
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppTheme.primaryBlue,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
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
              ElevatedButton(
                onPressed: isLoading || !isValidPhone.value ? null : sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLoading
                      ? Colors.grey.shade300
                      : isValidPhone.value
                      ? AppTheme.primaryBlue
                      : Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
