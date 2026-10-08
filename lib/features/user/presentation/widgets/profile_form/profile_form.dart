import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/providers.dart';
import '../../../../../shared/theme/app_theme.dart';
import '../../../../../shared/utils/launch_url.dart';
import '../../../../subscription/presentation/providers/subscription_providers.dart';
import 'package:flutter/foundation.dart';
import '../../../../../shared/widgets/form/form_widgets.dart';
import '../../../domain/constants.dart';
import '../../../domain/entities/user.dart';
import '../../providers/account_deletion_controller.dart';
import '../../../domain/value_objects/gender.dart';
import '../../../domain/value_objects/referral_source.dart';
import 'profile_form_notifier.dart';
import 'profile_form_state.dart';
import 'delete_account_sms_dialog.dart';

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
  late TextEditingController _zipcodeController;

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _zipcodeFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _zipcodeController = TextEditingController();

    // Set initial text values BEFORE adding listeners (so listeners don't fire)
    if (widget.mode == ProfileFormMode.edit && widget.initialUser != null) {
      _firstNameController.text = widget.initialUser!.firstName;
      _lastNameController.text = widget.initialUser!.lastName;
      _zipcodeController.text = widget.initialUser!.zipcode ?? '';
    }

    // Add listeners AFTER setting initial values
    _firstNameController.addListener(_onFirstNameChanged);
    _lastNameController.addListener(_onLastNameChanged);
    _emailController.addListener(_onEmailChanged);
    _zipcodeController.addListener(_onZipcodeChanged);

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
      _zipcodeController.text = widget.initialUser!.zipcode ?? '';
    } else {
      notifier.initForCreate(phoneNumber: widget.phoneNumber);
    }
  }

  @override
  void didUpdateWidget(ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If phone number changed, update the form state
    if (widget.phoneNumber != oldWidget.phoneNumber) {
      ref
          .read(profileFormProvider.notifier)
          .updatePhoneNumber(widget.phoneNumber);
    }
  }

  @override
  void dispose() {
    _firstNameController.removeListener(_onFirstNameChanged);
    _lastNameController.removeListener(_onLastNameChanged);
    _emailController.removeListener(_onEmailChanged);
    _zipcodeController.removeListener(_onZipcodeChanged);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _zipcodeController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _zipcodeFocus.dispose();
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

  void _onZipcodeChanged() {
    ref
        .read(profileFormProvider.notifier)
        .updateZipcode(_zipcodeController.text);
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
      ref
          .read(profileFormProvider.notifier)
          .updateReferralSourceFromIndex(result);
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
      (failure) {
        if (mounted) {
          AppTheme.showNotification(
            context,
            message: failure.message,
            isError: true,
          );
        }
      },
      (_) {
        widget.onSuccess();
      },
    );
  }

  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    if (_isDeleting) return;
    setState(() => _isDeleting = true);
    try {
      await _performDeleteAccount();
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  Future<void> _performDeleteAccount() async {
    // Step 1: Show confirmation dialog
    final wantsToDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Your profile and personal information will be deleted. Visit and payment history may be retained for business records. This cannot be undone. Please check out at the store first.\n\nDeleting your account does not cancel an Apple or Google subscription. Cancel it in subscription settings to stop future billing.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () async {
              final info = ref.read(customerInfoProvider).value;
              final url =
                  info?.managementURL ??
                  (defaultTargetPlatform == TargetPlatform.android
                      ? 'https://play.google.com/store/account/subscriptions'
                      : 'https://apps.apple.com/account/subscriptions');
              try {
                await launchURL(url);
              } catch (_) {
                if (mounted) {
                  AppTheme.showNotification(
                    this.context,
                    message: 'Could not open subscription settings.',
                    isError: true,
                  );
                }
              }
            },
            child: const Text('Manage Subscription'),
          ),
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

    // SMS verification proves possession; typing a phone number is not proof.
    if (!mounted) return;
    final authRepo = ref.read(authRepositoryProvider);
    final phone = authRepo.getCurrentUserPhoneNumber();
    if (phone == null) {
      AppTheme.showNotification(
        context,
        message: 'No verified phone number. Please contact support.',
        isError: true,
      );
      return;
    }
    final sent = await authRepo.sendOTP(phone);
    if (!mounted) return;
    final sendError = sent.fold((failure) => failure, (_) => null);
    if (sendError != null) {
      AppTheme.showNotification(
        context,
        message: sendError.message,
        isError: true,
      );
      return;
    }
    final verificationId = sent.fold((_) => '', (value) => value);
    if (verificationId.isEmpty) return;
    final confirmation =
        await showCupertinoDialog<DeleteAccountSmsConfirmation>(
          context: context,
          builder: (_) => DeleteAccountSmsDialog(
            initialVerificationId: verificationId,
            resend: () => authRepo.sendOTP(phone),
          ),
        );
    if (confirmation == null || !mounted) return;
    final verified = await authRepo.reauthenticateWithPhoneNumber(
      verificationId: confirmation.verificationId,
      otpCode: confirmation.code,
    );
    if (!mounted) return;
    final verificationError = verified.fold((failure) => failure, (_) => null);
    if (verificationError != null) {
      AppTheme.showNotification(
        context,
        message: verificationError.message,
        isError: true,
      );
      return;
    }

    // Execute deletion
    if (!mounted) return;

    FocusManager.instance.primaryFocus?.unfocus();
    await ref.read(accountDeletionProvider.notifier).delete(widget.uid);
    // The root deletion screen owns completion; never pop a disposed profile
    // navigator after Firebase sign-out redirects the route tree.
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(profileFormProvider);
    final isLoading = formState.isSubmitting || _isDeleting;

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

          // Zipcode (Optional)
          LabeledTextField(
            label: 'Zipcode (Optional)',
            controller: _zipcodeController,
            placeholder: 'Enter 00000 if international',
            prefixIcon: CupertinoIcons.location,
            keyboardType: TextInputType.number,
            enabled: !isLoading,
            focusNode: _zipcodeFocus,
            textInputAction: TextInputAction.done,
            maxLength: 5,
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
