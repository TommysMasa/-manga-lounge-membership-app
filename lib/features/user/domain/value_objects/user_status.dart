import 'package:freezed_annotation/freezed_annotation.dart';

enum UserStatus {
  checkedIn('checked_in'),
  checkedOut('checked_out');

  const UserStatus(this.value);

  /// Value stored in Firestore
  final String value;

  static UserStatus fromValue(String value) {
    return UserStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => UserStatus.checkedOut,
    );
  }
}

/// Converts between UserStatus enum and String for Firestore/JSON serialization
class UserStatusConverter implements JsonConverter<UserStatus, String> {
  const UserStatusConverter();

  @override
  UserStatus fromJson(String json) => UserStatus.fromValue(json);

  @override
  String toJson(UserStatus object) => object.value;
}
