import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_lounge/core/error/result.dart';
import 'package:manga_lounge/features/user/presentation/widgets/profile_form/delete_account_sms_dialog.dart';

void main() {
  testWidgets(
    'resend waits 30 seconds, prevents duplicate sends and verifies newest SMS',
    (tester) async {
      var now = DateTime.utc(2026);
      var sends = 0;
      final sent = Completer<Result<String>>();
      DeleteAccountSmsConfirmation? confirmation;
      await tester.pumpWidget(
        CupertinoApp(
          home: Builder(
            builder: (context) => CupertinoButton(
              onPressed: () async {
                confirmation =
                    await showCupertinoDialog<DeleteAccountSmsConfirmation>(
                      context: context,
                      builder: (_) => DeleteAccountSmsDialog(
                        initialVerificationId: 'old-sms',
                        now: () => now,
                        resend: () {
                          sends++;
                          return sent.future;
                        },
                      ),
                    );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Resend in 30s'), findsOneWidget);
      await tester.tap(find.text('Resend in 30s'));
      expect(sends, 0);
      await tester.enterText(find.byType(CupertinoTextField), '111111');
      now = now.add(const Duration(seconds: 31));
      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.text('Resend'));
      await tester.pump();
      expect(sends, 1);
      expect(find.text('Sending…'), findsOneWidget);
      await tester.tap(find.text('Sending…'));
      expect(sends, 1);
      sent.complete(const Right('new-sms'));
      await tester.pump();
      expect(
        tester
            .widget<CupertinoTextField>(find.byType(CupertinoTextField))
            .controller!
            .text,
        isEmpty,
      );
      expect(find.text('Resend in 30s'), findsOneWidget);
      await tester.enterText(find.byType(CupertinoTextField), '222222');
      await tester.tap(find.text('Verify and Delete'));
      await tester.pumpAndSettle();
      expect(confirmation!.verificationId, 'new-sms');
      expect(confirmation!.code, '222222');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('cancel during resend does not update a disposed dialog', (
    tester,
  ) async {
    var now = DateTime.utc(2026);
    final sent = Completer<Result<String>>();
    await tester.pumpWidget(
      CupertinoApp(
        home: DeleteAccountSmsDialog(
          initialVerificationId: 'old',
          now: () => now,
          resend: () => sent.future,
        ),
      ),
    );
    now = now.add(const Duration(seconds: 31));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Resend'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    sent.complete(const Right('new'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
