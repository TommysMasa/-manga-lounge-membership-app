import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/push_notification_config.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/router/navigation_diagnostics.dart';
import '../../../../shared/theme/app_theme.dart';
import '../widgets/profile_form/profile_form_exports.dart';

/// Screen for user registration after phone verification
///
/// This is a thin wrapper around ProfileForm that handles:
/// - Getting the authenticated user's UID and phone number
/// - Navigation bar with title and back button
/// - Navigation to home screen after successful registration
class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  String? _uid;
  String? _phoneNumber;
  bool _isInitializing = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final getCurrentUserIdUseCase = ref.read(getCurrentUserIdProvider);
    final userIdResult = await getCurrentUserIdUseCase();

    if (!mounted) return;
    userIdResult.fold(
      (failure) {
        setState(() {
          _error = failure.message;
          _isInitializing = false;
        });
      },
      (userId) {
        final firebaseAuth = ref.read(firebaseAuthProvider);
        final phoneFromAuth = firebaseAuth.currentUser?.phoneNumber ?? '';
        setState(() {
          _uid = userId;
          _phoneNumber = phoneFromAuth;
          _isInitializing = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.backgroundColor,
        border: null,
        middle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Manga Lounge',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Complete Your Profile',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
      child: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildContent() {
    if (_isInitializing) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: AppTheme.errorColor),
        ),
      );
    }

    if (_uid == null || _phoneNumber == null) {
      return const Center(child: Text('Unable to get user information'));
    }

    return ProfileForm(
      mode: ProfileFormMode.create,
      phoneNumber: _phoneNumber!,
      uid: _uid!,
      onSuccess: () => _onProfileCreated(context),
    );
  }

  /// Only the reduced profile is created; no email provider is linked.
  Future<void> _onProfileCreated(BuildContext context) async {
    NavigationDiagnostics.event('registration.success');
    final profileUid = _uid;
    if (profileUid != null) {
      unawaited(
        PushNotificationConfig.registerForUser(
          profileUid,
          ref.read(firestoreProvider),
        ),
      );
    }
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    ref.invalidate(userStreamProvider);
    NavigationDiagnostics.event('registration.goHome.start');
    const HomeRoute().go(context);
    NavigationDiagnostics.event('registration.goHome.return');
    NavigationDiagnostics.afterFrame('registration.home.frame');
  }
}
