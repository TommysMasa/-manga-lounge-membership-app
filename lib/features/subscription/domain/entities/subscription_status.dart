import 'package:cloud_firestore/cloud_firestore.dart';

/// Cross-channel subscription status mirrored to Firestore
/// (`subscriptions/{uid}`) by the payment webhooks (RevenueCat / Square).
class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isPro,
    this.source,
    this.expiresAt,
    this.productId,
    this.updatedAt,
  });

  final bool isPro;

  /// "revenuecat" (store IAP) or "promotional" (Square / comp)
  final String? source;
  final DateTime? expiresAt;
  final String? productId;
  final DateTime? updatedAt;

  /// Active means isPro and not past the expiration date (if any).
  bool get isActive {
    if (!isPro) return false;
    final exp = expiresAt;
    if (exp == null) return true;
    return exp.isAfter(DateTime.now());
  }

  factory SubscriptionStatus.fromFirestore(Map<String, dynamic> data) {
    DateTime? toDate(Object? v) => v is Timestamp ? v.toDate() : null;
    return SubscriptionStatus(
      isPro: data['isPro'] == true,
      source: data['source'] as String?,
      expiresAt: toDate(data['expiresAt']),
      productId: data['productId'] as String?,
      updatedAt: toDate(data['updatedAt']),
    );
  }
}
