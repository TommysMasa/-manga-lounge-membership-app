import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// Check a restored session before completing a new member profile.
/// Transient failures must not log out a valid member.
Future<bool> hasLiveRegistrationSession(FirebaseAuth auth) async {
  final user = auth.currentUser;
  if (user == null) return false;
  try {
    await user.reload().timeout(const Duration(seconds: 5));
    return auth.currentUser != null;
  } on FirebaseAuthException catch (error) {
    if (!const {
      'user-not-found',
      'user-disabled',
      'user-token-expired',
      'invalid-user-token',
    }.contains(error.code)) {
      return true;
    }
    await auth.signOut();
    return false;
  } on TimeoutException {
    return true;
  }
}
