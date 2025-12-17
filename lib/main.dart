import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_lounge/shared/navigation.dart';

import 'config/firebase_config.dart';
import 'core/router/app_router.dart';
import 'shared/constants/app_constants.dart';
import 'shared/theme/app_theme.dart';

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

class MangaLoungeApp extends ConsumerWidget {
  const MangaLoungeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return CupertinoApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.cupertinoTheme,
      routerConfig: router,
    );
  }
}
