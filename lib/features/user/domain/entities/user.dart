import 'package:freezed_annotation/freezed_annotation.dart';

import '../value_objects/timestamp_converter.dart';
import '../value_objects/user_status.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// User entity representing a Manga Lounge member
///
/// This is a domain entity used across all layers (no DTOs needed - YAGNI).
/// Uses Freezed for immutability and value equality.
/// Includes JSON serialization for Firestore integration.
@freezed
abstract class User with _$User {
  const User._();

  const factory User({
    required String uid,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    String? referralSource,
    @UserStatusConverter() @Default(UserStatus.checkedOut) UserStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    @TimestampConverter() DateTime? lastEntryTime,
  }) = _User;

  /// Create User from JSON (Firestore document)
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Get full name of the user
  String get fullName => '$firstName $lastName';

  /// Check if user is currently checked in
  bool get isCheckedIn => status == UserStatus.checkedIn;

  /// Entry time is only meaningful when the user is checked in
  DateTime? get activeEntryTime => isCheckedIn ? lastEntryTime : null;
}
