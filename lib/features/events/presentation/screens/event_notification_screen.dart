import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/events_repository.dart';
import 'event_detail_screen.dart';

/// Resolve a push against the currently authorized feed, never its cached payload.
class EventNotificationScreen extends ConsumerWidget {
  const EventNotificationScreen({super.key, required this.eventId});
  final String eventId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(eventsProvider)
        .when(
          loading: () => const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator()),
          ),
          error: (_, _) => CupertinoPageScaffold(
            navigationBar: const CupertinoNavigationBar(middle: Text('Event')),
            child: Center(
              child: CupertinoButton(
                onPressed: () => ref.invalidate(eventsProvider),
                child: const Text('Try again'),
              ),
            ),
          ),
          data: (events) {
            final matches = events.where((event) => event.id == eventId);
            if (matches.isNotEmpty)
              return EventDetailScreen(event: matches.first);
            return const CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(middle: Text('Event')),
              child: Center(child: Text('This event is no longer available.')),
            );
          },
        );
  }
}
