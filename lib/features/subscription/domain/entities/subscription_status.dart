import 'package:cloud_firestore/cloud_firestore.dart';

/// Cross-channel subscription status mirrored to Firestore
/// (`subscriptions/{uid}`) by the RevenueCat webhook.
class SubscriptionStatus {
  const SubscriptionStatus({
    required this.isPro,
    this.source,
    this.expiresAt,
    this.productId,
    this.updatedAt,
  });

  final bool isPro;

  /// "revenuecat" (store IAP) or "promotional" (comp granted via API/dashboard)
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
    return SubscriptionStatus(
      isPro: data['isPro'] == true,
      source: data['source'] as String?,
      expiresAt: _parseDate(data['expiresAt']),
      productId: data['productId'] as String?,
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
