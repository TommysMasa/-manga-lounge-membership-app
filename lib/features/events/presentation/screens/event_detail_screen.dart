import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/launch_url.dart';
import '../../data/events_repository.dart';
import '../../data/event_ticket_link.dart';

String eventTimeLabel(LoungeEvent event) {
  final start = event.localStart;
  final end = event.localEnd;
  final sameDay =
      start.year == end.year &&
      start.month == end.month &&
      start.day == end.day;
  final format = DateFormat('h:mm a', 'en_US');
  return '${format.format(start)} – ${sameDay ? format.format(end) : DateFormat('MMM d, h:mm a', 'en_US').format(end)}';
}

final eventFlyerProvider = Provider.family<ImageProvider?, LoungeEvent>(
  (ref, event) => event.imageUrl == null ? null : NetworkImage(event.imageUrl!),
);

class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({super.key, required this.event});
  final LoungeEvent event;
  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool _opening = false;
  Future<void> _register() async {
    if (!widget.event.endsAt.isAfter(DateTime.now())) {
      setState(() {});
      return;
    }
    setState(() => _opening = true);
    try {
      final url = await ref.read(eventTicketLinkProvider)(widget.event);
      if (!mounted) return;
      await launchURL(url);
    } catch (_) {
      if (mounted) {
        await AppTheme.showNotification(
          context,
          message: 'Could not open the registration page. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _openLocation() async {
    try {
      await launchURL('https://www.google.com/maps?cid=7863953685242921386');
    } catch (_) {
      if (mounted) {
        await AppTheme.showNotification(
          context,
          message: 'Could not open Google Maps. Please try again.',
          isError: true,
        );
      }
    }
  }

  void _expandFlyer(ImageProvider image) {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (overlayContext) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(overlayContext).pop(),
        child: ColoredBox(
          color: CupertinoColors.black.withValues(alpha: .84),
          child: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 64, 20, 24),
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: GestureDetector(
                        // Tapping the flyer keeps it open; the backdrop closes it.
                        onTap: () {},
                        child: Image(
                          image: image,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Text(
                            'Could not load flyer.',
                            style: TextStyle(color: CupertinoColors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 16,
                  child: Semantics(
                    label: 'Close flyer',
                    button: true,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(12),
                      color: CupertinoColors.white.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(24),
                      onPressed: () => Navigator.of(overlayContext).pop(),
                      child: const Icon(
                        CupertinoIcons.xmark,
                        size: 20,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final image = ref.watch(eventFlyerProvider(event));
    final ended = !event.endsAt.isAfter(DateTime.now());
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CupertinoButton(
                  padding: const EdgeInsets.all(10),
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.circular(24),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Icon(
                    CupertinoIcons.chevron_left,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final flyerHeight = (constraints.maxHeight * .48).clamp(
                    180.0,
                    340.0,
                  );
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          label: 'View event flyer',
                          button: image != null,
                          child: GestureDetector(
                            onTap: image == null
                                ? null
                                : () => _expandFlyer(image),
                            child: Container(
                              height: flyerHeight,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: CupertinoColors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: image == null
                                    ? const _FlyerUnavailable()
                                    : Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ImageFiltered(
                                            imageFilter: ui.ImageFilter.blur(
                                              sigmaX: 24,
                                              sigmaY: 24,
                                            ),
                                            child: Transform.scale(
                                              scale: 1.2,
                                              child: Image(
                                                image: image,
                                                fit: BoxFit.cover,
                                                excludeFromSemantics: true,
                                                errorBuilder: (_, _, _) =>
                                                    const SizedBox.shrink(),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            child: Image(
                                              image: image,
                                              fit: BoxFit.contain,
                                              loadingBuilder:
                                                  (
                                                    _,
                                                    child,
                                                    progress,
                                                  ) => progress == null
                                                  ? child
                                                  : const Center(
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    ),
                                              errorBuilder: (_, _, _) =>
                                                  const _FlyerUnavailable(),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                CupertinoIcons.calendar,
                                size: 22,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      DateFormat(
                                        'EEE, MMM d',
                                        'en_US',
                                      ).format(event.localStart),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      eventTimeLabel(event),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 1,
                                height: 36,
                                color: AppTheme.backgroundColor,
                              ),
                              const SizedBox(width: 16),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 110,
                                ),
                                child: Text(
                                  event.priceLabel,
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (event.description.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            height: .5,
                            color: AppTheme.textSecondary.withValues(
                              alpha: .18,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'About',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.description,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        const Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            alignment: Alignment.topLeft,
                            onPressed: _openLocation,
                            child: const Text(
                              'Manga Lounge',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                height: 1.6,
                                color: AppTheme.primaryBlue,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoButton(
                  color: const Color(0xFF102D52),
                  disabledColor: AppTheme.textSecondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  borderRadius: BorderRadius.circular(40),
                  onPressed: _opening || ended ? null : _register,
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.ticket,
                        size: 24,
                        color: CupertinoColors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ended ? 'Event ended' : event.registrationLabel,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: CupertinoColors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: _opening
                            ? const CupertinoActivityIndicator(
                                color: CupertinoColors.white,
                              )
                            : const Icon(
                                CupertinoIcons.arrow_right,
                                size: 22,
                                color: CupertinoColors.white,
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlyerUnavailable extends StatelessWidget {
  const _FlyerUnavailable();
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.photo, color: AppTheme.textSecondary, size: 28),
        SizedBox(height: 8),
        Text(
          'Could not load flyer.',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
      ],
    ),
  );
}
