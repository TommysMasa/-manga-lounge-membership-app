import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';

/// Implementation of AuthRepository
///
/// This class:
/// 1. Implements the domain layer's AuthRepository interface
/// 2. Delegates actual work to AuthDataSource (data layer)
/// 3. Converts Exceptions (data layer) to Failures (domain layer)
/// 4. Returns `Result<T>` to domain layer
///
/// This is the boundary between data and domain layers.
class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource dataSource;

  AuthRepositoryImpl(this.dataSource);

  @override
  AsyncResult<String> sendOTP(String phoneNumber) async {
    try {
      final verificationId = await dataSource.sendOTP(phoneNumber);
      return Right(verificationId);
    } on AuthException catch (e) {
      return Left(_mapAuthExceptionToFailure(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<String> verifyOTP({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      final uid = await dataSource.verifyOTP(
        verificationId: verificationId,
        otpCode: otpCode,
      );
      return Right(uid);
    } on AuthException catch (e) {
      return Left(_mapAuthExceptionToFailure(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  AsyncResult<Unit> signOut() async {
    try {
      await dataSource.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('Failed to sign out: ${e.toString()}'));
    }
  }

  @override
  StreamResult<String?> authStateChanges() {
    try {
      return dataSource.authStateChanges().map((uid) => Right<Failure, String?>(uid));
    } on AuthException catch (e) {
      return Stream.value(Left(AuthenticationFailure(e.message)));
    } catch (e) {
      return Stream.value(
        Left(
          AuthenticationFailure('Error monitoring auth state: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  AsyncResult<String?> getCurrentUserId() async {
    try {
      final uid = await dataSource.getCurrentUserId();
      return Right(uid);
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } catch (e) {
      return Left(
        AuthenticationFailure('Error getting current user: ${e.toString()}'),
      );
    }
  }

  @override
  AsyncResult<Unit> updatePhoneNumber({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      await dataSource.updatePhoneNumber(
        verificationId: verificationId,
        otpCode: otpCode,
      );
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(_mapAuthExceptionToFailure(e));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(AuthenticationFailure('Unexpected error: ${e.toString()}'));
    }
  }

  /// Map AuthException to appropriate Failure type
  Failure _mapAuthExceptionToFailure(AuthException exception) {
    final code = exception.code?.toLowerCase() ?? '';
    final message = exception.message;

    if (code.contains('invalid-phone')) {
      return InvalidPhoneNumberFailure(message);
    } else if (code.contains('invalid-verification-code')) {
      return InvalidOTPFailure(message);
    } else if (code.contains('session-expired') || code.contains('expired')) {
      return OTPExpiredFailure(message);
    } else if (code.contains('too-many-requests') || code.contains('quota')) {
      return TooManyRequestsFailure(message);
    } else if (code.contains('user-not-found')) {
      return UserNotFoundFailure(message);
    } else if (code.contains('network')) {
      return NetworkFailure(message);
    } else {
      return AuthenticationFailure(message);
    }
  }
}
