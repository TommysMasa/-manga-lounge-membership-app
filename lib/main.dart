import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/shared/navigation.dart';
import 'package:app_links/app_links.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/firebase_config.dart';
import 'core/router/app_router.dart';
import 'core/di/providers.dart';
import 'shared/constants/app_constants.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_state_notifier.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await FirebaseConfig.initialize();

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
    } catch (e) {
      print('Error getting initial link: $e');
    }

    // Handle links when app is in background/foreground
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }

  /// Handle deep link (Email Link authentication)
  Future<void> _handleDeepLink(Uri uri) async {
    print('DEBUG: Received deep link: $uri');

    // Get the email link
    final emailLink = uri.toString();

    // Check if this is a sign-in link
    final authDataSource = ref.read(authDataSourceProvider);
    if (!authDataSource.isSignInWithEmailLink(emailLink)) {
      print('DEBUG: Not a valid sign-in link');
      return;
    }

    print('DEBUG: Valid sign-in link detected');

    // Get stored email from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('emailForSignIn');

    if (email == null) {
      print('DEBUG: No email found in storage');
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

    print('DEBUG: Found email: $email');

    // Sign in with email link - delay to avoid modifying provider during build
    Future(() async {
      final authNotifier = ref.read(authStateProvider.notifier);
      final result = await authNotifier.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // Clear stored email
      await prefs.remove('emailForSignIn');

      // Show notification
      final nav = ref.read(navigationProvider);
      final rootContext = nav.rootContext;
      if (rootContext.mounted) {
        result.fold(
          (failure) {
            AppTheme.showNotification(
              rootContext,
              message: failure.message,
              isError: true,
            );
          },
          (_) {
            AppTheme.showNotification(
              rootContext,
              message: 'Logged in successfully. Please update your phone number.',
              isError: false,
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);

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
