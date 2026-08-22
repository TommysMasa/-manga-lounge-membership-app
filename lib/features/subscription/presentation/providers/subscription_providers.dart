import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../config/revenuecat_config.dart';
import '../../../../core/di/providers.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/guest_pass_period.dart';
import '../../domain/guest_pass_quota.dart';
import '../../domain/pro_cap.dart';

/// Streams the latest [CustomerInfo] from RevenueCat.
///
/// Emits the current value immediately and again whenever purchases,
/// renewals or user switches (logIn/logOut) happen.
final customerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  final controller = StreamController<CustomerInfo>();

  void listener(CustomerInfo info) {
    if (!controller.isClosed) controller.add(info);
  }

  Purchases.addCustomerInfoUpdateListener(listener);
  // Seed with the current value (listener only fires on updates)
  Purchases.getCustomerInfo().then(listener).catchError((Object e) {
    if (!controller.isClosed) controller.addError(e);
  });

  ref.onDispose(() {
    Purchases.removeCustomerInfoUpdateListener(listener);
    controller.close();
  });

  return controller.stream;
});

/// Whether the RevenueCat Pro entitlement is currently active
final revenueCatIsProProvider = Provider<bool>((ref) {
  final customerInfo = ref.watch(customerInfoProvider).value;
  return customerInfo?.entitlements.active.containsKey(
        RevenueCatConfig.entitlementId,
      ) ??
      false;
});

/// Live subscription status from Firestore (`subscriptions/{uid}`),
/// written by the RevenueCat webhook. Null when the
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

/// Whether the current user is a Pro member, from any payment channel.
///
/// - Firestore (`subscriptions/{uid}`) is the server-side mirror kept up to
///   date by the RevenueCat webhook (IAP and promotional comps).
/// - The live RevenueCat check is OR-ed in so that an in-app purchase
///   unlocks Pro instantly, without waiting for the webhook roundtrip.
final isProProvider = Provider<bool>((ref) {
  if (_kDebugForcePro) return true;

  final firestoreStatus = ref.watch(subscriptionStatusProvider).value;
  if (firestoreStatus != null && firestoreStatus.isActive) return true;

  return ref.watch(revenueCatIsProProvider);
});

/// Debug-only preview switch: forces Pro on the simulator so premium
/// designs can be checked without a subscription. Must stay false in
/// commits; kDebugMode keeps it inert in release builds regardless.
const bool _kDebugForcePro = kDebugMode && false;

/// Remaining free guest passes for the current Pro billing period.
///
/// Null when the user is not Pro (or signed out). Reads `guestPassUses`
/// written by the entry-scanner when staff issues a pass.
///
/// Waits for `subscriptions/{uid}` before choosing the period key. Otherwise
/// RevenueCat can mark the user Pro first, and we'd fall back to a calendar
/// month ("Renews Aug 1") instead of the real `expiresAt`.
final guestPassQuotaProvider = StreamProvider<GuestPassQuota?>((ref) {
  if (!ref.watch(isProProvider)) return Stream.value(null);

  final currentUser = ref.watch(firebaseAuthProvider).currentUser;
  if (currentUser == null) return Stream.value(null);

  final statusAsync = ref.watch(subscriptionStatusProvider);
  // Still fetching subscriptions/{uid} — don't invent a calendar renew date.
  if (statusAsync.isLoading && !statusAsync.hasValue) {
    return Stream.value(null);
  }
  if (statusAsync.hasError && !statusAsync.hasValue) {
    return Stream.value(null);
  }

  final status = statusAsync.value;
  // Pro via RevenueCat but no Firestore subscription doc yet: hide until the
  // webhook mirror exists so we don't show a fake "Renews Aug 1".
  if (status == null) {
    return Stream.value(null);
  }

  final period = GuestPassPeriod.fromSubscription(status);

  return ref
      .watch(firestoreProvider)
      .collection('guestPassUses')
      .where('hostUid', isEqualTo: currentUser.uid)
      .where('periodKey', isEqualTo: period.key)
      .snapshots()
      .map((snap) {
        final used = snap.size;
        final remaining = (kGuestPassesPerPeriod - used).clamp(
          0,
          kGuestPassesPerPeriod,
        );
        return GuestPassQuota(
          remaining: remaining,
          total: kGuestPassesPerPeriod,
          renewsAt: period.renewsAt,
          periodKey: period.key,
        );
      });
});

/// Soft launch Pro seat counter (`config/proCap`).
///
/// Written by the RevenueCat webhook. Readable by signed-in clients so the
/// home / paywall can show remaining spots. Null while signed out or missing.
final proCapProvider = StreamProvider<ProCap?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final firestore = ref.watch(firestoreProvider);

  // Re-subscribe when auth changes. A one-shot currentUser == null used to
  // return Stream.value(null) forever, so the Upgrade banner never got spots.
  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) return Stream<ProCap?>.value(null);
    return firestore.collection('config').doc('proCap').snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      return ProCap.fromFirestore(data);
    });
  });
});

/// Current offerings (products) configured in the RevenueCat dashboard.
///
/// Bounded: StoreKit can stall indefinitely on account-side blockers (pending
/// App Store terms agreement, payment issues, Ask to Buy), which used to
/// leave the paywall on a spinner forever. Timing out surfaces the error
/// view (with the reason) instead.
final offeringsProvider = FutureProvider<Offerings>((ref) {
  return Purchases.getOfferings().timeout(
    const Duration(seconds: 12),
    onTimeout: () => throw TimeoutException(
      'The App Store did not respond. This usually means the App Store is '
      'asking this Apple Account for something (new terms to accept, a '
      'payment method issue, or a purchase approval). Open the App Store '
      'app, resolve any prompt there, then retry.',
    ),
  );
});

/// The monthly package of the current offering, if available
final monthlyPackageProvider = Provider<Package?>((ref) {
  final offerings = ref.watch(offeringsProvider).value;
  final current = offerings?.current;
  if (current == null) return null;
  return current.monthly ??
      (current.availablePackages.isNotEmpty
          ? current.availablePackages.first
          : null);
});
