import 'package:manga_lounge/core/models/country_code.dart';

/// List of supported country codes for phone number input
///
/// This list defines all countries that users can select when entering
/// their phone number. Each country has specific formatting and validation rules.
///
/// To add a new country:
/// 1. Add a new CountryCode entry to this list
/// 2. Update phone_formatter.dart with country-specific formatting logic
/// 3. Add tests for the new country
const List<CountryCode> availableCountryCodes = [
  // United States
  CountryCode(
    name: 'United States',
    isoCode: 'US',
    dialCode: '+1',
    flagEmoji: '🇺🇸',
    phoneLength: 10,
    formatHint: '(555) 123-4567',
  ),

  // Japan
  CountryCode(
    name: 'Japan',
    isoCode: 'JP',
    dialCode: '+81',
    flagEmoji: '🇯🇵',
    phoneLength: 10, // Mobile numbers are typically 10 digits (e.g., 80-1234-5678)
    formatHint: '80-1234-5678',
  ),
];

/// Default country code (first in the list)
final CountryCode defaultCountryCode = availableCountryCodes.first;
