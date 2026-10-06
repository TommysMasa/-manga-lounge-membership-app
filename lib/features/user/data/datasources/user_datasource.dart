import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../../core/error/exceptions.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/entities/user.dart';
import '../../domain/value_objects/user_status.dart';

/// Data source for User operations with Firestore
///
/// This class:
/// 1. Handles all Firestore operations for users
/// 2. Converts between Firestore documents and User entities
/// 3. Throws domain-specific exceptions (not Failures)
/// 4. Repository layer will convert exceptions to Failures
abstract class UserDataSource {
  /// Create a new user profile in Firestore
  Future<User> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    String? referralSource,
    String? zipcode,
  });

  /// Get user by ID from Firestore
  Future<User> getUserById(String uid);

  /// Get current authenticated user's profile
  Future<User> getCurrentUser();

  /// Update existing user profile in Firestore
  Future<User> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? referralSource,
    String? zipcode,
    UserStatus? status,
  });

  /// Check if user profile exists in Firestore
  Future<bool> checkUserProfileExists(String uid);

  /// Watch user changes in real-time
  Stream<User> watchUser(String uid);

  /// Request server-side erasure; business history is anonymized and retained.
  Future<void> deleteAccount(String uid);
}

/// Implementation of UserDataSource using Firestore
class UserDataSourceImpl implements UserDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth auth;
  final FirebaseFunctions functions;

  UserDataSourceImpl({
    required this.firestore,
    required this.auth,
    required this.functions,
  });

  @override
  Future<User> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    String? referralSource,
    String? zipcode,
  }) async {
    try {
      if (auth.currentUser?.uid != uid) {
        throw const AuthException('Please sign in to your own account.');
      }
      await functions.httpsCallable('createMemberProfile').call({
        'firstName': firstName,
        'lastName': lastName,
        'gender': gender,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'referralSource': referralSource,
        'zipcode': zipcode,
      });
      return await getUserById(uid);
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to create user profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Unexpected error creating user profile: $e',
      );
    }
  }

  @override
  Future<User> getUserById(String uid) async {
    try {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        throw UserNotFoundException('User with ID $uid not found');
      }

      final data = doc.data();
      if (data == null) {
        throw FirestoreException(message: 'User document data is null');
      }

      // Add uid to the data map since it's not stored in the document
      data['uid'] = doc.id;

      return User.fromJson(data);
    } on UserNotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to get user: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(message: 'Unexpected error getting user: $e');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser == null) {
        throw const AuthException(
          'No authenticated user',
          'no-authenticated-user',
        );
      }

      return await getUserById(currentUser.uid);
    } on AuthException {
      rethrow;
    } on UserNotFoundException {
      rethrow;
    } catch (e) {
      throw FirestoreException(message: 'Failed to get current user: $e');
    }
  }

  @override
  Future<User> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? referralSource,
    String? zipcode,
    UserStatus? status,
  }) async {
    try {
      // First, get the current user data
      final currentUser = await getUserById(uid);

      if (status != null && status != currentUser.status) {
        throw const AuthException('Visit status is managed at the store.');
      }
      // Omitted or unchanged fields never enter the write payload. In
      // particular, do not reserialize server-owned timestamps or visit state.
      final changes = <String, dynamic>{};
      void changedText(String key, String? proposed, String? existing) {
        if (proposed != null && proposed != existing) changes[key] = proposed;
      }

      changedText('firstName', firstName, currentUser.firstName);
      changedText('lastName', lastName, currentUser.lastName);
      changedText('gender', gender, currentUser.gender);
      changedText('referralSource', referralSource, currentUser.referralSource);
      changedText('zipcode', zipcode, currentUser.zipcode);
      if (dateOfBirth != null &&
          !dateOfBirth.isAtSameMomentAs(currentUser.dateOfBirth)) {
        changes['dateOfBirth'] = dateOfBirth.toIso8601String();
      }
      if (changes.isEmpty) return currentUser;
      final updatedAt = DateTime.now();
      changes['updatedAt'] = updatedAt.toIso8601String();
      final updatedUser = currentUser.copyWith(
        firstName: firstName ?? currentUser.firstName,
        lastName: lastName ?? currentUser.lastName,
        gender: gender ?? currentUser.gender,
        dateOfBirth: dateOfBirth ?? currentUser.dateOfBirth,
        referralSource: referralSource ?? currentUser.referralSource,
        zipcode: zipcode ?? currentUser.zipcode,
        updatedAt: updatedAt,
      );
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(changes);

      return updatedUser;
    } on UserNotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update user profile: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Unexpected error updating user profile: $e',
      );
    }
  }

  @override
  Future<bool> checkUserProfileExists(String uid) async {
    try {
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();

      return doc.exists;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to check if user exists: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Unexpected error checking user existence: $e',
      );
    }
  }

  @override
  Stream<User> watchUser(String uid) {
    try {
      return firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              throw UserNotFoundException('User with ID $uid not found');
            }

            final data = snapshot.data();
            if (data == null) {
              throw FirestoreException(message: 'User document data is null');
            }

            // Add uid to the data map
            data['uid'] = snapshot.id;
            return User.fromJson(data);
          });
    } catch (e) {
      throw FirestoreException(message: 'Failed to watch user: $e');
    }
  }

  @override
  Future<void> deleteAccount(String uid) async {
    try {
      if (auth.currentUser?.uid != uid) {
        throw const AuthException('Please sign in to your own account.');
      }
      // Refresh the token after SMS reauthentication so auth_time is current.
      await auth.currentUser!.getIdToken(true);
      final response = await functions
          .httpsCallable(
            'deleteMyAccount',
            options: HttpsCallableOptions(timeout: const Duration(minutes: 9)),
          )
          .call({'confirm': true});
      if (response.data is! Map || response.data['accepted'] != true) {
        throw const FirestoreException(
          message: 'The deletion request was not confirmed. Please try again.',
        );
      }
      await auth.signOut();
    } on FirebaseFunctionsException catch (e) {
      if (e.details is Map && e.details['reason'] == 'recent-login-required') {
        throw const ReauthenticationRequiredException(
          'Please verify your phone again before deleting your account.',
        );
      }
      throw FirestoreException(
        message: e.message ?? 'Account deletion failed.',
        code: e.code,
      );
    } on AuthException {
      rethrow;
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to delete account: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Unexpected error deleting account: $e',
      );
    }
  }
}
