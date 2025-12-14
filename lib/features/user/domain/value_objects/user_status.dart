/// User check-in status value object
///
/// Represents whether a user is currently checked in at Manga Lounge.
/// Using enum ensures type safety and eliminates magic strings like 'checked_in'.
enum UserStatus {
  checkedIn('checked_in', 'Checked In'),
  checkedOut('checked_out', 'Checked Out');

  const UserStatus(this.value, this.displayName);

  /// Value stored in database
  final String value;

  /// Human-readable display name for UI
  final String displayName;

  /// Whether user is currently at the lounge
  bool get isAtLounge => this == UserStatus.checkedIn;

  /// Get the opposite status (for toggle)
  UserStatus get toggled =>
      this == checkedIn ? checkedOut : checkedIn;

  /// Parse from database value
  /// Returns checkedOut as default if not found
  static UserStatus fromValue(String value) {
    return UserStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => UserStatus.checkedOut,
    );
  }

  /// Parse from database value, returns null if not found
  static UserStatus? tryFromValue(String value) {
    for (final status in UserStatus.values) {
      if (status.value == value) {
        return status;
      }
    }
    return null;
  }
}
