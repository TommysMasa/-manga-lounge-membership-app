import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/gender.dart';
import '../../providers/user_state_notifier.dart';
import 'profile_form_state.dart';

part 'profile_form_notifier.g.dart';

/// Notifier for managing profile form state
///
/// Handles form lifecycle for both create and edit modes:
/// - Field updates
/// - Change detection
/// - Form submission (delegates to UserStateNotifier)
@riverpod
class ProfileFormNotifier extends _$ProfileFormNotifier {
  @override
  ProfileFormState build() {
    // Initial state - will be overwritten by initForCreate or initForEdit
    return const ProfileFormState(mode: ProfileFormMode.create);
  }

  /// Initialize form for creating a new profile
  void initForCreate({required String phoneNumber}) {
    state = ProfileFormState.forCreate(phoneNumber: phoneNumber);
  }

  /// Initialize form for editing existing profile
  void initForEdit(User user) {
    state = ProfileFormState.forEdit(
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      genderString: user.gender,
      dateOfBirth: user.dateOfBirth,
      phoneNumber: user.phoneNumber,
    );
  }

  /// Update first name
  void updateFirstName(String value) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(firstName: value)
        : true;

    state = state.copyWith(
      firstName: value,
      hasChanges: hasChanges,
      errorMessage: null,
    );
  }

  /// Update last name
  void updateLastName(String value) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(lastName: value)
        : true;

    state = state.copyWith(
      lastName: value,
      hasChanges: hasChanges,
      errorMessage: null,
    );
  }

  /// Update email
  void updateEmail(String value) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(email: value)
        : true;

    state = state.copyWith(
      email: value,
      hasChanges: hasChanges,
      errorMessage: null,
    );
  }

  /// Update gender
  void updateGender(Gender gender) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(gender: gender)
        : true;

    state = state.copyWith(
      gender: gender,
      hasChanges: hasChanges,
      errorMessage: null,
    );
  }

  /// Update gender from index (for picker)
  void updateGenderFromIndex(int index) {
    try {
      final gender = Gender.fromIndex(index);
      updateGender(gender);
    } catch (e) {
      debugPrint('Invalid gender index: $index');
    }
  }

  /// Update date of birth
  void updateDateOfBirth(DateTime date) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(dateOfBirth: date)
        : true;

    state = state.copyWith(
      dateOfBirth: date,
      hasChanges: hasChanges,
      errorMessage: null,
    );
  }

  /// Update phone number
  /// Used when phone number is changed externally (e.g., from Change Phone Number screen)
  void updatePhoneNumber(String phoneNumber) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      // Don't mark as hasChanges since this is a separate update flow
    );
  }

  /// Submit the form
  ///
  /// Returns Right(unit) if successful, Left(Failure) otherwise.
  /// For create mode: calls createProfile
  /// For edit mode: calls updateProfile
  Future<Either<Failure, Unit>> submit({required String uid}) async {
    if (!state.canSubmit) {
      return const Left(ValidationFailure('Please fill in all required fields'));
    }

    state = state.copyWith(isSubmitting: true);

    final userNotifier = ref.read(userStateProvider.notifier);
    final Either<Failure, User> result;

    if (state.isCreateMode) {
      result = await userNotifier.createProfile(
        uid: uid,
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        email: state.email.trim(),
        gender: state.genderString ?? '',
        dateOfBirth: state.dateOfBirth!,
        phoneNumber: state.phoneNumber,
      );
    } else {
      result = await userNotifier.updateProfile(
        uid: uid,
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        email: state.email.trim(),
        gender: state.genderString,
        dateOfBirth: state.dateOfBirth,
      );
    }

    final isSuccess = result.isRight();

    // Check if provider is still mounted after async operation
    if (ref.mounted) {
      state = state.copyWith(
        isSubmitting: false,
        hasChanges: isSuccess ? false : state.hasChanges,
      );
    }

    return result.map((_) => unit);
  }

  /// Clear any error message
  void clearError() {
    if (ref.mounted) {
      state = state.copyWith(errorMessage: null);
    }
  }

  /// Check if any field has changed from its initial value
  ///
  /// Used in edit mode to determine if hasChanges should be true.
  /// Compares current field values with initial values stored in state.
  bool _hasAnyFieldChanged({
    String? firstName,
    String? lastName,
    String? email,
    Gender? gender,
    DateTime? dateOfBirth,
  }) {
    // Use provided value or current state value
    final currentFirstName = firstName ?? state.firstName;
    final currentLastName = lastName ?? state.lastName;
    final currentEmail = email ?? state.email;
    final currentGender = gender ?? state.gender;
    final currentDateOfBirth = dateOfBirth ?? state.dateOfBirth;

    // Compare each field with its initial value
    if (currentFirstName != state.initialFirstName) return true;
    if (currentLastName != state.initialLastName) return true;
    if (currentEmail != state.initialEmail) return true;
    if (currentGender != state.initialGender) return true;
    if (currentDateOfBirth != state.initialDateOfBirth) return true;

    return false;
  }
}
