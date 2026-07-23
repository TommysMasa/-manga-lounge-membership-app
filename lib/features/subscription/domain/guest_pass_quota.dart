/// Remaining free guest passes for the current billing period.
class GuestPassQuota {
  const GuestPassQuota({
    required this.remaining,
    required this.total,
    required this.renewsAt,
    required this.periodKey,
  });

  final int remaining;
  final int total;
  final DateTime renewsAt;
  final String periodKey;
}
