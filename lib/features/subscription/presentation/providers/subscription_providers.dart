import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/providers.dart';
import '../../domain/entities/subscription_status.dart';

/// Live subscription status from Firestore (`subscriptions/{uid}`),
/// written by the payment webhooks (RevenueCat / Square). Null when the
/// user has no subscription document or is signed out.
final subscriptionStatusProvider = StreamProvider<SubscriptionStatus?>((ref) {
  final currentUser = ref.watch(firebaseAuthProvider).currentUser;
  if (currentUser == null) return Stream.value(null);

  return ref
      .watch(firestoreProvider)
      .collection('subscriptions')
      .doc(currentUser.uid)
      .snapshots()
      .map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return SubscriptionStatus.fromFirestore(data);
      });
});

/// Whether the current user has an active Pro membership.
final isProProvider = Provider<bool>((ref) {
  final status = ref.watch(subscriptionStatusProvider).value;
  return status != null && status.isActive;
});
