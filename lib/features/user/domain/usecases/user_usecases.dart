import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use Cases for User Management
///
/// Following the YAGNI principle, we group related use cases in one file
/// instead of creating separate files for each use case.
///
/// Each use case has a single responsibility and is easily testable.
/// Use cases contain business logic and orchestrate repository calls.

/// Create a new user profile
class CreateUserProfile {
  final UserRepository repository;

  CreateUserProfile(this.repository);

  /// Create a new user profile in Firestore
  ///
  /// Returns:
  /// - Success: User profile created successfully
  /// - Failure: Failed to create user profile
  AsyncResult<User> call({
    required String uid,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    // Business logic: Validate inputs
    if (firstName.trim().isEmpty) {
      return Results.failure(const ValidationFailure('First name cannot be empty'));
    }

    if (lastName.trim().isEmpty) {
      return Results.failure(const ValidationFailure('Last name cannot be empty'));
    }

    if (gender.trim().isEmpty) {
      return Results.failure(const ValidationFailure('Gender cannot be empty'));
    }

    // Business logic: Age validation (must be at least 13 years old)
    final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
    if (age < 13) {
      return Results.failure(
        const InvalidAgeFailure('User must be at least 13 years old'),
      );
    }

    return await repository.createUserProfile(
      uid: uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
}

/// Get user by ID
class GetUser {
  final UserRepository repository;

  GetUser(this.repository);

  /// Get user by their unique ID
  ///
  /// Returns:
  /// - Success: User found
  /// - Failure: User not found or error occurred
  AsyncResult<User> call(String uid) async {
    if (uid.trim().isEmpty) {
      return Results.failure(const ValidationFailure('User ID cannot be empty'));
    }

    return await repository.getUserById(uid);
  }
}

/// Get current authenticated user's profile
class GetCurrentUser {
  final UserRepository repository;

  GetCurrentUser(this.repository);

  /// Get the current authenticated user's profile
  ///
  /// Returns:
  /// - Success: User profile found
  /// - Failure: No authenticated user or profile not found
  AsyncResult<User> call() async {
    return await repository.getCurrentUser();
  }
}

/// Update user profile
class UpdateUserProfile {
  final UserRepository repository;

  UpdateUserProfile(this.repository);

  /// Update existing user profile
  ///
  /// Returns:
  /// - Success: User profile updated successfully
  /// - Failure: Failed to update user profile
  AsyncResult<User> call({
    required String uid,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    if (uid.trim().isEmpty) {
      return Results.failure(const ValidationFailure('User ID cannot be empty'));
    }

    // Business logic: Validate inputs if provided
    if (firstName != null && firstName.trim().isEmpty) {
      return Results.failure(const ValidationFailure('First name cannot be empty'));
    }

    if (lastName != null && lastName.trim().isEmpty) {
      return Results.failure(const ValidationFailure('Last name cannot be empty'));
    }

    if (gender != null && gender.trim().isEmpty) {
      return Results.failure(const ValidationFailure('Gender cannot be empty'));
    }

    // Business logic: Age validation if dateOfBirth is provided
    if (dateOfBirth != null) {
      final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
      if (age < 13) {
        return Results.failure(
          const InvalidAgeFailure('User must be at least 13 years old'),
        );
      }
    }

    return await repository.updateUserProfile(
      uid: uid,
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      gender: gender,
      dateOfBirth: dateOfBirth,
    );
  }
}

/// Check if user profile exists
class CheckUserProfileExists {
  final UserRepository repository;

  CheckUserProfileExists(this.repository);

  /// Check if a user profile exists in Firestore
  ///
  /// Returns:
  /// - Success: true if profile exists, false otherwise
  /// - Failure: Error occurred while checking
  AsyncResult<bool> call(String uid) async {
    if (uid.trim().isEmpty) {
      return Results.failure(const ValidationFailure('User ID cannot be empty'));
    }

    return await repository.checkUserProfileExists(uid);
  }
}

/// Watch user changes in real-time
class WatchUser {
  final UserRepository repository;

  WatchUser(this.repository);

  /// Stream of user changes in real-time
  ///
  /// Emits:
  /// - Success: User data updated
  /// - Failure: Error occurred
  StreamResult<User> call(String uid) {
    if (uid.trim().isEmpty) {
      return Stream.value(
        Results.failure(const ValidationFailure('User ID cannot be empty')),
      );
    }

    return repository.watchUser(uid);
  }
}

