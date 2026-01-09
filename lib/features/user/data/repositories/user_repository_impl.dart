import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_datasource.dart';

/// Implementation of UserRepository
///
/// This class:
/// 1. Implements the domain layer's UserRepository interface
/// 2. Delegates actual work to UserDataSource (data layer)
/// 3. Converts Exceptions (data layer) to Failures (domain layer)
/// 4. Returns `Result<T>` to domain layer
///
/// This is the boundary between data and domain layers.
class UserRepositoryImpl implements UserRepository {
  final UserDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  AsyncResult<User> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String phoneNumber,
  }) async {
    try {
      final user = await dataSource.createUserProfile(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
      );
      return Right(user);
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error creating user profile: $e'));
    }
  }

  @override
  AsyncResult<User> getUserById(String uid) async {
    try {
      final user = await dataSource.getUserById(uid);
      return Right(user);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error getting user: $e'));
    }
  }

  @override
  AsyncResult<User> getCurrentUser() async {
    try {
      final user = await dataSource.getCurrentUser();
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error getting current user: $e'));
    }
  }

  @override
  AsyncResult<User> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? status,
  }) async {
    try {
      final user = await dataSource.updateUserProfile(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        status: status,
      );
      return Right(user);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error updating user profile: $e'));
    }
  }

  @override
  AsyncResult<bool> checkUserProfileExists(String uid) async {
    try {
      final exists = await dataSource.checkUserProfileExists(uid);
      return Right(exists);
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error checking user existence: $e'));
    }
  }

  @override
  StreamResult<User> watchUser(String uid) {
    try {
      return dataSource.watchUser(uid).map<Result<User>>((user) => Right(user)).handleError((error) {
        if (error is UserNotFoundException) {
          return Left(UserNotFoundFailure(error.message));
        } else if (error is FirestoreException) {
          return Left(DatabaseFailure(error.message));
        } else {
          return Left(DatabaseFailure('Unexpected error watching user: $error'));
        }
      });
    } catch (e) {
      return Stream.value(Left(DatabaseFailure('Failed to watch user: $e')));
    }
  }

  @override
  AsyncResult<User> updateUserStatus({
    required String uid,
    required String status,
  }) async {
    try {
      final user = await dataSource.updateUserStatus(uid: uid, status: status);
      return Right(user);
    } on UserNotFoundException catch (e) {
      return Left(UserNotFoundFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error updating user status: $e'));
    }
  }

  @override
  AsyncResult<void> deleteAccount(String uid) async {
    try {
      await dataSource.deleteAccount(uid);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure('Unexpected error deleting account: $e'));
    }
  }

  @override
  AsyncResult<void> updatePhoneNumber({
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      await dataSource.updatePhoneNumber(uid: uid, phoneNumber: phoneNumber);
      return const Right(null);
    } on FirestoreException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
          DatabaseFailure('Unexpected error updating phone number: $e'));
    }
  }
}
