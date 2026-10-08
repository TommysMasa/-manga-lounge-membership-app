import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/di/providers.dart';
import 'package:manga_lounge/features/user/domain/entities/user.dart';
import 'package:manga_lounge/features/user/domain/repositories/user_repository.dart';
import 'package:manga_lounge/features/user/domain/value_objects/gender.dart';
import 'package:manga_lounge/features/user/presentation/widgets/profile_form/profile_form_notifier.dart';

class MockRepository extends Mock implements UserRepository {}

void main() {
  test(
    'form submits only edited fields and resets its baseline after saving',
    () async {
      final user = User(
        uid: 'synthetic',
        firstName: 'Test',
        lastName: 'Member',
        gender: 'Other',
        dateOfBirth: DateTime.utc(2000),
        createdAt: DateTime.utc(2026),
      );
      final repository = MockRepository();
      when(
        () => repository.updateUserProfile(
          uid: any(named: 'uid'),
          nickname: any(named: 'nickname'),
          birthYear: any(named: 'birthYear'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          gender: any(named: 'gender'),
          dateOfBirth: any(named: 'dateOfBirth'),
          referralSource: any(named: 'referralSource'),
          zipcode: any(named: 'zipcode'),
        ),
      ).thenAnswer((_) async => Right(user));
      final container = ProviderContainer(
        overrides: [userRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      container.listen(profileFormProvider, (_, _) {});
      final form = container.read(profileFormProvider.notifier);
      form.initForEdit(
        user: user,
        email: 'test@example.invalid',
        phoneNumber: '+16505550001',
      );
      form.updateNickname('Edited');
      expect((await form.submit(uid: user.uid)).isRight(), isTrue);
      verify(
        () => repository.updateUserProfile(
          uid: 'synthetic',
          nickname: 'Edited',
          birthYear: null,
          firstName: null,
          lastName: null,
          gender: null,
          dateOfBirth: null,
          referralSource: null,
          zipcode: null,
        ),
      ).called(1);
      // A second edit must not send the name saved on the previous submission.
      form.updateGender(Gender.male);
      expect((await form.submit(uid: user.uid)).isRight(), isTrue);
      verify(
        () => repository.updateUserProfile(
          uid: 'synthetic',
          nickname: null,
          birthYear: null,
          firstName: null,
          lastName: null,
          gender: Gender.male.displayName,
          dateOfBirth: null,
          referralSource: null,
          zipcode: null,
        ),
      ).called(1);
    },
  );
}
