import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/error/failures.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/gender.dart';
import '../../../domain/value_objects/referral_source.dart';
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
  /// Note: Email and phone number are now managed by Firebase Auth, not User entity
  void initForEdit({
    required User user,
    required String email,
    required String phoneNumber,
  }) {
    state = ProfileFormState.forEdit(
      firstName: user.firstName,
      lastName: user.lastName,
      email: email,
      genderString: user.gender,
      dateOfBirth: user.dateOfBirth,
      phoneNumber: phoneNumber,
      referralSourceString: user.referralSource,
      zipcode: user.zipcode,
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

  /// Update referral source
  void updateReferralSource(ReferralSource? source) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(referralSource: source)
        : true;

    state = state.copyWith(
      referralSource: source,
      hasChanges: hasChanges,
      errorMessage: null,
    );
  }

  /// Update referral source from index (for picker)
  void updateReferralSourceFromIndex(int index) {
    try {
      final source = ReferralSource.fromIndex(index);
      updateReferralSource(source);
    } catch (e) {
      debugPrint('Invalid referral source index: $index');
    }
  }

  /// Update zipcode
  void updateZipcode(String value) {
    final hasChanges = state.isEditMode
        ? _hasAnyFieldChanged(zipcode: value)
        : true;

    state = state.copyWith(
      zipcode: value,
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
      print('DEBUG ProfileForm: Creating profile');
      // Note: Email and phoneNumber are managed separately by Firebase Auth
      // They are NOT stored in the Firestore User document
      result = await userNotifier.createProfile(
        uid: uid,
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        gender: state.genderString ?? '',
        dateOfBirth: state.dateOfBirth!,
        referralSource: state.referralSourceString,
        zipcode: state.zipcode.trim().isEmpty ? null : state.zipcode.trim(),
      );
    } else {
      // Note: Email and phoneNumber updates must be handled separately via Firebase Auth
      // This only updates the Firestore User document fields
      result = await userNotifier.updateProfile(
        uid: uid,
        firstName: state.firstName.trim(),
        lastName: state.lastName.trim(),
        gender: state.genderString,
        dateOfBirth: state.dateOfBirth,
        referralSource: state.referralSourceString,
        zipcode: state.zipcode.trim().isEmpty ? null : state.zipcode.trim(),
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
    ReferralSource? referralSource,
    String? zipcode,
  }) {
    // Use provided value or current state value
    final currentFirstName = firstName ?? state.firstName;
    final currentLastName = lastName ?? state.lastName;
    final currentEmail = email ?? state.email;
    final currentGender = gender ?? state.gender;
    final currentDateOfBirth = dateOfBirth ?? state.dateOfBirth;
    final currentReferralSource = referralSource ?? state.referralSource;
    final currentZipcode = zipcode ?? state.zipcode;

    // Compare each field with its initial value
    if (currentFirstName != state.initialFirstName) return true;
    if (currentLastName != state.initialLastName) return true;
    if (currentEmail != state.initialEmail) return true;
    if (currentGender != state.initialGender) return true;
    if (currentDateOfBirth != state.initialDateOfBirth) return true;
    if (currentReferralSource != state.initialReferralSource) return true;
    if (currentZipcode != state.initialZipcode) return true;

    return false;
  }
}
