import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userStateProvider);

    return userState.when(
      initial: () => _buildScaffold(
        context,
        child: const Center(child: Text('Loading...')),
      ),
      loading: () => _buildScaffold(
        context,
        child: const Center(child: CupertinoActivityIndicator()),
      ),
      error: (message) => _buildScaffold(
        context,
        child: Center(child: Text(message)),
      ),
      noUser: () => _buildScaffold(
        context,
        child: const Center(child: Text('No user data available')),
      ),
      loaded: (user) => _ProfileEditContent(user: user),
    );
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
class _ProfileEditContent extends ConsumerWidget {
  const _ProfileEditContent({required this.user});

  final User user;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(profileFormProvider);

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
          trailing: formState.hasChanges
              ? CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: formState.isSubmitting ? null : null,
                  child: Text(
                    'Save',
                    style: TextStyle(
                      color: formState.isSubmitting
                          ? AppTheme.textSecondary
                          : AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
        child: SafeArea(
          child: ProfileForm(
            mode: ProfileFormMode.edit,
            phoneNumber: user.phoneNumber,
            uid: user.uid,
            initialUser: user,
            onSuccess: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
