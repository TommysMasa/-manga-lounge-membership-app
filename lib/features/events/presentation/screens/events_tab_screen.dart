import 'package:flutter/cupertino.dart';

import '../../../../shared/theme/app_theme.dart';

/// Events tab placeholder until the events feed ships.
class EventsTabScreen extends StatelessWidget {
  const EventsTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      navigationBar: CupertinoNavigationBar(middle: Text('Events')),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.sparkles,
                size: 56,
                color: AppTheme.primaryOrange,
              ),
              SizedBox(height: 16),
              Text(
                'Coming soon',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 8),
              Text(
                'Store events and announcements will live here.',
                style: TextStyle(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
