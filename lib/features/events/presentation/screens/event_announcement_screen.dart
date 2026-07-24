import 'package:flutter/cupertino.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/launch_url.dart';

/// Full-screen event flyer shown when a push notification is tapped.
///
/// Opened with query params `imageUrl` and `ticketUrl` (and optional
/// `title`) from FCM custom data. Tapping the image or the CTA opens
/// [ticketUrl] in an external browser.
class EventAnnouncementScreen extends StatelessWidget {
  const EventAnnouncementScreen({
    super.key,
    required this.imageUrl,
    required this.ticketUrl,
    this.title = 'Event',
  });

  final String imageUrl;
  final String ticketUrl;
  final String title;

  Future<void> _openTickets(BuildContext context) async {
    final url = ticketUrl.trim();
    if (url.isEmpty) return;
    try {
      await launchURL(url);
    } catch (_) {
      if (context.mounted) {
        AppTheme.showNotification(
          context,
          message: 'Could not open the link.',
          isError: true,
        );
      }
    }
  }

  void _close(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      const HomeRoute().go(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final heading = title.trim().isEmpty ? 'Event' : title.trim();

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF0B1220),
      navigationBar: CupertinoNavigationBar(
        backgroundColor: const Color(0xFF0B1220),
        border: null,
        middle: Text(
          heading,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: CupertinoColors.white,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _close(context),
          child: const Icon(
            CupertinoIcons.xmark,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: GestureDetector(
                  onTap: () => _openTickets(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: ColoredBox(
                      color: const Color(0xFF152033),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CupertinoActivityIndicator(
                              color: CupertinoColors.white,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'Could not load the event image.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CupertinoButton(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(28),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    onPressed: () => _openTickets(context),
                    child: const Text(
                      'Get more info',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap the image or the button for more info.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
