import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/country_code.dart';
import '../../../../shared/constants/country_codes.dart';

part 'phone_input_state.freezed.dart';

/// State for phone number input screen
@freezed
sealed class PhoneInputState with _$PhoneInputState {
  const factory PhoneInputState({
    /// Currently selected country
    @Default(null) CountryCode? selectedCountry,

    /// Phone number (formatted for display)
    @Default('') String phoneNumber,

    /// Raw digits only (for validation)
    @Default('') String digits,

    /// Whether the phone number is valid
    @Default(false) bool isValid,
  }) = _PhoneInputState;

  const PhoneInputState._();

  /// Get selected country or default
  CountryCode get country => selectedCountry ?? defaultCountryCode;

  /// Phone number in E.164 format for API calls
  String get e164PhoneNumber => country.toE164(phoneNumber);
}
