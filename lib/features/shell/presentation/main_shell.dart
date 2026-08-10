import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

/// Bottom tab scaffold for the signed-in app: Home, Events, Manga, Settings.
/// Each tab is a StatefulShellRoute branch so tab state survives switching.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(
        children: [
          Expanded(child: navigationShell),
          CupertinoTabBar(
            currentIndex: navigationShell.currentIndex,
            activeColor: AppTheme.primaryBlue,
            onTap: (index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.house_fill),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.ticket_fill),
                label: 'Events',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.book_fill),
                label: 'Manga',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
