import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/features/auth/domain/entities/auth_state.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';

/// Splash screen displayed on app launch
///
/// Migrated to use Riverpod and clean architecture.
/// Watches authStateProvider for authentication state.
/// Navigation is handled automatically by the router's redirect logic.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth state for changes
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo_1.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(),

              // Bottom section
              Column(
                children: [
                  // Show loading or error state
                  authState.when(
                    initial: () => const SizedBox.shrink(),
                    authenticated: (_) => const SizedBox.shrink(),
                    unauthenticated: () => const SizedBox.shrink(),
                    otpSent: (_, __) => const SizedBox.shrink(),
                    loading: () => const CircularProgressIndicator(),
                    error: (message) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Continue with phone button
                  ElevatedButton.icon(
                    onPressed: () {
                      const PhoneInputRoute().go(context);
                    },
                    icon: const Icon(Icons.phone, color: Colors.white),
                    label: const Text('Continue with phone'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Info message
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppTheme.primaryBlue, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Children under 13 may enter only with an adult parent or guardian.',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Change Phone Number link
                  TextButton(
                    onPressed: () {
                      // Already on splash, do nothing or show a message
                    },
                    child: const Text(
                      'Change Phone Number',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
