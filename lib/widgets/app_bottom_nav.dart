import 'package:flutter/material.dart';

import '../ToDo_admin.dart';
import '../ToDo_user.dart';
import '../annoncement_admin.dart';
import '../annoncement_user.dart';
import '../dash_admin.dart';
import '../dash_mem.dart';
import '../event_screen_admin.dart';
import '../event_screen_user.dart';
import '../members_directory_admin.dart';
import '../members_directory_member.dart';
import '../settings_admin.dart';
import '../setting_user.dart';

/// Every destination reachable from the bottom bar.
enum AppTab { home, events, members, announcements, tasks, settings }

/// A single, reusable bottom navigation bar used across every screen.
///
/// Centralising the bar here means the Home tab (and any future styling
/// changes) only need to be defined once, instead of separately inside
/// every screen as before.
class AppBottomNav extends StatelessWidget {
  final AppTab currentTab;
  final bool isAdmin;

  const AppBottomNav({
    super.key,
    required this.currentTab,
    required this.isAdmin,
  });

  static const Color _barColor = Color(0xFFF7D990);
  static const Color _activeColor = Color(0xFF1F2A37);
  static const Color _inactiveColor = Color(0xFF7A7365);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: _barColor,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _navItem(
                context,
                tab: AppTab.home,
                icon: Icons.home_rounded,
              ),
              _navItem(
                context,
                tab: AppTab.events,
                icon: Icons.calendar_month_rounded,
                assetPath: "assets/icons/calendar (2).png",
              ),
              _navItem(
                context,
                tab: AppTab.members,
                icon: Icons.people_alt_rounded,
                assetPath: "assets/icons/profile (2).png",
              ),
              _navItem(
                context,
                tab: AppTab.announcements,
                icon: Icons.campaign_rounded,
                assetPath: "assets/icons/announcement (2).png",
              ),
              _navItem(
                context,
                tab: AppTab.tasks,
                icon: Icons.task_alt_rounded,
                assetPath: "assets/icons/task1.png",
              ),
              _navItem(
                context,
                tab: AppTab.settings,
                icon: Icons.settings_rounded,
                assetPath: "assets/icons/settings (2).png",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required AppTab tab,
    required IconData icon,
    String? assetPath,
  }) {
    final bool active = tab == currentTab;
    final Color color = active ? _activeColor : _inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _goTo(context, tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white.withValues(alpha: 0.55) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: assetPath == null
            ? Icon(icon, size: 26, color: color)
            : Image.asset(assetPath, height: 26, color: color),
      ),
    );
  }

  void _goTo(BuildContext context, AppTab tab) {
    if (tab == currentTab) return;

    final Widget destination = isAdmin ? _adminDestination(tab) : _userDestination(tab);

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  Widget _adminDestination(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const DashboardPageAdmin();
      case AppTab.events:
        return const EventsScreenAdmin();
      case AppTab.members:
        return const MemberDirectoryAdmin();
      case AppTab.announcements:
        return const AnnouncementsAdmin();
      case AppTab.tasks:
        return const AdminWeeklyTaskScreen();
      case AppTab.settings:
        return const SettingsPageAdmin();
    }
  }

  Widget _userDestination(AppTab tab) {
    switch (tab) {
      case AppTab.home:
        return const DashboardPage();
      case AppTab.events:
        return const EventsScreen();
      case AppTab.members:
        return const MemberDirectoryUser();
      case AppTab.announcements:
        return const AnnouncementsPage();
      case AppTab.tasks:
        return const UserWeeklyTaskScreen();
      case AppTab.settings:
        return const SettingsPage();
    }
  }
}
