/// Domain constants for user-related business rules
///
/// Centralizes magic numbers and business rule values.
/// Changes here propagate throughout the app.
abstract final class UserConstants {
  /// Minimum age required to register (business rule)
  static const int minimumAge = 13;

  /// Earliest valid birth year for date picker
  static const int minimumBirthYear = 1900;

  /// Default birth year for date picker initial value
  static const int defaultBirthYear = 2000;

  /// Calculate minimum allowed birth date (for date picker maximum)
  static DateTime get minimumBirthDate => DateTime(minimumBirthYear);

  /// Calculate maximum allowed birth date (today, for date picker)
  static DateTime get maximumBirthDate => DateTime.now();

  /// Default date of birth for form initialization
  static DateTime get defaultDateOfBirth => DateTime(defaultBirthYear);

  /// Calculate age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    // Adjust if birthday hasn't occurred yet this year
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  /// Check if date of birth meets minimum age requirement
  static bool isValidAge(DateTime dateOfBirth) {
    return calculateAge(dateOfBirth) >= minimumAge;
  }
}
