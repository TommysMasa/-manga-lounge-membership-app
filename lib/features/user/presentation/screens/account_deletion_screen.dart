import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/account_deletion_controller.dart';

class AccountDeletionScreen extends ConsumerWidget {
  const AccountDeletionScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(accountDeletionProvider);
    final busy = status.phase == DeletionPhase.deleting;
    final message = switch (status.phase) {
      DeletionPhase.deleting =>
        'Deleting your account… Please keep this screen open.',
      DeletionPhase.completed =>
        'Your account has been deleted. Connected service data has been submitted for deletion. Store subscriptions must be cancelled separately.',
      DeletionPhase.processing =>
        'Your deletion request has been accepted. Remaining processing will retry automatically. Store subscriptions must be cancelled separately.',
      DeletionPhase.failed =>
        'We could not confirm deletion. ${status.message ?? ''}',
      DeletionPhase.idle => 'Account deletion',
    };
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (busy) const CupertinoActivityIndicator(),
                const SizedBox(height: 20),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (!busy)
                  CupertinoButton.filled(
                    onPressed: () {
                      ref.read(accountDeletionProvider.notifier).dismiss();
                    },
                    child: const Text('Continue'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
