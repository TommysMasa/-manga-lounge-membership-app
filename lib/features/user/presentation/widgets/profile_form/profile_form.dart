import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/form/form_widgets.dart';
import '../../../domain/constants.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/value_objects/gender.dart';
import 'profile_form_notifier.dart';
import 'profile_form_state.dart';

/// Unified profile form widget for create and edit modes
///
/// This widget handles the form UI for both:
/// - Registration (create mode): New user registration after phone verification
/// - Profile Edit (edit mode): Editing existing user profile
///
/// The parent screen is responsible for:
/// - Providing initial data (User for edit, phoneNumber for create)
/// - Handling navigation after successful submission
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({
    super.key,
    required this.mode,
    required this.phoneNumber,
    required this.uid,
    required this.onSuccess,
    this.initialUser,
  });

  /// Form mode (create or edit)
  final ProfileFormMode mode;

  /// Phone number (read-only field)
  final String phoneNumber;

  /// User ID for submission
  final String uid;

  /// Callback when form submission succeeds
  final VoidCallback onSuccess;

  /// Initial user data (required for edit mode)
  final User? initialUser;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();

    // Initialize form after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });

    // Add listeners to sync with notifier
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _emailController.addListener(_onEmailChanged);
  }

  void _initializeForm() {
    final notifier = ref.read(profileFormProvider.notifier);

    if (widget.mode == ProfileFormMode.edit && widget.initialUser != null) {
      notifier.initForEdit(widget.initialUser!);
      _firstNameController.text = widget.initialUser!.firstName;
      _lastNameController.text = widget.initialUser!.lastName;
      _emailController.text = widget.initialUser!.email;
    } else {
      notifier.initForCreate(phoneNumber: widget.phoneNumber);
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFirstNameChanged);
    _lastNameController.removeListener(_onLastNameChanged);
    _emailController.removeListener(_onEmailChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _onFirstNameChanged() {
    ref
        .read(profileFormProvider.notifier)
        .updateFirstName(_firstNameController.text);
  }

  void _onLastNameChanged() {
    ref
        .read(profileFormProvider.notifier)
        .updateLastName(_lastNameController.text);
  }

  void _onEmailChanged() {
    ref.read(profileFormProvider.notifier).updateEmail(_emailController.text);
  }

  Future<void> _selectGender() async {
    final formState = ref.read(profileFormProvider);
    final currentIndex = formState.gender?.index ?? 0;

    final result = await AppTheme.showPickerModal(
      context,
      options: Gender.displayNames,
      initialIndex: currentIndex,
    );

    if (result != null) {
      ref.read(profileFormProvider.notifier).updateGenderFromIndex(result);
    }
  }

  Future<void> _selectDateOfBirth() async {
    final formState = ref.read(profileFormProvider);
    final currentDate =
        formState.dateOfBirth ?? UserConstants.defaultDateOfBirth;

    final picked = await AppTheme.showDatePickerModal(
      context,
      initialDate: currentDate,
      minimumDate: UserConstants.minimumBirthDate,
      maximumDate: UserConstants.maximumBirthDate,
    );

    if (picked != null) {
      ref.read(profileFormProvider.notifier).updateDateOfBirth(picked);
    }
  }

  Future<void> _submit() async {
    final result = await ref
        .read(profileFormProvider.notifier)
        .submit(uid: widget.uid);
    if (!mounted) return;

    result.fold(
      (failure) => AppTheme.showNotification(
        context,
        message: failure.message,
        isError: true,
      ),
      (_) {
        AppTheme.showNotification(
          context,
          message: widget.mode == ProfileFormMode.create
              ? 'Registration successful'
              : 'Profile updated successfully',
        );
        widget.onSuccess();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(profileFormProvider);
    final isLoading = formState.isSubmitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info message (edit mode only)
          if (formState.isEditMode) ...[
            _buildInfoMessage(),
            const SizedBox(height: 24),
          ],

          // First Name
          LabeledTextField(
            label: 'First Name',
            controller: _firstNameController,
            placeholder: 'Enter first name',
            prefixIcon: CupertinoIcons.person,
            textCapitalization: TextCapitalization.words,
            enabled: !isLoading,
            focusNode: _firstNameFocus,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _lastNameFocus.requestFocus(),
          ),

          const SizedBox(height: 16),

          // Last Name
          LabeledTextField(
            label: 'Last Name',
            controller: _lastNameController,
            placeholder: 'Enter last name',
            prefixIcon: CupertinoIcons.person,
            textCapitalization: TextCapitalization.words,
            enabled: !isLoading,
            focusNode: _lastNameFocus,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _emailFocus.requestFocus(),
          ),

          const SizedBox(height: 16),

          // Email
          LabeledTextField(
            label: 'Email',
            controller: _emailController,
            placeholder: 'Enter email',
            prefixIcon: CupertinoIcons.mail,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _emailFocus.unfocus(),
          ),

          const SizedBox(height: 16),

          // Gender
          LabeledPickerField(
            label: 'Gender',
            value: formState.gender?.displayName ?? '',
            placeholder: 'Select gender',
            prefixIcon: CupertinoIcons.person_2,
            onTap: _selectGender,
            enabled: !isLoading,
          ),

          const SizedBox(height: 16),

          // Date of Birth
          LabeledPickerField(
            label: 'Date of Birth',
            value: formState.dateOfBirth != null
                ? DateFormat('MMM dd, yyyy').format(formState.dateOfBirth!)
                : '',
            placeholder: 'Select date of birth',
            prefixIcon: CupertinoIcons.calendar,
            onTap: _selectDateOfBirth,
            enabled: !isLoading,
          ),

          const SizedBox(height: 16),

          // Phone Number (read-only)
          LabeledReadonlyField(
            label: 'Phone Number',
            value: formState.phoneNumber,
            prefixIcon: CupertinoIcons.phone,
          ),

          const SizedBox(height: 32),

          // Submit Button
          _buildSubmitButton(formState, isLoading),

          // Cancel Button (edit mode only)
          if (formState.isEditMode) ...[
            const SizedBox(height: 16),
            _buildCancelButton(isLoading),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            color: AppTheme.primaryBlue,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your phone number cannot be changed',
              style: TextStyle(fontSize: 14, color: AppTheme.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ProfileFormState formState, bool isLoading) {
    final buttonEnabled = formState.canSubmit;
    final buttonLabel = formState.isCreateMode
        ? 'Complete Registration'
        : 'Save Changes';

    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: buttonEnabled ? _submit : null,
        color: buttonEnabled
            ? AppTheme.primaryBlue
            : CupertinoColors.systemGrey3,
        borderRadius: BorderRadius.circular(30),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: isLoading
            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
            : Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildCancelButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Text(
          'Cancel',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
