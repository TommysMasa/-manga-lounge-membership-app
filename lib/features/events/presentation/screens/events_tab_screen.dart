import 'package:flutter/cupertino.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/launch_url.dart';

/// Events tab placeholder until the in-app events feed ships. Points to the
/// website schedule in the meantime.
class EventsTabScreen extends StatelessWidget {
  const EventsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: const CupertinoNavigationBar(middle: Text('Events')),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'This feature is coming soon on the app.',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'For now, please check our website for event information.',
                  style: TextStyle(color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                CupertinoButton(
                  onPressed: () => launchURL('https://mangalounge.com/schedule'),
                  child: const Text('mangalounge.com/schedule'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
