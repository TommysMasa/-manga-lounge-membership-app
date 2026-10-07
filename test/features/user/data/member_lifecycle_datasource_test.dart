import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/error/exceptions.dart';
import 'package:manga_lounge/features/user/data/datasources/user_datasource.dart';

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockAuth extends Mock implements auth.FirebaseAuth {}

class MockIdentity extends Mock implements auth.User {}

class MockFunctions extends Mock implements FirebaseFunctions {}

class MockCallable extends Mock implements HttpsCallable {}

class MockResult extends Mock implements HttpsCallableResult<dynamic> {}

// Test doubles only: the pinned SDK exposes sealed reference types.
// ignore: subtype_of_sealed_class
class MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockDocument extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

// ignore: subtype_of_sealed_class
class MockSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirestore firestore;
  late MockAuth authentication;
  late MockIdentity identity;
  late MockFunctions functions;
  late MockCallable callable;
  late MockResult response;
  late MockDocument document;
  late UserDataSourceImpl source;
  late MockSnapshot rollout;
  setUp(() {
    firestore = MockFirestore();
    authentication = MockAuth();
    identity = MockIdentity();
    functions = MockFunctions();
    callable = MockCallable();
    response = MockResult();
    document = MockDocument();
    rollout = MockSnapshot();
    final config = MockCollection();
    final configDocument = MockDocument();
    when(() => firestore.collection('config')).thenReturn(config);
    when(() => config.doc('memberLifecycle')).thenReturn(configDocument);
    when(() => configDocument.get(any())).thenAnswer((_) async => rollout);
    when(() => rollout.data()).thenReturn({
      'serverOnly': !const bool.fromEnvironment('MEMBER_LIFECYCLE_PREVIEW'),
    });
    final collection = MockCollection();
    final snapshot = MockSnapshot();
    when(() => authentication.currentUser).thenReturn(identity);
    when(() => identity.uid).thenReturn('synthetic-member');
    when(
      () => identity.getIdToken(true),
    ).thenAnswer((_) async => 'synthetic-token');
    when(() => authentication.signOut()).thenAnswer((_) async {});
    when(() => firestore.collection('users')).thenReturn(collection);
    when(() => collection.doc('synthetic-member')).thenReturn(document);
    when(() => document.get()).thenAnswer((_) async => snapshot);
    when(() => document.update(any())).thenAnswer((_) async {});
    when(() => document.set(any())).thenAnswer((_) async {});
    when(() => snapshot.exists).thenReturn(true);
    when(() => snapshot.id).thenReturn('synthetic-member');
    when(() => snapshot.data()).thenAnswer(
      (_) => {
        'firstName': 'Test',
        'lastName': 'Member',
        'gender': 'Other',
        'dateOfBirth': '2000-01-01T00:00:00.000Z',
        'createdAt': '2026-10-06T12:00:00.000Z',
        'status': 'checked_in',
        'lastEntryTime': Timestamp.fromDate(DateTime.utc(2026, 10, 6, 18)),
        'isBanned': true,
        'visitCount': 3,
      },
    );
    when(
      () => functions.httpsCallable('createMemberProfile'),
    ).thenReturn(callable);
    when(
      () => functions.httpsCallable(
        'deleteMyAccount',
        options: any(named: 'options'),
      ),
    ).thenReturn(callable);
    when(() => callable.call<dynamic>(any())).thenAnswer((_) async => response);
    when(() => response.data).thenReturn({'accepted': true, 'created': true});
    source = UserDataSourceImpl(
      firestore: firestore,
      auth: authentication,
      functions: functions,
    );
  });
  test(
    'registration sends only personal fields; membership age comes back from server',
    () async {
      final user = await source.createUserProfile(
        uid: 'synthetic-member',
        firstName: 'Test',
        lastName: 'Member',
        gender: 'Other',
        dateOfBirth: DateTime.utc(2000),
      );
      final payload =
          verify(() => callable.call<dynamic>(captureAny())).captured.single
              as Map;
      expect(
        payload.keys,
        unorderedEquals([
          'firstName',
          'lastName',
          'gender',
          'dateOfBirth',
          'referralSource',
          'zipcode',
        ]),
      );
      expect(user.createdAt, DateTime.parse('2026-10-06T12:00:00.000Z'));
      verifyNever(() => document.set(any()));
    },
  );
  test(
    'before cutover registration keeps the existing app path',
    () async {
      when(() => rollout.data()).thenReturn({'serverOnly': false});
      await source.createUserProfile(
        uid: 'synthetic-member',
        firstName: 'Test',
        lastName: 'Member',
        gender: 'Other',
        dateOfBirth: DateTime.utc(2000),
      );
      final payload =
          verify(() => document.set(captureAny())).captured.single as Map;
      expect(payload['status'], 'checked_out');
      expect(payload.containsKey('isStaff'), isFalse);
      verifyNever(() => callable.call<dynamic>(any()));
    },
    skip: const bool.fromEnvironment('MEMBER_LIFECYCLE_PREVIEW'),
  );
  test(
    'name edit sends only the changed name and updatedAt, even after a visit',
    () async {
      final saved = await source.updateUserProfile(
        uid: 'synthetic-member',
        firstName: 'Edited',
        lastName: 'Member',
        gender: 'Other',
        dateOfBirth: DateTime.utc(2000),
      );
      final payload =
          verify(() => document.update(captureAny())).captured.single as Map;
      expect(payload.keys, unorderedEquals(['firstName', 'updatedAt']));
      expect(payload['firstName'], 'Edited');
      expect(
        saved.lastEntryTime!.isAtSameMomentAs(DateTime.utc(2026, 10, 6, 18)),
        isTrue,
      );
    },
  );
  test('unchanged profile does not write or change updatedAt', () async {
    await source.updateUserProfile(
      uid: 'synthetic-member',
      firstName: 'Test',
      lastName: 'Member',
      gender: 'Other',
      dateOfBirth: DateTime.utc(2000),
    );
    verifyNever(() => document.update(any()));
  });
  test('several changed profile fields send only those fields', () async {
    await source.updateUserProfile(
      uid: 'synthetic-member',
      lastName: 'Changed',
      zipcode: '90001',
    );
    final payload =
        verify(() => document.update(captureAny())).captured.single as Map;
    expect(payload.keys, unorderedEquals(['lastName', 'zipcode', 'updatedAt']));
    expect(payload['zipcode'], '90001');
  });
  test(
    'withdrawal refreshes authentication and calls only the self-erasure endpoint',
    () async {
      await source.deleteAccount('synthetic-member');
      verify(() => identity.getIdToken(true)).called(1);
      final payload = verify(
        () => callable.call<dynamic>(captureAny()),
      ).captured.single;
      expect(payload, {'confirm': true});
      verify(() => authentication.signOut()).called(1);
      verifyNever(() => firestore.collection('users'));
      verifyNever(() => firestore.collection('Records'));
      verifyNever(() => firestore.collection('deletionStats'));
      verifyNever(() => identity.delete());
    },
  );
  test(
    'wrong account cannot request deletion or sign out the current account',
    () async {
      await expectLater(
        source.deleteAccount('someone-else'),
        throwsA(isA<AuthException>()),
      );
      verifyNever(() => callable.call<dynamic>(any()));
      verifyNever(() => authentication.signOut());
    },
  );
}
