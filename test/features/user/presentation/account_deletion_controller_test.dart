import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:manga_lounge/core/di/providers.dart';
import 'package:manga_lounge/core/error/failures.dart';
import 'package:manga_lounge/core/error/result.dart';
import 'package:manga_lounge/features/user/domain/entities/account_deletion_outcome.dart';
import 'package:manga_lounge/features/user/domain/repositories/user_repository.dart';
import 'package:manga_lounge/features/user/presentation/providers/account_deletion_controller.dart';

class FakeRepository extends Mock implements UserRepository {}

void main() {
  test(
    'result survives profile listener disposal during sign-out and duplicate requests are blocked',
    () async {
      final repository = FakeRepository();
      final pending = Completer<Result<AccountDeletionOutcome>>();
      when(
        () => repository.deleteAccount('synthetic'),
      ).thenAnswer((_) => pending.future);
      final container = ProviderContainer(
        overrides: [userRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      final profileListener = container.listen(
        accountDeletionProvider,
        (_, _) {},
      );
      final controller = container.read(accountDeletionProvider.notifier);
      final request = controller.delete('synthetic');
      expect(
        container.read(accountDeletionProvider).phase,
        DeletionPhase.deleting,
      );
      profileListener.close();
      await controller.delete('synthetic');
      verify(() => repository.deleteAccount('synthetic')).called(1);
      pending.complete(const Right(AccountDeletionOutcome.completed));
      await request;
      expect(
        container.read(accountDeletionProvider).phase,
        DeletionPhase.completed,
      );
      controller.dismiss();
      expect(container.read(accountDeletionProvider).active, isFalse);
    },
  );
  test('accepted-but-pending and failure never display completed', () async {
    final repository = FakeRepository();
    final container = ProviderContainer(
      overrides: [userRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    final controller = container.read(accountDeletionProvider.notifier);
    when(
      () => repository.deleteAccount('synthetic'),
    ).thenAnswer((_) async => const Right(AccountDeletionOutcome.processing));
    await controller.delete('synthetic');
    expect(
      container.read(accountDeletionProvider).phase,
      DeletionPhase.processing,
    );
    controller.dismiss();
    when(
      () => repository.deleteAccount('synthetic'),
    ).thenAnswer((_) async => const Left(DatabaseFailure('synthetic failure')));
    await controller.delete('synthetic');
    expect(container.read(accountDeletionProvider).phase, DeletionPhase.failed);
  });
}
