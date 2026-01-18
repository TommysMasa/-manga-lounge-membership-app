import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/di/providers.dart';
import '../../../../core/router/app_routes.dart';
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
        print('DEBUG Registration: Phone from Firebase Auth: $phoneFromAuth');
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

  /// Called after profile is successfully created
  /// Links email address to Firebase Auth for account recovery
  Future<void> _onProfileCreated(BuildContext context) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('WARNING: No authenticated user');
        const HomeRoute().go(context);
        return;
      }

      // Get email from ProfileForm state (user just entered it during registration)
      final profileFormState = ref.read(profileFormProvider);
      final email = profileFormState.email;

      if (email.isEmpty) {
        print('WARNING: No email address available');
        const HomeRoute().go(context);
        return;
      }

      print('DEBUG: Linking email $email to Firebase Auth');

      // Generate random password (user will use email link for login, not password)
      final randomPassword = _generateRandomPassword();

      // Create email/password credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: randomPassword,
      );

      // Link email to current phone auth user
      await currentUser.linkWithCredential(credential);

      print('SUCCESS: Email provider linked successfully');

      // Show success message
      if (context.mounted) {
        AppTheme.showNotification(
          context,
          message: 'セカンダリ認証（メールアドレス）を設定しました',
          isError: false,
        );
      }
    } catch (e) {
      // Log error but don't block user flow
      print('ERROR: Failed to link email provider: $e');

      if (context.mounted) {
        AppTheme.showNotification(
          context,
          message: 'セカンダリ認証の設定に失敗しました',
          isError: true,
        );
      }
    } finally {
      // Navigate to home screen regardless of link result
      if (context.mounted) {
        const HomeRoute().go(context);
      }
    }
  }

  /// Generate a secure random password
  /// This password is not used by users (they use email link for login)
  String _generateRandomPassword() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%^&*';
    final random = Random.secure();
    return List.generate(32, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
