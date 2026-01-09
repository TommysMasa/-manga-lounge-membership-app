import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/entities/user.dart';

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
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String phoneNumber,
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
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? status,
  });

  /// Check if user profile exists in Firestore
  Future<bool> checkUserProfileExists(String uid);

  /// Watch user changes in real-time
  Stream<User> watchUser(String uid);

  /// Update user check-in/check-out status
  Future<User> updateUserStatus({
    required String uid,
    required String status,
  });

  /// Delete user account completely
  /// This includes:
  /// - User document from Firestore
  /// - All related Records
  /// - Firebase Authentication account
  /// - Record deletion statistics
  Future<void> deleteAccount(String uid);

  /// Update user phone number in Firestore
  Future<void> updatePhoneNumber({
    required String uid,
    required String phoneNumber,
  });
}

/// Implementation of UserDataSource using Firestore
class UserDataSourceImpl implements UserDataSource {
  final FirebaseFirestore firestore;
  final firebase_auth.FirebaseAuth auth;

  UserDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  @override
  Future<User> createUserProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String email,
    required String gender,
    required DateTime dateOfBirth,
    required String phoneNumber,
  }) async {
    try {
      final now = DateTime.now();
      final user = User(
        uid: uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        gender: gender,
        dateOfBirth: dateOfBirth,
        phoneNumber: phoneNumber,
        status: AppConstants.statusCheckedOut,
        createdAt: now,
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(user.toJson());

      return user;
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
      throw FirestoreException(
        message: 'Unexpected error getting user: $e',
      );
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
      throw FirestoreException(
        message: 'Failed to get current user: $e',
      );
    }
  }

  @override
  Future<User> updateUserProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? email,
    String? gender,
    DateTime? dateOfBirth,
    String? status,
  }) async {
    try {
      // First, get the current user data
      final currentUser = await getUserById(uid);

      // Create updated user with new values or keep existing ones
      final updatedUser = currentUser.copyWith(
        firstName: firstName ?? currentUser.firstName,
        lastName: lastName ?? currentUser.lastName,
        email: email ?? currentUser.email,
        gender: gender ?? currentUser.gender,
        dateOfBirth: dateOfBirth ?? currentUser.dateOfBirth,
        status: status ?? currentUser.status,
        updatedAt: DateTime.now(),
      );

      // Update in Firestore
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updatedUser.toJson());

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
      throw FirestoreException(
        message: 'Failed to watch user: $e',
      );
    }
  }

  @override
  Future<User> updateUserStatus({
    required String uid,
    required String status,
  }) async {
    return await updateUserProfile(uid: uid, status: status);
  }

  @override
  Future<void> deleteAccount(String uid) async {
    try {
      // 1. Delete user document from Firestore
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .delete();

      // 2. Delete all related Records
      final recordsQuery = await firestore
          .collection('Records')
          .where('membershipId', isEqualTo: uid)
          .get();

      for (final doc in recordsQuery.docs) {
        await doc.reference.delete();
      }

      // 3. Record deletion statistics (monthly counter)
      final now = DateTime.now();
      final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      await firestore
          .collection('deletionStats')
          .doc(yearMonth)
          .set({
            'count': FieldValue.increment(1),
            'lastUpdated': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      // 4. Delete Firebase Authentication account
      final currentUser = auth.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        await currentUser.delete();
      }
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

  @override
  Future<void> updatePhoneNumber({
    required String uid,
    required String phoneNumber,
  }) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'phoneNumber': phoneNumber});
    } on FirebaseException catch (e) {
      throw FirestoreException(
        message: 'Failed to update phone number: ${e.message}',
        code: e.code,
      );
    } catch (e) {
      throw FirestoreException(
        message: 'Unexpected error updating phone number: $e',
      );
    }
  }
}
