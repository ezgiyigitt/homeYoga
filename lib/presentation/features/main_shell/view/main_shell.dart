import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// iOS-style bottom tab bar shell.
///
/// 4 visible tabs: Home, Achievements, Progress, Settings.
/// Coach is reachable via the AI Coach shortcut on Home.
/// [_tabs] points at the StatefulShellRoute branches (indices 0: Home, 2: Achievements, 3: Settings).
///
/// Progress is a *pseudo*-tab: it has no branchIndex of its own and
/// never navigates — tapping it opens the 52-card garden popup on top
/// of whichever branch is currently showing, via [_openGarden].
class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Shell tabs (Home, Achievements, Progress, Settings) are strictly portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: navigationShell,
      bottomNavigationBar: _IOSTabBar(
        currentIndex: navigationShell.currentIndex,
        onTapBranch: (branchIndex) => navigationShell.goBranch(
          branchIndex,
          initialLocation: branchIndex == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _IOSTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTapBranch;

  /// Labels come from the active locale, so the list is built per frame
  /// rather than held as a `const`.
  static List<_Tab> _tabsOf(BuildContext context) {
    final l10n = context.l10n;
    return [
      _Tab(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: l10n.tabHome, branchIndex: 0),
      _Tab(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded, label: l10n.tabAchievements, branchIndex: 2),
      _Tab(icon: Icons.local_florist_outlined, activeIcon: Icons.local_florist_rounded, label: l10n.tabProgress, branchIndex: 4),
      _Tab(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: l10n.tabSettings, branchIndex: 3),
    ];
  }

  const _IOSTabBar({
    required this.currentIndex,
    required this.onTapBranch,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 49 + bottom,
      decoration: BoxDecoration(
        color: AppColors.systemBackground,
        border: Border(
          top: BorderSide(color: AppColors.separator, width: 0.5),
        ),
      ),
      child: Row(
        children: _tabsOf(context).map((tab) {
          final isActive = tab.branchIndex != null && currentIndex == tab.branchIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (tab.branchIndex != null) {
                  onTapBranch(tab.branchIndex!);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Small scale pop on the icon when a tab becomes active —
                  // one of the "little hits of motion" that make the tab
                  // bar feel considered rather than just a static row.
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: isActive ? 0.85 : 1.0, end: 1.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                    child: Icon(
                      isActive ? tab.activeIcon : tab.icon,
                      color: isActive ? AppColors.primary : AppColors.systemGray2,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tab.label,
                    style: AppTypography.tabLabel.copyWith(
                      color: isActive ? AppColors.primary : AppColors.systemGray2,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: bottom),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Index into StatefulShellRoute's branches. Null means this tab
  /// doesn't navigate at all — it's a popup trigger (İlerleme).
  final int? branchIndex;

  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.branchIndex,
  });
}
