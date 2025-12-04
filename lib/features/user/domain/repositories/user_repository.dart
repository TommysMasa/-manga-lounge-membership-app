import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Repository interface for User operations
///
/// This is the contract between domain and data layers.
/// The data layer implements this interface, hiding Firestore implementation details.
/// Returns Either<Failure, T> for proper error handling in the domain layer.
abstract class UserRepository {
  /// Create a new user profile in Firestore
  ///
  /// Returns:
  /// - Right(User): User profile created successfully
  /// - Left(Failure): Failed to create user profile
  Future<Either<Failure, User>> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String phoneNumber,
  });

  /// Get user by ID
  ///
  /// Returns:
  /// - Right(User): User found
  /// - Left(Failure): User not found or error occurred
  Future<Either<Failure, User>> getUserById(String uid);

  /// Get current authenticated user's profile
  ///
  /// Returns:
  /// - Right(User): User profile found
  /// - Left(Failure): No authenticated user or profile not found
  Future<Either<Failure, User>> getCurrentUser();

  /// Update existing user profile
  ///
  /// Returns:
  /// - Right(User): User profile updated successfully
  /// - Left(Failure): Failed to update user profile
  Future<Either<Failure, User>> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? status,
  });

  /// Check if user profile exists in Firestore
  ///
  /// Returns:
  /// - Right(true): User profile exists
  /// - Right(false): User profile does not exist
  /// - Left(Failure): Error occurred while checking
  Future<Either<Failure, bool>> checkUserProfileExists(String uid);

  /// Watch user changes in real-time
  ///
  /// Emits:
  /// - Right(User): User data updated
  /// - Left(Failure): Error occurred
  Stream<Either<Failure, User>> watchUser(String uid);

  /// Update user check-in/check-out status
  ///
  /// Returns:
  /// - Right(User): Status updated successfully
  /// - Left(Failure): Failed to update status
  Future<Either<Failure, User>> updateUserStatus({
    required String uid,
    required String status,
  });
}
