import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/error/failures.dart';
import 'package:manga_lounge/features/auth/domain/repositories/auth_repository.dart';
import 'package:manga_lounge/features/auth/domain/usecases/auth_usecases.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
  });

  group('SendOTP Use Case', () {
    late SendOTP useCase;

    setUp(() {
      useCase = SendOTP(mockRepository);
    });

    test('should return verification ID when phone number is valid', () async {
      // Arrange
      const phoneNumber = '+1234567890';
      const verificationId = 'test_verification_id';
      when(() => mockRepository.sendOTP(phoneNumber))
          .thenAnswer((_) async => const Right(verificationId));

      // Act
      final result = await useCase.call(phoneNumber);

      // Assert
      expect(result, const Right(verificationId));
      verify(() => mockRepository.sendOTP(phoneNumber)).called(1);
    });

    test('should return failure when phone number is empty', () async {
      // Arrange
      const phoneNumber = '';

      // Act
      final result = await useCase.call(phoneNumber);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumberFailure>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.sendOTP(any()));
    });

    test('should return failure when phone number has no country code', () async {
      // Arrange
      const phoneNumber = '1234567890';

      // Act
      final result = await useCase.call(phoneNumber);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidPhoneNumberFailure>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.sendOTP(any()));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const phoneNumber = '+1234567890';
      const failure = TooManyRequestsFailure('Too many requests');
      when(() => mockRepository.sendOTP(phoneNumber))
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(phoneNumber);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.sendOTP(phoneNumber)).called(1);
    });
  });

  group('VerifyOTP Use Case', () {
    late VerifyOTP useCase;

    setUp(() {
      useCase = VerifyOTP(mockRepository);
    });

    test('should return UID when OTP is valid', () async {
      // Arrange
      const verificationId = 'test_verification_id';
      const otpCode = '123456';
      const uid = 'test_user_id';
      when(() => mockRepository.verifyOTP(
            verificationId: verificationId,
            otpCode: otpCode,
          )).thenAnswer((_) async => const Right(uid));

      // Act
      final result = await useCase.call(
        verificationId: verificationId,
        otpCode: otpCode,
      );

      // Assert
      expect(result, const Right(uid));
      verify(() => mockRepository.verifyOTP(
            verificationId: verificationId,
            otpCode: otpCode,
          )).called(1);
    });

    test('should return failure when verification ID is empty', () async {
      // Arrange
      const verificationId = '';
      const otpCode = '123456';

      // Act
      final result = await useCase.call(
        verificationId: verificationId,
        otpCode: otpCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Should return failure'),
      );
      verifyNever(() => mockRepository.verifyOTP(
            verificationId: any(named: 'verificationId'),
            otpCode: any(named: 'otpCode'),
          ));
    });

    test('should return failure when OTP code is empty', () async {
      // Arrange
      const verificationId = 'test_verification_id';
      const otpCode = '';

      // Act
      final result = await useCase.call(
        verificationId: verificationId,
        otpCode: otpCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidOTPFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return failure when OTP code is not 6 digits', () async {
      // Arrange
      const verificationId = 'test_verification_id';
      const otpCode = '12345'; // Only 5 digits

      // Act
      final result = await useCase.call(
        verificationId: verificationId,
        otpCode: otpCode,
      );

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<InvalidOTPFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const verificationId = 'test_verification_id';
      const otpCode = '123456';
      const failure = InvalidOTPFailure('Invalid OTP');
      when(() => mockRepository.verifyOTP(
            verificationId: verificationId,
            otpCode: otpCode,
          )).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call(
        verificationId: verificationId,
        otpCode: otpCode,
      );

      // Assert
      expect(result, const Left(failure));
    });
  });

  group('SignOut Use Case', () {
    late SignOut useCase;

    setUp(() {
      useCase = SignOut(mockRepository);
    });

    test('should return unit when sign out succeeds', () async {
      // Arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Right(unit));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, const Right(unit));
      verify(() => mockRepository.signOut()).called(1);
    });

    test('should return failure when sign out fails', () async {
      // Arrange
      const failure = AuthenticationFailure('Sign out failed');
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.signOut()).called(1);
    });
  });
}
