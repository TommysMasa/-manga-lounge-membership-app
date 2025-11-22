/// Shared validation utilities for the application

class Validators {
  /// Validates if a phone number is in E.164 format
  /// E.164 format: +[country code][subscriber number]
  /// Example: +1234567890
  static bool isValidE164PhoneNumber(String phoneNumber) {
    final e164Regex = RegExp(r'^\+[1-9]\d{1,14}$');
    return e164Regex.hasMatch(phoneNumber);
  }

  /// Validates email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validates if user is at least minimum age (default: 13 years old)
  static bool isValidAge(DateTime dateOfBirth, {int minimumAge = 13}) {
    final now = DateTime.now();
    final age = now.year - dateOfBirth.year;
    final hasHadBirthdayThisYear = now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;
    return actualAge >= minimumAge;
  }

  /// Validates if a string is not empty or just whitespace
  static bool isNotEmpty(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  /// Validates OTP code (6 digits)
  static bool isValidOTP(String otp) {
    final otpRegex = RegExp(r'^\d{6}$');
    return otpRegex.hasMatch(otp);
  }
}
