import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing a Manga Lounge member
class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final DateTime dateOfBirth;
  final String phoneNumber;
  final String status; // 'checked_in' or 'checked_out'
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Helper function to parse date fields (handles both Timestamp and String)
    DateTime? parseDate(dynamic dateField, DateTime? defaultValue) {
      if (dateField is Timestamp) {
        return dateField.toDate();
      } else if (dateField is String) {
        // Try to parse string date (e.g., "08/28/1999")
        try {
          final parts = dateField.split('/');
          if (parts.length == 3) {
            return DateTime(
              int.parse(parts[2]), // year
              int.parse(parts[0]), // month
              int.parse(parts[1]), // day
            );
          }
        } catch (e) {
          print('Error parsing date string: $dateField - $e');
        }
      }
      return defaultValue;
    }

    return UserModel(
      uid: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      gender: data['gender'] ?? '',
      dateOfBirth: parseDate(data['dateOfBirth'], DateTime(2000))!,
      phoneNumber: data['phoneNumber'] ?? '',
      status: data['status'] ?? 'checked_out',
      createdAt: parseDate(data['createdAt'], DateTime.now())!,
      updatedAt: data['updatedAt'] != null
          ? parseDate(data['updatedAt'], null)
          : null,
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'phoneNumber': phoneNumber,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? phoneNumber,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Check if user is checked in
  bool get isCheckedIn => status == 'checked_in';
}
