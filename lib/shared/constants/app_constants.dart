/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Manga Lounge';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';

  // Gender Options
  static const String genderMale = 'male';
  static const String genderFemale = 'female';
  static const String genderOther = 'other';
  static const String genderPreferNotToSay = 'prefer_not_to_say';

  // Age Restriction
  static const int minimumAge = 13;

  // URLs
  static const String privacyPolicyUrl = 'https://mangalounge.com/privacy';
  static const String termsAndConditionsUrl = 'https://mangalounge.com/terms';
  static const String contactEmail = 'support@mangalounge.com';

  // Validation
  static const int minNameLength = 1;
  static const int maxNameLength = 50;

  // Timeouts
  static const int otpTimeoutSeconds = 60;
  static const int otpCodeLength = 6;
}
