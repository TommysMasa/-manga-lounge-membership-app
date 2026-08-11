import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

/// Bottom tab scaffold for the signed-in app: Home, Events, Manga, Settings.
/// Floating rounded bar with an indicator line above the active tab.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    (icon: CupertinoIcons.house_fill, label: 'Home'),
    (icon: CupertinoIcons.ticket_fill, label: 'Events'),
    (icon: CupertinoIcons.book_fill, label: 'Manga'),
    (icon: CupertinoIcons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundColor,
      child: Column(
        children: [
          Expanded(child: navigationShell),
          SafeArea(
            top: false,
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: CupertinoColors.black.withValues(alpha: 0.07),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  for (var i = 0; i < _tabs.length; i += 1)
                    Expanded(
                      child: _TabItem(
                        icon: _tabs[i].icon,
                        label: _tabs[i].label,
                        active: navigationShell.currentIndex == i,
                        onTap: () {
                          if (i != navigationShell.currentIndex) {
                            HapticFeedback.selectionClick();
                          }
                          navigationShell.goBranch(
                            i,
                            initialLocation: i == navigationShell.currentIndex,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.primaryBlue : const Color(0xFF9A9A9A);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Indicator line above the active tab
          Container(
            width: 36,
            height: 3,
            margin: const EdgeInsets.only(bottom: 7),
            decoration: BoxDecoration(
              color: active ? AppTheme.primaryBlue : const Color(0x00000000),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(3),
              ),
            ),
          ),
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
