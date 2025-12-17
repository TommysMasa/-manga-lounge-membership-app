import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/models/country_code.dart';
import '../../../../shared/constants/country_codes.dart';
import 'phone_input_state.dart';

part 'phone_input_notifier.g.dart';

/// Notifier for phone number input
///
/// Handles:
/// - Phone number formatting per country
/// - Country selection
/// - Autofill detection and processing
/// - Validation
@riverpod
class PhoneInputNotifier extends _$PhoneInputNotifier {
  @override
  PhoneInputState build() {
    return PhoneInputState(selectedCountry: defaultCountryCode);
  }

  /// Update phone number from user input
  ///
  /// Handles both manual input and autofill.
  /// If autofill is detected (contains +), parses and extracts country.
  void updatePhoneNumber(String value) {
    // Check for autofill (contains country code)
    if (value.contains('+')) {
      _processAutofill(value);
      return;
    }

    // Normal input - extract digits and format
    final digits = _extractDigits(value);
    final country = state.country;

    // Limit to expected phone length
    final limitedDigits = digits.length > country.phoneLength
        ? digits.substring(0, country.phoneLength)
        : digits;

    final formatted = country.format(limitedDigits);
    final isValid = country.isValid(formatted);

    state = state.copyWith(
      phoneNumber: formatted,
      digits: limitedDigits,
      isValid: isValid,
    );
  }

  /// Select a country
  ///
  /// Clears the phone number when country changes.
  void selectCountry(CountryCode country) {
    state = PhoneInputState(selectedCountry: country);
  }

  /// Clear phone number input
  void clear() {
    state = state.copyWith(
      phoneNumber: '',
      digits: '',
      isValid: false,
    );
  }

  /// Process autofilled phone number
  ///
  /// Detects country from dial code and extracts local number.
  void _processAutofill(String value) {
    final parsed = parsePhoneNumber(value);

    if (parsed.country != null) {
      // Country detected - update state with detected country and local number
      final formatted = parsed.country!.format(parsed.localNumber);
      final isValid = parsed.country!.isValid(formatted);

      state = state.copyWith(
        selectedCountry: parsed.country,
        phoneNumber: formatted,
        digits: parsed.localNumber,
        isValid: isValid,
      );
    } else {
      // No country detected - treat as normal input
      updatePhoneNumber(value);
    }
  }

  /// Extract digits from phone number string
  String _extractDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }
}
