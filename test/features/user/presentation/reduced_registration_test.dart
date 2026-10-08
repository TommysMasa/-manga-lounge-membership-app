import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_lounge/features/user/domain/entities/user.dart';
import 'package:manga_lounge/features/user/presentation/widgets/profile_form/profile_form.dart';
import 'package:manga_lounge/features/user/presentation/widgets/profile_form/profile_form_state.dart';

void main() {
  test('both legacy and reduced member documents display a member name', () {
    final base = {
      'uid': 'synthetic',
      'gender': 'Other',
      'createdAt': '2026-01-01T00:00:00.000Z',
    };
    final reduced = User.fromJson({
      ...base,
      'nickname': 'Manga Fan',
      'birthYear': 2000,
    });
    expect(reduced.fullName, 'Manga Fan');
    expect(reduced.dateOfBirth, isNull);
    expect(reduced.effectiveBirthYear, 2000);
    final legacy = User.fromJson({
      ...base,
      'firstName': 'Test',
      'lastName': 'Member',
      'dateOfBirth': '2000-06-15T00:00:00.000Z',
    });
    expect(legacy.fullName, 'Test Member');
    expect(legacy.effectiveBirthYear, 2000);
  });
  testWidgets(
    'registration offers only nickname, gender and birth year plus verified phone',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: CupertinoApp(
            home: CupertinoPageScaffold(
              child: ProfileForm(
                mode: ProfileFormMode.create,
                phoneNumber: '+16505550001',
                uid: 'synthetic',
                onSuccess: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      for (final label in [
        'Nick Name',
        'Gender',
        'Birth Year',
        'Phone Number',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
      for (final label in [
        'First Name',
        'Last Name',
        'Email',
        'Date of Birth',
        'Zipcode (Optional)',
        'How did you hear about us? (Optional)',
      ]) {
        expect(find.text(label), findsNothing);
      }
    },
  );
}
