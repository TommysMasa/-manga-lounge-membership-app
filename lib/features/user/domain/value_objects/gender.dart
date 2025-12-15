/// Gender value object for user profiles
///
/// Single source of truth for gender options across the app.
/// Using enum ensures type safety and eliminates magic strings.
enum Gender {
  male('Male'),
  female('Female'),
  other('Other');

  const Gender(this.displayName);

  /// Human-readable display name for UI
  final String displayName;

  /// All genders as display strings (for pickers)
  static List<String> get displayNames =>
      Gender.values.map((g) => g.displayName).toList();

  /// Parse from string (case-insensitive)
  /// Returns null if not found
  static Gender? tryParse(String value) {
    final normalized = value.toLowerCase().trim();
    for (final gender in Gender.values) {
      if (gender.name == normalized ||
          gender.displayName.toLowerCase() == normalized) {
        return gender;
      }
    }
    return null;
  }

  /// Parse from string, throws if not found
  static Gender parse(String value) {
    final result = tryParse(value);
    if (result == null) {
      throw ArgumentError('Invalid gender value: $value');
    }
    return result;
  }

  /// Parse from index (for picker selection)
  static Gender fromIndex(int index) {
    if (index < 0 || index >= Gender.values.length) {
      throw RangeError('Gender index out of range: $index');
    }
    return Gender.values[index];
  }
}
