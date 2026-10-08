import '../entities/account_deletion_outcome.dart';
import '../../../../core/error/result.dart';
import '../repositories/user_repository.dart';

/// Use case for deleting user account
///
/// This use case:
/// Requests server-side erasure of the authenticated member. Personal data is
/// removed, business history is anonymized, and interrupted jobs resume safely.
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
  Future<Result<AccountDeletionOutcome>> call(String uid) async {
    return await repository.deleteAccount(uid);
  }
}
