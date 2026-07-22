import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/shared/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/firebase_config.dart';
import 'config/push_notification_config.dart';
import 'config/revenuecat_config.dart';
import 'core/di/providers.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/providers/auth_state_notifier.dart';
import 'features/subscription/presentation/providers/subscription_providers.dart';
import 'shared/constants/app_constants.dart';
import 'shared/theme/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Initialize RevenueCat
  await RevenueCatConfig.initialize();

  // Initialize push notifications (foreground presentation options)
  await PushNotificationConfig.initialize();

  // Run the app wrapped with Riverpod ProviderScope
  runApp(
    ProviderScope(
      overrides: [
        navigationProvider.overrideWithValue(
          NavigationState(
            rootNavKey: GlobalKey<NavigatorState>(debugLabel: 'root'),
          ),
        ),
      ],
      child: MangaLoungeApp(),
    ),
  );
}

class MangaLoungeApp extends ConsumerStatefulWidget {
  const MangaLoungeApp({super.key});

  @override
  ConsumerState<MangaLoungeApp> createState() => _MangaLoungeAppState();
}

class _MangaLoungeAppState extends ConsumerState<MangaLoungeApp> {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinkListener();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  /// Initialize deep link listener for Email Link authentication
  Future<void> _initDeepLinkListener() async {
    // Handle initial link when app is launched from terminated state
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }
    } catch (_) {
      // Deep link initialization failure is non-critical - app continues normally
    }

    // Handle links when app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen(
      _handleDeepLink,
      onError: (_) {
        // Deep link stream errors are non-critical - app continues normally
      },
    );
  }

  /// Handle deep link (Email Link authentication)
  Future<void> _handleDeepLink(Uri uri) async {
    // Get the email link
    final emailLink = uri.toString();

    // Check if this is a sign-in link
    final authDataSource = ref.read(authDataSourceProvider);
    if (!authDataSource.isSignInWithEmailLink(emailLink)) {
      return;
    }

    // Get stored email from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('emailForSignIn');

    if (email == null) {
      // Show error notification - delay to avoid modifying during build
      Future(() {
        final nav = ref.read(navigationProvider);
        final rootContext = nav.rootContext;
        if (rootContext.mounted) {
          AppTheme.showNotification(
            rootContext,
            message: 'メールアドレスが見つかりませんでした。もう一度やり直してください。',
            isError: true,
          );
        }
      });
      return;
    }

    // Sign in with email link - delay to avoid modifying provider during build
    Future(() async {
      final authNotifier = ref.read(authStateProvider.notifier);
      final result = await authNotifier.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // Clear stored email
      await prefs.remove('emailForSignIn');

      // Handle result
      result.fold(
        (failure) {
          // Show error notification immediately
          final nav = ref.read(navigationProvider);
          final rootContext = nav.rootContext;
          if (rootContext.mounted) {
            AppTheme.showNotification(
              rootContext,
              message: failure.message,
              isError: true,
            );
          }
        },
        (_) {
          // Listen for route change to /home, then show success notification
          _showNotificationOnHomeRoute(
            'Logged in successfully. Please update your phone number.',
          );
        },
      );
    });
  }

  /// Show notification after navigation to /home completes
  void _showNotificationOnHomeRoute(String message) {
    final router = ref.read(goRouterProvider);

    void showNotification() {
      Future.delayed(const Duration(milliseconds: 100), () {
        final nav = ref.read(navigationProvider);
        final rootContext = nav.rootContext;
        if (rootContext.mounted) {
          AppTheme.showNotification(rootContext, message: message);
        }
      });
    }

    // Check if already on /home (navigation happened very fast)
    final currentRoute = router.routerDelegate.currentConfiguration.fullPath;
    if (currentRoute == '/home') {
      showNotification();
      return;
    }

    // Otherwise, wait for navigation to /home
    void listener() {
      final route = router.routerDelegate.currentConfiguration.fullPath;
      if (route == '/home') {
        router.routerDelegate.removeListener(listener);
        showNotification();
      }
    }

    router.routerDelegate.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

    // Keep the `pro` notification topic in sync with the Pro status
    ref.listen<bool>(isProProvider, (previous, next) {
      if (previous != next) PushNotificationConfig.setProTopic(next);
    });

    return CupertinoApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
