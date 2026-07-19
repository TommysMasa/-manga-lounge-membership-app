/// Referral source value object for user profiles
///
/// Tracks how users discovered the store.
/// This is an optional field used for marketing analytics.
enum ReferralSource {
  igTiktok('IG/TikTok'),
  walkBy('Passing by'),
  flyerElac('Flyer (ELAC)'),
  flyerCsula('Flyer (CSULA)'),
  flyerLittleTokyo('Flyer (Little Tokyo)'),
  flyerOther('Flyer (Other)'),
  reddit('Reddit'),
  friendReferral('Friend referral'),
  other('Other');

  const ReferralSource(this.displayName);

  /// Human-readable display name for UI
  final String displayName;

  /// All referral sources as display strings (for pickers)
  static List<String> get displayNames =>
      ReferralSource.values.map((r) => r.displayName).toList();

  /// Parse from string (case-insensitive)
  /// Returns null if not found
  static ReferralSource? tryParse(String value) {
    final normalized = value.toLowerCase().trim();
    for (final source in ReferralSource.values) {
      if (source.name == normalized ||
          source.displayName.toLowerCase() == normalized) {
        return source;
      }
    }
    return null;
  }

  /// Parse from string, throws if not found
  static ReferralSource parse(String value) {
    final result = tryParse(value);
    if (result == null) {
      throw ArgumentError('Invalid referral source value: $value');
    }
    return result;
  }

  /// Parse from index (for picker selection)
  static ReferralSource fromIndex(int index) {
    if (index < 0 || index >= ReferralSource.values.length) {
      throw RangeError('ReferralSource index out of range: $index');
    }
    return ReferralSource.values[index];
  }
}
