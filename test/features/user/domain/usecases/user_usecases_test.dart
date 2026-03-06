import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_lounge/core/error/failures.dart';
import 'package:manga_lounge/features/user/domain/entities/user.dart';
import 'package:manga_lounge/features/user/domain/repositories/user_repository.dart';
import 'package:manga_lounge/features/user/domain/usecases/user_usecases.dart';
import 'package:manga_lounge/features/user/domain/value_objects/user_status.dart';
import 'package:mocktail/mocktail.dart';

/// Mock UserRepository for testing
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
  });

  group('CreateUserProfile', () {
    late CreateUserProfile useCase;

    setUp(() {
      useCase = CreateUserProfile(mockRepository);
    });

    final testUser = User(
      uid: 'test-uid',
      firstName: 'John',
      lastName: 'Doe',
      gender: 'Male',
      dateOfBirth: DateTime(1990, 1, 1),
      status: UserStatus.checkedOut,
      createdAt: DateTime.now(),
    );

    test('should create user profile successfully', () async {
      // Arrange
      when(
        () => mockRepository.createUserProfile(
          uid: any(named: 'uid'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          gender: any(named: 'gender'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase(
        uid: 'test-uid',
        firstName: 'John',
        lastName: 'Doe',
        gender: 'Male',
        dateOfBirth: DateTime(1990, 1, 1),
      );

      // Assert
      expect(result, Right(testUser));
      verify(
        () => mockRepository.createUserProfile(
          uid: 'test-uid',
          firstName: 'John',
          lastName: 'Doe',
          gender: 'Male',
          dateOfBirth: DateTime(1990, 1, 1),
        ),
      ).called(1);
    });

    test('should return ValidationFailure when first name is empty', () async {
      // Act
      final result = await useCase(
        uid: 'test-uid',
        firstName: '',
        lastName: 'Doe',
        gender: 'Male',
        dateOfBirth: DateTime(1990, 1, 1),
      );

      // Assert
      expect(
        result,
        const Left(ValidationFailure('First name cannot be empty')),
      );
      verifyNever(
        () => mockRepository.createUserProfile(
          uid: any(named: 'uid'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          gender: any(named: 'gender'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      );
    });

    test('should return InvalidAgeFailure when user is under 13', () async {
      // Arrange
      final youngDate = DateTime.now().subtract(const Duration(days: 365 * 10));

      // Act
      final result = await useCase(
        uid: 'test-uid',
        firstName: 'John',
        lastName: 'Doe',
        gender: 'Male',
        dateOfBirth: youngDate,
      );

      // Assert
      expect(
        result,
        const Left(InvalidAgeFailure('User must be at least 13 years old')),
      );
    });
  });

  group('GetUser', () {
    late GetUser useCase;

    setUp(() {
      useCase = GetUser(mockRepository);
    });

    final testUser = User(
      uid: 'test-uid',
      firstName: 'John',
      lastName: 'Doe',
      gender: 'Male',
      dateOfBirth: DateTime(1990, 1, 1),
      status: UserStatus.checkedOut,
      createdAt: DateTime.now(),
    );

    test('should get user by ID successfully', () async {
      // Arrange
      when(
        () => mockRepository.getUserById(any()),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase('test-uid');

      // Assert
      expect(result, Right(testUser));
      verify(() => mockRepository.getUserById('test-uid')).called(1);
    });

    test('should return ValidationFailure when UID is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result, const Left(ValidationFailure('User ID cannot be empty')));
      verifyNever(() => mockRepository.getUserById(any()));
    });

    test(
      'should return UserNotFoundFailure when user does not exist',
      () async {
        // Arrange
        when(() => mockRepository.getUserById(any())).thenAnswer(
          (_) async => const Left(UserNotFoundFailure('User not found')),
        );

        // Act
        final result = await useCase('non-existent-uid');

        // Assert
        expect(result, const Left(UserNotFoundFailure('User not found')));
      },
    );
  });

  group('GetCurrentUser', () {
    late GetCurrentUser useCase;

    setUp(() {
      useCase = GetCurrentUser(mockRepository);
    });

    final testUser = User(
      uid: 'test-uid',
      firstName: 'John',
      lastName: 'Doe',
      gender: 'Male',
      dateOfBirth: DateTime(1990, 1, 1),
      status: UserStatus.checkedOut,
      createdAt: DateTime.now(),
    );

    test('should get current user successfully', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await useCase();

      // Assert
      expect(result, Right(testUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test(
      'should return AuthenticationFailure when no user is authenticated',
      () async {
        // Arrange
        when(() => mockRepository.getCurrentUser()).thenAnswer(
          (_) async =>
              const Left(AuthenticationFailure('No authenticated user')),
        );

        // Act
        final result = await useCase();

        // Assert
        expect(
          result,
          const Left(AuthenticationFailure('No authenticated user')),
        );
      },
    );
  });

  group('UpdateUserProfile', () {
    late UpdateUserProfile useCase;

    setUp(() {
      useCase = UpdateUserProfile(mockRepository);
    });

    final updatedUser = User(
      uid: 'test-uid',
      firstName: 'Jane',
      lastName: 'Smith',
      gender: 'Female',
      dateOfBirth: DateTime(1995, 5, 15),
      status: UserStatus.checkedOut,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should update user profile successfully', () async {
      // Arrange
      when(
        () => mockRepository.updateUserProfile(
          uid: any(named: 'uid'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          gender: any(named: 'gender'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      ).thenAnswer((_) async => Right(updatedUser));

      // Act
      final result = await useCase(
        uid: 'test-uid',
        firstName: 'Jane',
        lastName: 'Smith',
        gender: 'Female',
        dateOfBirth: DateTime(1995, 5, 15),
      );

      // Assert
      expect(result, Right(updatedUser));
      verify(
        () => mockRepository.updateUserProfile(
          uid: 'test-uid',
          firstName: 'Jane',
          lastName: 'Smith',
          gender: 'Female',
          dateOfBirth: DateTime(1995, 5, 15),
        ),
      ).called(1);
    });

    test('should return ValidationFailure when UID is empty', () async {
      // Act
      final result = await useCase(uid: '', firstName: 'Jane');

      // Assert
      expect(result, const Left(ValidationFailure('User ID cannot be empty')));
      verifyNever(
        () => mockRepository.updateUserProfile(
          uid: any(named: 'uid'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          gender: any(named: 'gender'),
          dateOfBirth: any(named: 'dateOfBirth'),
        ),
      );
    });
  });

  group('CheckUserProfileExists', () {
    late CheckUserProfileExists useCase;

    setUp(() {
      useCase = CheckUserProfileExists(mockRepository);
    });

    test('should return true when user exists', () async {
      // Arrange
      when(
        () => mockRepository.checkUserProfileExists(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await useCase('test-uid');

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.checkUserProfileExists('test-uid')).called(1);
    });

    test('should return false when user does not exist', () async {
      // Arrange
      when(
        () => mockRepository.checkUserProfileExists(any()),
      ).thenAnswer((_) async => const Right(false));

      // Act
      final result = await useCase('non-existent-uid');

      // Assert
      expect(result, const Right(false));
    });

    test('should return ValidationFailure when UID is empty', () async {
      // Act
      final result = await useCase('');

      // Assert
      expect(result, const Left(ValidationFailure('User ID cannot be empty')));
      verifyNever(() => mockRepository.checkUserProfileExists(any()));
    });
  });
}
