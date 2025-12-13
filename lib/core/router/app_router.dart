import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:manga_lounge/core/router/app_routes.dart';
import 'package:manga_lounge/features/auth/domain/entities/auth_state.dart';
import 'package:manga_lounge/features/auth/presentation/providers/auth_state_notifier.dart';

/// Go Router Configuration with Type-Safe Routes and Auth Redirect
///
/// This uses go_router_builder for compile-time type safety.
/// Routes are defined in app_routes.dart and generated code provides
/// type-safe navigation methods.
///
/// Auto-login/redirect logic:
/// - Authenticated users accessing auth screens -> redirect to /home
/// - Unauthenticated users accessing protected screens -> redirect to /
/// - OTP sent state -> redirect to /otp-verification
/// - Auth state changes automatically trigger navigation updates via refreshListenable
///
/// Benefits:
/// - Compile-time safety: Typos caught during development
/// - IDE autocomplete: Full support for route navigation
/// - Refactor-friendly: Changes propagate automatically
/// - Auth-aware routing: Automatic redirects based on auth state
/// - Router stability: Uses refreshListenable to avoid recreating router on auth changes

/// Listenable that notifies GoRouter to refresh when auth state changes
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(this._ref) {
    _ref.listen(authStateProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: $appRoutes,
    refreshListenable: _GoRouterRefreshNotifier(ref),

    // Auth redirect logic
    redirect: (context, state) {
      // Read current auth state (don't watch - that would recreate the router)
      final authState = ref.read(authStateProvider);
      final currentLocation = state.matchedLocation;

      // Define route categories
      // Note: /register is NOT an auth route - it requires authentication
      // for profile completion after phone verification
      final isAuthRoute =
          currentLocation == '/' ||
          currentLocation == '/phone-input' ||
          currentLocation == '/otp-verification';
      final isProtectedRoute =
          currentLocation == '/home' || currentLocation == '/register';

      // Check for OTP sent state - navigate to OTP verification
      final shouldGoToOTP = authState.maybeWhen(
        otpSent: (_, __) => currentLocation != '/otp-verification',
        orElse: () => false,
      );

      if (shouldGoToOTP) {
        return '/otp-verification';
      }

      // Determine auth status
      final isAuthenticated = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );

      // Redirect logic
      if (isAuthenticated && isAuthRoute) {
        // Authenticated users shouldn't see auth screens
        return '/home';
      }

      if (!isAuthenticated && isProtectedRoute) {
        // Unauthenticated users can't access protected routes
        return '/';
      }

      // No redirect needed
      return null;
    },

    // Error handling
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
