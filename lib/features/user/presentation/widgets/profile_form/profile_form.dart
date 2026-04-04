import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/providers.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/widgets/form/form_widgets.dart';
import '../../../domain/constants.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/usecases/delete_account_usecase.dart';
import '../../../domain/value_objects/gender.dart';
import '../../../domain/value_objects/referral_source.dart';
import 'profile_form_notifier.dart';
import 'profile_form_state.dart';

/// Unified profile form widget for create and edit modes
///
/// This widget handles the form UI for both:
/// - Registration (create mode): New user registration after phone verification
/// - Profile Edit (edit mode): Editing existing user profile
///
/// The parent screen is responsible for:
/// - Providing initial data (User for edit, phoneNumber/email for both modes)
/// - Handling navigation after successful submission
///
/// Note: Email and phone number are managed by Firebase Auth, not Firestore
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({
    super.key,
    required this.mode,
    required this.phoneNumber,
    required this.uid,
    required this.onSuccess,
    this.initialUser,
    this.email,
  });

  /// Form mode (create or edit)
  final ProfileFormMode mode;

  /// Phone number (read-only field) - from Firebase Auth
  final String phoneNumber;

  /// Email address (read-only field) - from Firebase Auth, optional for create mode
  final String? email;

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

    // Set initial text values BEFORE adding listeners (so listeners don't fire)
    if (widget.mode == ProfileFormMode.edit && widget.initialUser != null) {
      _firstNameController.text = widget.initialUser!.firstName;
      _lastNameController.text = widget.initialUser!.lastName;
    }

    // Add listeners AFTER setting initial values
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _emailController.addListener(_onEmailChanged);

    // Initialize form provider state after first frame (to avoid modifying provider during build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    final notifier = ref.read(profileFormProvider.notifier);

    if (widget.mode == ProfileFormMode.edit && widget.initialUser != null) {
      notifier.initForEdit(
        user: widget.initialUser!,
        email: widget.email ?? '',
        phoneNumber: widget.phoneNumber,
      );
      _firstNameController.text = widget.initialUser!.firstName;
      _lastNameController.text = widget.initialUser!.lastName;
    } else {
      notifier.initForCreate(phoneNumber: widget.phoneNumber);
    }
  }

  @override
  void didUpdateWidget(ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If phone number changed, update the form state
    if (widget.phoneNumber != oldWidget.phoneNumber) {
      ref.read(profileFormProvider.notifier).updatePhoneNumber(widget.phoneNumber);
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
    ref
        .read(profileFormProvider.notifier)
        .updateEmail(_emailController.text);
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

  Future<void> _selectReferralSource() async {
    final formState = ref.read(profileFormProvider);
    final currentIndex = formState.referralSource?.index ?? 0;

    final result = await AppTheme.showPickerModal(
      context,
      options: ReferralSource.displayNames,
      initialIndex: currentIndex,
    );

    if (result != null) {
      ref.read(profileFormProvider.notifier).updateReferralSourceFromIndex(result);
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
    print('DEBUG _submit: Starting submit');

    final result = await ref
        .read(profileFormProvider.notifier)
        .submit(uid: widget.uid);
    print('DEBUG _submit: Submit completed, result: ${result.isRight() ? "success" : "failure"}');
    print('DEBUG _submit: Widget mounted: $mounted');

    result.fold(
      (failure) {
        print('DEBUG _submit: Failure - ${failure.message}');
        if (mounted) {
          AppTheme.showNotification(
            context,
            message: failure.message,
            isError: true,
          );
        }
      },
      (_) {
        print('DEBUG _submit: Success - calling onSuccess callback');
        widget.onSuccess();
      },
    );
  }

  Future<void> _deleteAccount() async {
    // Step 1: Show confirmation dialog
    final wantsToDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (wantsToDelete != true) return;

    // Step 2: Show phone number verification dialog
    final phoneNumberController = TextEditingController();
    final phoneConfirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Verify Phone Number'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            const Text(
              'To confirm, please enter your phone number:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: phoneNumberController,
              placeholder: 'Phone number',
              keyboardType: TextInputType.phone,
              prefix: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(CupertinoIcons.phone, size: 20),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );

    if (phoneConfirmed != true) {
      phoneNumberController.dispose();
      return;
    }

    // Verify phone number (without country code)
    final enteredPhone = phoneNumberController.text.trim();
    phoneNumberController.dispose();

    final formState = ref.read(profileFormProvider);
    final registeredPhone = formState.phoneNumber;

    // Remove country code from registered phone for comparison
    final registeredPhoneWithoutCountryCode = _removeCountryCode(registeredPhone);

    if (enteredPhone != registeredPhoneWithoutCountryCode) {
      if (!mounted) return;
      AppTheme.showNotification(
        context,
        message: 'Phone number does not match. Account deletion cancelled.',
        isError: true,
      );
      return;
    }

    // Execute deletion
    if (!mounted) return;

    final userRepository = ref.read(userRepositoryProvider);
    final deleteUseCase = DeleteAccountUseCase(userRepository);

    final result = await deleteUseCase.call(widget.uid);

    if (!mounted) return;

    result.fold(
      (failure) {
        AppTheme.showNotification(
          context,
          message: 'Failed to delete account: ${failure.message}',
          isError: true,
        );
      },
      (_) {
        // Account deleted successfully
        // Navigate to login screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  /// Remove country code from phone number (e.g., "+1 6505551234" -> "6505551234")
  String _removeCountryCode(String phoneNumber) {
    // Remove all non-digit characters
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // If starts with country code (1-3 digits), remove it
    // Common country codes: +1 (US/CA), +81 (JP), +86 (CN), +44 (UK), etc.
    if (digitsOnly.length > 10) {
      // Assume country code is 1-3 digits, phone number is typically 10 digits
      return digitsOnly.substring(digitsOnly.length - 10);
    }

    return digitsOnly;
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
            textInputAction: TextInputAction.done,
          ),

          const SizedBox(height: 16),

          // Email - only show in create mode
          if (formState.isCreateMode) ...[
            LabeledTextField(
              label: 'Email',
              controller: _emailController,
              placeholder: 'Enter email address',
              prefixIcon: CupertinoIcons.mail,
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading,
              focusNode: _emailFocus,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
          ],

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

          // Referral Source (Optional)
          LabeledPickerField(
            label: 'How did you hear about us? (Optional)',
            value: formState.referralSource?.displayName ?? '',
            placeholder: 'Select option',
            prefixIcon: CupertinoIcons.info_circle,
            onTap: _selectReferralSource,
            enabled: !isLoading,
          ),

          const SizedBox(height: 16),

          // Phone Number - only show in create mode
          if (formState.isCreateMode) ...[
            LabeledReadonlyField(
              label: 'Phone Number',
              value: formState.phoneNumber,
              prefixIcon: CupertinoIcons.phone,
            ),
            const SizedBox(height: 16),
          ],

          const SizedBox(height: 16),

          // Submit Button
          _buildSubmitButton(formState, isLoading),

          // Cancel Button (edit mode only)
          if (formState.isEditMode) ...[
            const SizedBox(height: 16),
            _buildCancelButton(isLoading),
          ],

          // Delete Account Button (edit mode only)
          if (formState.isEditMode) ...[
            const SizedBox(height: 48),
            _buildDeleteAccountButton(isLoading),
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
              'To change your phone number or email address, use the settings screen',
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

  Widget _buildDeleteAccountButton(bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: CupertinoButton(
        onPressed: isLoading ? null : _deleteAccount,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.destructiveRed,
          ),
        ),
      ),
    );
  }
}
