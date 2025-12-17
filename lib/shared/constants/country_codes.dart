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
///
/// Note: Order matters for country detection - longer dial codes should come first
/// to avoid partial matches (e.g., +81 before +8)
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

/// Result of parsing a phone number
class ParsedPhoneNumber {
  final CountryCode? country;
  final String localNumber;

  const ParsedPhoneNumber({this.country, required this.localNumber});
}

/// Parses a phone number string and extracts country code and local number
///
/// Handles various formats:
/// - "+81 80-1234-5678" -> Japan, "8012345678"
/// - "+1 (555) 123-4567" -> US, "5551234567"
/// - "08012345678" -> null country, "08012345678"
/// - "5551234567" -> null country, "5551234567"
ParsedPhoneNumber parsePhoneNumber(String input) {
  // Remove all non-digit characters except leading +
  final cleaned = input.trim();
  final hasPlus = cleaned.startsWith('+');
  final digits = cleaned.replaceAll(RegExp(r'\D'), '');

  if (!hasPlus || digits.isEmpty) {
    // No country code detected, return digits only
    return ParsedPhoneNumber(localNumber: digits);
  }

  // Sort by dial code length (descending) to match longer codes first
  final sortedCountries = List<CountryCode>.from(availableCountryCodes)
    ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));

  for (final country in sortedCountries) {
    final dialDigits = country.dialCode.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith(dialDigits)) {
      final localNumber = digits.substring(dialDigits.length);
      return ParsedPhoneNumber(country: country, localNumber: localNumber);
    }
  }

  // No matching country found
  return ParsedPhoneNumber(localNumber: digits);
}
