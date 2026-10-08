import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/features/auth/data/datasources/registration_session.dart';

class TestAuth extends Mock implements FirebaseAuth {}

class TestUser extends Mock implements User {}

void main() {
  late TestAuth auth;
  late TestUser user;
  setUp(() {
    auth = TestAuth();
    user = TestUser();
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.signOut()).thenAnswer((_) async {});
  });
  test(
    'externally deleted user is signed out instead of stranded in registration',
    () async {
      when(
        () => user.reload(),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));
      expect(await hasLiveRegistrationSession(auth), isFalse);
      verify(() => auth.signOut()).called(1);
    },
  );
  test('disabled and revoked sessions are signed out', () async {
    for (final code in [
      'user-disabled',
      'user-token-expired',
      'invalid-user-token',
    ]) {
      when(() => user.reload()).thenThrow(FirebaseAuthException(code: code));
      expect(await hasLiveRegistrationSession(auth), isFalse);
    }
    verify(() => auth.signOut()).called(3);
  });
  test('temporary network errors retain the session', () async {
    when(
      () => user.reload(),
    ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));
    expect(await hasLiveRegistrationSession(auth), isTrue);
    verifyNever(() => auth.signOut());
  });
  test(
    'valid users can complete registration and missing sessions cannot',
    () async {
      when(() => user.reload()).thenAnswer((_) async {});
      expect(await hasLiveRegistrationSession(auth), isTrue);
      when(() => auth.currentUser).thenReturn(null);
      expect(await hasLiveRegistrationSession(auth), isFalse);
      verifyNever(() => auth.signOut());
    },
  );
}
