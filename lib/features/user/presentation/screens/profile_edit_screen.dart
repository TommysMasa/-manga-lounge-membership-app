import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/user.dart';
import '../providers/user_state.dart';
import '../providers/user_state_notifier.dart';
import '../widgets/profile_form/profile_form_exports.dart';

/// Screen for editing user profile information
///
/// This is a thin wrapper around ProfileForm that handles:
/// - Loading user state and showing appropriate UI states
/// - Navigation bar with back button and conditional save
/// - Unsaved changes confirmation on back navigation
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  User? _initialUser;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Read user state once during initialization
    final userState = ref.read(userStateProvider);
    userState.when(
      initial: () {
        setState(() {
          _error = 'No user data';
          _isLoading = false;
        });
      },
      loading: () {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      },
      error: (message) {
        setState(() {
          _error = message;
          _isLoading = false;
        });
      },
      noUser: () {
        setState(() {
          _error = 'No user data available';
          _isLoading = false;
        });
      },
      loaded: (user) {
        setState(() {
          _initialUser = user;
          _isLoading = false;
          _error = null;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildScaffold(
        context,
        child: const Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_error != null) {
      return _buildScaffold(
        context,
        child: Center(child: Text(_error!)),
      );
    }

    if (_initialUser == null) {
      return _buildScaffold(
        context,
        child: const Center(child: Text('No user data available')),
      );
    }

    return _ProfileEditContent(user: _initialUser!);
  }

  Widget _buildScaffold(BuildContext context, {required Widget child}) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        middle: const Text(
          'Edit Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}

/// Content widget when user is loaded
///
/// Separated to handle PopScope and form state properly.
class _ProfileEditContent extends ConsumerStatefulWidget {
  const _ProfileEditContent({required this.user});

  final User user;

  @override
  ConsumerState<_ProfileEditContent> createState() => _ProfileEditContentState();
}

class _ProfileEditContentState extends ConsumerState<_ProfileEditContent> {
  Future<bool> _onWillPop(BuildContext context, WidgetRef ref) async {
    final formState = ref.read(profileFormProvider);
    if (!formState.hasChanges) return true;

    final shouldPop = await AppTheme.showConfirmation(
      context,
      title: 'Discard Changes?',
      message: 'You have unsaved changes. Do you want to discard them?',
      confirmText: 'Discard',
      isDestructive: true,
    );

    return shouldPop ?? false;
  }

  void _onSaveSuccess() {
    print('DEBUG: Save succeeded');

    // Show notification
    AppTheme.showNotification(
      context,
      message: 'Profile updated successfully',
    );

    // User can manually go back with the back button
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(profileFormProvider);
    // Get email and phone number from Firebase Auth instead of User entity
    final authRepo = ref.read(authRepositoryProvider);
    final phoneNumber = authRepo.getCurrentUserPhoneNumber() ?? '';
    final email = authRepo.getCurrentUserEmail() ?? '';

    return PopScope(
      canPop: !formState.hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop(context, ref);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: AppTheme.backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: AppTheme.backgroundColor,
          border: null,
          middle: const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              if (formState.hasChanges) {
                final shouldPop = await _onWillPop(context, ref);
                if (shouldPop && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Icon(CupertinoIcons.back, color: AppTheme.textPrimary),
          ),
        ),
        child: SafeArea(
          child: ProfileForm(
            mode: ProfileFormMode.edit,
            phoneNumber: phoneNumber,
            email: email,
            uid: widget.user.uid,
            initialUser: widget.user,
            onSuccess: _onSaveSuccess,
          ),
        ),
      ),
    );
  }
}
