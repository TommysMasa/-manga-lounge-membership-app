import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/di/providers.dart';
import 'package:manga_lounge/core/router/app_routes.dart';
import 'package:manga_lounge/features/auth/domain/repositories/auth_repository.dart';
import 'package:manga_lounge/features/shell/presentation/main_shell.dart';
import 'package:manga_lounge/features/subscription/presentation/providers/subscription_providers.dart';

class FakeAuth extends Mock implements AuthRepository {}

void main() {
  for (final item in ['Phone Number', 'Email Address']) {
    testWidgets(
      '$item stays inside Settings, switches tabs and returns without losing its stack',
      (tester) async {
        final auth = FakeAuth();
        when(() => auth.getCurrentUserPhoneNumber()).thenReturn('+16505550001');
        when(
          () => auth.getCurrentUserEmail(),
        ).thenReturn('synthetic@example.invalid');
        final production = $mainShellRoute as StatefulShellRoute;
        final router = GoRouter(
          initialLocation: '/settings',
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (_, _, shell) => MainShell(navigationShell: shell),
              branches: [
                for (final path in ['/home', '/events', '/manga'])
                  StatefulShellBranch(
                    routes: [
                      GoRoute(
                        path: path,
                        builder: (_, _) => Center(child: Text('Content $path')),
                      ),
                    ],
                  ),
                StatefulShellBranch(routes: production.branches[3].routes),
              ],
            ),
          ],
        );
        addTearDown(router.dispose);
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              authRepositoryProvider.overrideWithValue(auth),
              isProProvider.overrideWithValue(false),
            ],
            child: CupertinoApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Edit Profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(item));
        await tester.pumpAndSettle();
        expect(
          find.text(
            item == 'Phone Number'
                ? 'Change Phone Number'
                : 'Change Email Address',
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.text('Content /home'), findsOneWidget);
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(
          find.text(
            item == 'Phone Number'
                ? 'Change Phone Number'
                : 'Change Email Address',
          ),
          findsOneWidget,
        );
        await tester.tap(find.byIcon(CupertinoIcons.back).last);
        await tester.pumpAndSettle();
        expect(find.text('Change Phone Number'), findsNothing);
        expect(find.text('Change Email Address'), findsNothing);
        expect(find.text('Edit Profile'), findsOneWidget);
        expect(find.text('Phone Number'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
