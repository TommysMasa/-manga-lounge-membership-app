import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_lounge/features/auth/data/datasources/sms_request_diagnostics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/error/exceptions.dart';
import 'package:manga_lounge/features/auth/data/datasources/auth_datasource.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  setUpAll(() => registerFallbackValue(const Duration(seconds: 30)));
  test(
    'concurrent SMS calls issue only one SDK call, then allow a new call',
    () async {
      final auth = _MockFirebaseAuth();
      final calls = <Invocation>[];
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((call) async {
        calls.add(call);
      });
      final source = FirebaseAuthDataSource(firebaseAuth: auth);
      final first = source.sendOTP('+15555550123');
      await expectLater(
        source.sendOTP('+15555550999'),
        throwsA(
          isA<AuthException>().having(
            (e) => e.code,
            'code',
            'request-in-progress',
          ),
        ),
      );
      expect(calls, hasLength(1));
      (calls.first.namedArguments[#codeSent] as void Function(String, int?))(
        'private-verification-id',
        null,
      );
      expect(await first, 'private-verification-id');
      final second = source.sendOTP('+15555550123');
      expect(calls, hasLength(2));
      (calls.last.namedArguments[#codeSent] as void Function(String, int?))(
        'second-private-id',
        null,
      );
      await second;
      final events = SmsRequestDiagnostics.events.toString();
      expect(events, contains('duplicate-blocked'));
      expect(events, contains('code-sent'));
      expect(events, isNot(contains('1555555')));
      expect(events, isNot(contains('private-id')));
      expect(events, isNot(contains('private-verification-id')));
    },
  );

  test(
    'failed SMS request releases guard and diagnostics stay bounded and sanitized',
    () async {
      final auth = _MockFirebaseAuth();
      var calls = 0;
      when(
        () => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          timeout: any(named: 'timeout'),
        ),
      ).thenAnswer((call) async {
        calls++;
        throw FirebaseAuthException(code: 'too-many-requests');
      });
      final source = FirebaseAuthDataSource(firebaseAuth: auth);
      for (var i = 0; i < 2; i++) {
        await expectLater(
          source.sendOTP('+15555550123'),
          throwsA(isA<AuthException>()),
        );
      }
      expect(calls, 2);
      for (var i = 0; i < 110; i++) {
        SmsRequestDiagnostics.record(
          1,
          'sdk-error',
          code: 'secret +15555550123',
        );
      }
      expect(SmsRequestDiagnostics.events.length, 100);
      expect(
        SmsRequestDiagnostics.events.toString(),
        isNot(contains('1555555')),
      );
      expect(SmsRequestDiagnostics.events.last['code'], 'unknown-error');
    },
  );
  test('provider hints retain only explicit safe categories', () {
    expect(
      SmsRequestDiagnostics.restrictionHint(
        'We have blocked all requests from this device due to unusual activity. +15555550123',
      ),
      'device-unusual-activity',
    );
    expect(
      SmsRequestDiagnostics.restrictionHint(
        'Too many SMS messages sent to this phone number.',
      ),
      'phone-sms-limit',
    );
    expect(
      SmsRequestDiagnostics.restrictionHint('unknown details'),
      'unspecified',
    );
  });
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
