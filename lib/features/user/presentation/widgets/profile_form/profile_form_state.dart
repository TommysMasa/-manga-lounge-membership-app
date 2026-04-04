import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/constants.dart';
import '../../../domain/value_objects/gender.dart';
import '../../../domain/value_objects/referral_source.dart';

part 'profile_form_state.freezed.dart';

/// Form mode for profile form
enum ProfileFormMode {
  /// Creating a new user profile
  create,

  /// Editing an existing user profile
  edit,
}

/// State for profile form (create and edit)
///
/// Holds all form field values and form-level state.
/// Used by ProfileFormNotifier to manage form lifecycle.
@freezed
abstract class ProfileFormState with _$ProfileFormState {
  const ProfileFormState._();

  const factory ProfileFormState({
    required ProfileFormMode mode,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String email,
    Gender? gender,
    DateTime? dateOfBirth,
    ReferralSource? referralSource,
    @Default('') String phoneNumber,
    @Default(false) bool hasChanges,
    @Default(false) bool isSubmitting,
    String? errorMessage,
    // Initial values for change detection (edit mode only)
    @Default('') String initialFirstName,
    @Default('') String initialLastName,
    @Default('') String initialEmail,
    Gender? initialGender,
    DateTime? initialDateOfBirth,
    ReferralSource? initialReferralSource,
  }) = _ProfileFormState;

  /// Create initial state for registration (create mode)
  factory ProfileFormState.forCreate({required String phoneNumber}) =>
      ProfileFormState(
        mode: ProfileFormMode.create,
        phoneNumber: phoneNumber,
        dateOfBirth: UserConstants.defaultDateOfBirth,
      );

  /// Create initial state for profile edit
  factory ProfileFormState.forEdit({
    required String firstName,
    required String lastName,
    required String email,
    required String genderString,
    required DateTime dateOfBirth,
    required String phoneNumber,
    String? referralSourceString,
  }) {
    final gender = Gender.tryParse(genderString);
    final referralSource = referralSourceString != null
        ? ReferralSource.tryParse(referralSourceString)
        : null;
    return ProfileFormState(
      mode: ProfileFormMode.edit,
      firstName: firstName,
      lastName: lastName,
      email: email,
      gender: gender,
      dateOfBirth: dateOfBirth,
      referralSource: referralSource,
      phoneNumber: phoneNumber,
      // Store initial values for change detection
      initialFirstName: firstName,
      initialLastName: lastName,
      initialEmail: email,
      initialGender: gender,
      initialDateOfBirth: dateOfBirth,
      initialReferralSource: referralSource,
    );
  }

  /// Whether the form can be submitted
  bool get canSubmit {
    if (isSubmitting) return false;
    if (mode == ProfileFormMode.edit && !hasChanges) return false;
    return true;
  }

  /// Get gender as string for API calls
  String? get genderString => gender?.displayName;

  /// Get referral source as string for API calls
  String? get referralSourceString => referralSource?.name;

  /// Whether form is in edit mode
  bool get isEditMode => mode == ProfileFormMode.edit;

  /// Whether form is in create mode
  bool get isCreateMode => mode == ProfileFormMode.create;
}
