import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import 'user_state.dart';

part 'user_state_notifier.g.dart';

/// State notifier for managing user-related state using Riverpod codegen
///
/// This class:
/// 1. Manages the user state for the UI
/// 2. Calls use cases to perform business logic
/// 3. Updates state based on use case results
/// 4. Handles both success and failure scenarios
@riverpod
class UserStateNotifier extends _$UserStateNotifier {
  @override
  UserState build() {
    // Return initial state
    return const UserState.initial();
  }

  /// Load current authenticated user's profile
  Future<void> loadCurrentUser() async {
    state = const UserState.loading();

    final getCurrentUser = ref.read(getCurrentUserProvider);
    final result = await getCurrentUser();

    // Check if provider is still mounted after async operation
    if (!ref.mounted) return;

    result.fold(
      (failure) => state = UserState.error(failure.message),
      (user) => state = UserState.loaded(user),
    );
  }

  /// Load user by ID
  Future<void> loadUser(String uid) async {
    state = const UserState.loading();

    final getUser = ref.read(getUserProvider);
    final result = await getUser(uid);

    // Check if provider is still mounted after async operation
    if (!ref.mounted) return;

    result.fold(
      (failure) => state = UserState.error(failure.message),
      (user) => state = UserState.loaded(user),
    );
  }

  /// Create a new user profile
  Future<Either<Failure, User>> createProfile({
    required String uid,
    required String firstName,
    required String lastName,
    required String gender,
    required DateTime dateOfBirth,
    String? referralSource,
    String? zipcode,
  }) async {
    state = const UserState.loading();

    final createUserProfile = ref.read(createUserProfileProvider);
    final result = await createUserProfile(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      referralSource: referralSource,
      zipcode: zipcode,
    );

    // Update state if provider is still mounted
    if (ref.mounted) {
      result.fold(
        (failure) => state = UserState.error(failure.message),
        (user) => state = UserState.loaded(user),
      );
    }

    return result;
  }

  /// Update user profile
  Future<Either<Failure, User>> updateProfile({
    required String uid,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? dateOfBirth,
    String? referralSource,
    String? zipcode,
  }) async {
    state = const UserState.loading();

    final updateUserProfile = ref.read(updateUserProfileProvider);
    final result = await updateUserProfile(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      referralSource: referralSource,
      zipcode: zipcode,
    );

    // Update state if provider is still mounted
    if (ref.mounted) {
      result.fold(
        (failure) => state = UserState.error(failure.message),
        (user) => state = UserState.loaded(user),
      );
    }

    return result;
  }

  /// Check if user profile exists
  Future<bool> profileExists(String uid) async {
    final checkUserProfileExists = ref.read(checkUserProfileExistsProvider);
    final result = await checkUserProfileExists(uid);

    return result.fold((failure) => false, (exists) => exists);
  }

  /// Clear the current state
  void clear() {
    state = const UserState.initial();
  }

  /// Set no user state
  void setNoUser() {
    state = const UserState.noUser();
  }
}
