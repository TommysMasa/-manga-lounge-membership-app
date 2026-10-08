import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/error/exceptions.dart';
import 'package:manga_lounge/features/auth/data/datasources/auth_datasource.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  setUpAll(() => registerFallbackValue(const Duration(seconds: 30)));
  for (final callbackFailure in [true, false]) {
    for (final code in [
      'too-many-requests',
      'quota-exceeded',
      'invalid-app-credential',
      'captcha-check-failed',
      'network-request-failed',
      'provider-new-error',
      'unsafe +15555550123',
    ]) {
      test(
        'SMS category $code, callback=$callbackFailure, excludes payload',
        () async {
          final auth = _MockFirebaseAuth();
          final error = FirebaseAuthException(
            code: code,
            message: 'Private phone +15555550123 and verification secret',
          );
          when(
            () => auth.verifyPhoneNumber(
              phoneNumber: any(named: 'phoneNumber'),
              verificationCompleted: any(named: 'verificationCompleted'),
              verificationFailed: any(named: 'verificationFailed'),
              codeSent: any(named: 'codeSent'),
              codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
              timeout: any(named: 'timeout'),
            ),
          ).thenAnswer((invocation) async {
            if (!callbackFailure) throw error;
            final callback =
                invocation.namedArguments[#verificationFailed]
                    as void Function(FirebaseAuthException);
            callback(error);
          });
          try {
            await FirebaseAuthDataSource(
              firebaseAuth: auth,
            ).sendOTP('+15555550123');
            fail('Expected an SMS exception');
          } on AuthException catch (e) {
            final expectedCode = code.startsWith('unsafe')
                ? 'unknown-error'
                : code;
            expect(e.code, expectedCode);
            expect(e.message, contains('(SMS: $expectedCode)'));
            expect(e.message, isNot(contains('15555550123')));
            expect(e.message, isNot(contains('verification secret')));
            if (code == 'quota-exceeded') {
              expect(e.message, contains('sending limit'));
            } else if (code == 'too-many-requests') {
              expect(e.message, contains('temporarily restricted'));
            } else if (code == 'invalid-app-credential' ||
                code == 'captcha-check-failed') {
              expect(e.message, contains('App security verification failed'));
            }
          }
        },
      );
    }
  }
}
