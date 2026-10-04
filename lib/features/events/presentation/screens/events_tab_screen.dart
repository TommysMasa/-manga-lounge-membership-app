import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../data/events_repository.dart';
import 'event_detail_screen.dart';

class EventsTabScreen extends ConsumerWidget {
  const EventsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: const CupertinoNavigationBar(middle: Text('Events')),
      child: SafeArea(
        bottom: false,
        child: ref
            .watch(eventsProvider)
            .when(
              loading: () => const Center(child: CupertinoActivityIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load events.'),
                    CupertinoButton(
                      onPressed: () => ref.invalidate(eventsProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final events = all
                    .where((e) => e.endsAt.isAfter(DateTime.now()))
                    .toList();
                if (events.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            CupertinoIcons.ticket,
                            size: 36,
                            color: AppTheme.primaryBlue,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'More events coming soon!',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Check back for our next Manga Lounge gathering.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final month = DateFormat(
                      'MMMM yyyy',
                      'en_US',
                    ).format(event.localStart);
                    final previous = index == 0
                        ? null
                        : DateFormat(
                            'MMMM yyyy',
                            'en_US',
                          ).format(events[index - 1].localStart);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (month != previous)
                          Padding(
                            padding: EdgeInsets.only(
                              top: index == 0 ? 0 : 12,
                              bottom: 12,
                            ),
                            child: Text(
                              month.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        _EventRow(event: event),
                      ],
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});
  final LoungeEvent event;

  @override
  Widget build(BuildContext context) {
    final start = event.localStart;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () => Navigator.of(context).push(
          CupertinoPageRoute<void>(
            builder: (_) => EventDetailScreen(event: event),
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 46,
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEE', 'en_US').format(start).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      '${start.day}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      DateFormat('MMM', 'en_US').format(start).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (event.summary.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      eventTimeLabel(event),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
