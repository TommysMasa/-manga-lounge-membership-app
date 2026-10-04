import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/di/providers.dart';
import '../../subscription/presentation/providers/subscription_providers.dart';

final _venueZone = (() {
  tz_data.initializeTimeZones();
  return tz.getLocation('America/Los_Angeles');
})();

class LoungeEvent {
  const LoungeEvent({
    required this.id,
    required this.title,
    required this.summary,
    required this.description,
    required this.startsAt,
    required this.endsAt,
    required this.ticketUrl,
    this.location = 'Manga Lounge',
    this.imageUrl,
    this.registrationLabel = 'Get tickets',
    this.priceLabel = 'See ticket options',
  });
  final String id,
      title,
      summary,
      description,
      ticketUrl,
      location,
      registrationLabel,
      priceLabel;
  final DateTime startsAt, endsAt;
  final String? imageUrl;
  DateTime get localStart => tz.TZDateTime.from(startsAt, _venueZone);
  DateTime get localEnd => tz.TZDateTime.from(endsAt, _venueZone);

  factory LoungeEvent.fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    String text(String field, [String fallback = '']) {
      final value = data[field];
      return value is String && value.trim().isNotEmpty
          ? value.trim()
          : fallback;
    }

    final start = data['startsAt'];
    final end = data['endsAt'];
    final url = text('ticketUrl');
    final uri = Uri.tryParse(url);
    if (text('title').isEmpty ||
        start is! Timestamp ||
        end is! Timestamp ||
        !end.toDate().isAfter(start.toDate()) ||
        uri == null ||
        !['https', 'http'].contains(uri.scheme) ||
        uri.host.isEmpty) {
      throw const FormatException('Invalid event');
    }
    final image = text('imageUrl');
    final imageUri = Uri.tryParse(image);
    return LoungeEvent(
      id: doc.id,
      title: text('title'),
      summary: text('summary'),
      description: text('description'),
      startsAt: start.toDate(),
      endsAt: end.toDate(),
      ticketUrl: url,
      location: text('location', 'Manga Lounge'),
      imageUrl: imageUri?.scheme == 'https' && imageUri!.host.isNotEmpty
          ? image
          : null,
      registrationLabel: text('registrationLabel', 'Get tickets'),
      priceLabel: text('priceLabel', 'See ticket options'),
    );
  }
}

final eventsProvider = StreamProvider<List<LoungeEvent>>((ref) {
  // Early-access queries use the server membership mirror enforced by rules.
  final isPro = ref.watch(subscriptionStatusProvider).value?.isActive ?? false;
  final collection = ref.watch(firestoreProvider).collection('events');
  final query = isPro
      ? collection.where(
          Filter.or(
            Filter('published', isEqualTo: true),
            Filter('proPublished', isEqualTo: true),
          ),
        )
      : collection.where('published', isEqualTo: true);
  return query.snapshots().map((snapshot) {
    final events = <LoungeEvent>[];
    for (final doc in snapshot.docs) {
      try {
        events.add(LoungeEvent.fromDocument(doc));
      } on FormatException {
        // One invalid document must not hide the remaining events.
        continue;
      }
    }
    events.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return events;
  });
});
