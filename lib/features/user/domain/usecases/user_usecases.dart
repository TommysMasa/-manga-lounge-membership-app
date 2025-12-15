import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
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
  /// - Right(User): User profile created successfully
  /// - Left(Failure): Failed to create user profile
  Future<Either<Failure, User>> call({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String phoneNumber,
  }) async {
    // Business logic: Validate inputs
    if (firstName.trim().isEmpty) {
      return const Left(ValidationFailure('First name cannot be empty'));
    }

    if (lastName.trim().isEmpty) {
      return const Left(ValidationFailure('Last name cannot be empty'));
    }

    if (email.trim().isEmpty || !email.contains('@')) {
      return const Left(ValidationFailure('Invalid email address'));
    }

    if (gender.trim().isEmpty) {
      return const Left(ValidationFailure('Gender cannot be empty'));
    }

    // Business logic: Age validation (must be at least 13 years old)
    final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
    if (age < 13) {
      return const Left(InvalidAgeFailure('User must be at least 13 years old'));
    }

    return await repository.createUserProfile(
      uid: uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      gender: gender,
      dateOfBirth: dateOfBirth,
      phoneNumber: phoneNumber,
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
  /// - Right(User): User found
  /// - Left(Failure): User not found or error occurred
  Future<Either<Failure, User>> call(String uid) async {
    if (uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
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
  /// - Right(User): User profile found
  /// - Left(Failure): No authenticated user or profile not found
  Future<Either<Failure, User>> call() async {
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
  /// - Right(User): User profile updated successfully
  /// - Left(Failure): Failed to update user profile
  Future<Either<Failure, User>> call({
    required String uid,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    if (uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    // Business logic: Validate inputs if provided
    if (firstName != null && firstName.trim().isEmpty) {
      return const Left(ValidationFailure('First name cannot be empty'));
    }

    if (lastName != null && lastName.trim().isEmpty) {
      return const Left(ValidationFailure('Last name cannot be empty'));
    }

    if (email != null && (email.trim().isEmpty || !email.contains('@'))) {
      return const Left(ValidationFailure('Invalid email address'));
    }

    if (gender != null && gender.trim().isEmpty) {
      return const Left(ValidationFailure('Gender cannot be empty'));
    }

    // Business logic: Age validation if dateOfBirth is provided
    if (dateOfBirth != null) {
      final age = DateTime.now().difference(dateOfBirth).inDays ~/ 365;
      if (age < 13) {
        return const Left(InvalidAgeFailure('User must be at least 13 years old'));
      }
    }

    return await repository.updateUserProfile(
      uid: uid,
      firstName: firstName?.trim(),
      lastName: lastName?.trim(),
      email: email?.trim(),
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
  /// - Right(true): User profile exists
  /// - Right(false): User profile does not exist
  /// - Left(Failure): Error occurred while checking
  Future<Either<Failure, bool>> call(String uid) async {
    if (uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
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
  /// - Right(User): User data updated
  /// - Left(Failure): Error occurred
  Stream<Either<Failure, User>> call(String uid) {
    if (uid.trim().isEmpty) {
      return Stream.value(
        const Left(ValidationFailure('User ID cannot be empty')),
      );
    }

    return repository.watchUser(uid);
  }
}

/// Update user check-in/check-out status
class UpdateUserStatus {
  final UserRepository repository;

  UpdateUserStatus(this.repository);

  /// Update user's check-in/check-out status
  ///
  /// Returns:
  /// - Right(User): Status updated successfully
  /// - Left(Failure): Failed to update status
  Future<Either<Failure, User>> call({
    required String uid,
    required String status,
  }) async {
    if (uid.trim().isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    // Business logic: Validate status
    if (status != 'checked_in' && status != 'checked_out') {
      return const Left(
        ValidationFailure('Invalid status. Must be "checked_in" or "checked_out"'),
      );
    }

    return await repository.updateUserStatus(uid: uid, status: status);
  }
}
