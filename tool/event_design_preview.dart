import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../lib/shared/theme/app_theme.dart';
import '../lib/features/events/data/events_repository.dart';
import '../lib/features/events/data/event_ticket_link.dart';
import '../lib/features/events/presentation/screens/event_detail_screen.dart';

void main() {
  final event = LoungeEvent(
    id: 'design-preview',
    title: 'Manga Jazz Night vol.3',
    summary: '',
    description:
        'An evening of live jazz, manga, and good company at Manga Lounge.',
    startsAt: DateTime.utc(2026, 10, 11, 3),
    endsAt: DateTime.utc(2026, 10, 11, 5),
    ticketUrl: 'https://www.eventbrite.com/e/2002178534895',
    imageUrl: 'https://mangalounge.com/Picture/Event/MJNv3.png',
    priceLabel: 'See ticket options',
  );
  runApp(
    ProviderScope(
      overrides: [
        eventTicketLinkProvider.overrideWithValue(
          (event) async => event.ticketUrl,
        ),
      ],
      child: CupertinoApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.cupertinoTheme,
        home: EventDetailScreen(event: event),
      ),
    ),
  );
}
