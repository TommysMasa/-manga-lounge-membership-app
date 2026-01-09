import '../../../../core/error/result.dart';
import '../entities/user.dart';

/// Repository interface for User operations
///
/// This is the contract between domain and data layers.
/// The data layer implements this interface, hiding Firestore implementation details.
/// Returns `Result<T>` for proper error handling in the domain layer.
abstract class UserRepository {
  /// Create a new user profile in Firestore
  ///
  /// Returns:
  /// - Success: User profile created successfully
  /// - Failure: Failed to create user profile
  AsyncResult<User> createUserProfile({
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
  /// - Success: User found
  /// - Failure: User not found or error occurred
  AsyncResult<User> getUserById(String uid);

  /// Get current authenticated user's profile
  ///
  /// Returns:
  /// - Success: User profile found
  /// - Failure: No authenticated user or profile not found
  AsyncResult<User> getCurrentUser();

  /// Update existing user profile
  ///
  /// Returns:
  /// - Success: User profile updated successfully
  /// - Failure: Failed to update user profile
  AsyncResult<User> updateUserProfile({
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
  /// - Success: true if profile exists, false otherwise
  /// - Failure: Error occurred while checking
  AsyncResult<bool> checkUserProfileExists(String uid);

  /// Watch user changes in real-time
  ///
  /// Emits:
  /// - Success: User data updated
  /// - Failure: Error occurred
  StreamResult<User> watchUser(String uid);

  /// Update user check-in/check-out status
  ///
  /// Returns:
  /// - Success: Status updated successfully
  /// - Failure: Failed to update status
  AsyncResult<User> updateUserStatus({
    required String uid,
    required String status,
  });

  /// Delete user account completely
  ///
  /// This includes:
  /// - User document from Firestore
  /// - All related Records
  /// - Firebase Authentication account
  /// - Record deletion statistics
  ///
  /// Returns:
  /// - Success: Account deleted successfully
  /// - Failure: Failed to delete account
  AsyncResult<void> deleteAccount(String uid);

  /// Update user phone number in Firestore
  ///
  /// This should be called AFTER Firebase Auth phone number is updated.
  /// Firebase Auth is the source of truth for phone numbers.
  ///
  /// Parameters:
  /// - [uid]: User ID
  /// - [phoneNumber]: New phone number (must match Firebase Auth)
  ///
  /// Returns:
  /// - Success: Phone number updated in Firestore
  /// - Failure: Failed to update phone number
  AsyncResult<void> updatePhoneNumber({
    required String uid,
    required String phoneNumber,
  });
}
