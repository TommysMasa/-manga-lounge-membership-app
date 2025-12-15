import 'package:freezed_annotation/freezed_annotation.dart';

part 'country_code.freezed.dart';

/// Represents a country code configuration for phone number input
///
/// Contains all necessary information for formatting and validating
/// phone numbers for a specific country.
@freezed
abstract class CountryCode with _$CountryCode {
  const factory CountryCode({
    /// Country name (e.g., "United States", "Japan")
    required String name,

    /// ISO country code (e.g., "US", "JP")
    required String isoCode,

    /// International dialing code (e.g., "+1", "+81")
    required String dialCode,

    /// Country flag emoji (e.g., "🇺🇸", "🇯🇵")
    required String flagEmoji,

    /// Expected phone number length (excluding country code)
    /// For countries with variable length, use the most common length
    required int phoneLength,

    /// Hint text showing the expected format
    /// e.g., "(555) 123-4567" for US, "80-1234-5678" for Japan
    required String formatHint,
  }) = _CountryCode;

  const CountryCode._();

  /// Display text for the country selector
  /// Shows flag emoji and dial code, e.g., "🇺🇸 +1"
  String get displayText => '$flagEmoji $dialCode';

  // =========================================================================
  // Phone Number Formatting & Validation Methods
  // =========================================================================

  /// Formats a phone number according to this country's format rules
  ///
  /// Extracts digits and applies country-specific formatting.
  ///
  /// Examples:
  /// - US: "5551234567" -> "(555) 123-4567"
  /// - JP: "8012345678" -> "80-1234-5678"
  String format(String value) {
    final digits = _extractDigits(value);
    if (digits.isEmpty) return '';

    switch (isoCode) {
      case 'US':
        return _formatUS(digits);
      case 'JP':
        return _formatJP(digits);
      default:
        return digits;
    }
  }

  /// Validates if the phone number has the correct length for this country
  ///
  /// Returns true if the number of digits matches the expected length.
  ///
  /// Example:
  /// - US: "(555) 123-4567" -> true (10 digits)
  /// - JP: "80-1234-5678" -> true (10 digits)
  bool isValid(String phoneNumber) {
    final digits = _extractDigits(phoneNumber);
    return digits.length == phoneLength;
  }

  /// Converts phone number to E.164 format for API/Firebase Auth
  ///
  /// E.164 format: +[country code][phone number] (no formatting)
  ///
  /// Examples:
  /// - US: "(555) 123-4567" -> "+15551234567"
  /// - JP: "80-1234-5678" -> "+818012345678"
  String toE164(String phoneNumber) {
    final digits = _extractDigits(phoneNumber);
    return '$dialCode$digits';
  }

  // =========================================================================
  // Private Helper Methods
  // =========================================================================

  /// Extracts only digits from a phone number string
  static String _extractDigits(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }

  /// Formats US phone number: (XXX) XXX-XXXX
  String _formatUS(String digits) {
    if (digits.length <= 3) {
      return '($digits';
    }
    if (digits.length <= 6) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3)}';
    }
    final maxLength = digits.length > phoneLength ? phoneLength : digits.length;
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6, maxLength)}';
  }

  /// Formats Japan mobile phone number: XX-XXXX-XXXX
  String _formatJP(String digits) {
    if (digits.length <= 2) {
      return digits;
    }
    if (digits.length <= 6) {
      return '${digits.substring(0, 2)}-${digits.substring(2)}';
    }
    final maxLength = digits.length > phoneLength ? phoneLength : digits.length;
    return '${digits.substring(0, 2)}-${digits.substring(2, 6)}-${digits.substring(6, maxLength)}';
  }
}
