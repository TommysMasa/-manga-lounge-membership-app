import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/account_deletion_outcome.dart';

// Kept outside the profile widget so sign-out cannot dispose the result owner.
enum DeletionPhase { idle, deleting, completed, processing, failed }

class DeletionState {
  const DeletionState(this.phase, {this.message});
  final DeletionPhase phase;
  final String? message;
  bool get active => phase != DeletionPhase.idle;
}

final accountDeletionProvider =
    NotifierProvider<AccountDeletionController, DeletionState>(
      AccountDeletionController.new,
    );

class AccountDeletionController extends Notifier<DeletionState> {
  @override
  DeletionState build() => const DeletionState(DeletionPhase.idle);
  Future<void> delete(String uid) async {
    if (state.phase == DeletionPhase.deleting) return;
    final repository = ref.read(userRepositoryProvider);
    state = const DeletionState(DeletionPhase.deleting);
    try {
      final result = await repository.deleteAccount(uid);
      result.fold(
        (failure) => state = DeletionState(
          DeletionPhase.failed,
          message: failure.message,
        ),
        (outcome) => state = DeletionState(
          outcome == AccountDeletionOutcome.completed
              ? DeletionPhase.completed
              : DeletionPhase.processing,
        ),
      );
    } catch (_) {
      state = const DeletionState(
        DeletionPhase.failed,
        message:
            'We could not confirm the result. Please contact support before trying again.',
      );
    }
  }

  void dismiss() => state = const DeletionState(DeletionPhase.idle);
}
