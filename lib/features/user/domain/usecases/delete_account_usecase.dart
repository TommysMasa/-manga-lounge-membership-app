import '../../../../core/error/result.dart';
import '../repositories/user_repository.dart';

/// Use case for deleting user account
///
/// This use case:
/// 1. Deletes user document from Firestore
/// 2. Deletes all related Records
/// 3. Records deletion statistics
/// 4. Deletes Firebase Authentication account
class DeleteAccountUseCase {
  final UserRepository repository;

  DeleteAccountUseCase(this.repository);

  /// Execute account deletion
  ///
  /// Parameters:
  /// - uid: User ID to delete
  ///
  /// Returns:
  /// - Success: Account deleted successfully
  /// - Failure: Failed to delete account (AuthenticationFailure, DatabaseFailure, etc.)
  Future<Result<void>> call(String uid) async {
    return await repository.deleteAccount(uid);
  }
}
