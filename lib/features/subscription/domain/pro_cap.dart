/// Soft launch seat counter (`config/proCap` in Firestore).
class ProCap {
  const ProCap({required this.limit, required this.activeCount});

  final int limit;
  final int activeCount;

  int get remaining => (limit - activeCount).clamp(0, limit);

  bool get isFull => remaining <= 0;

  factory ProCap.fromFirestore(Map<String, dynamic> data) {
    final limit = (data['limit'] as num?)?.toInt() ?? 150;
    final activeCount = (data['activeCount'] as num?)?.toInt() ?? 0;
    return ProCap(limit: limit, activeCount: activeCount);
  }
}
