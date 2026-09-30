import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../shared/widgets/hy_card.dart';
import '../viewmodel/achievements_viewmodel.dart';

/// Clean Apple Fitness Awards style Achievements screen.
/// Displays user badges with authentic Apple SF Symbols (CupertinoIcons),
/// native iOS spring touch interactions, and Apple Activity medallion aesthetic.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  int _selectedFilter = 0; // 0: All, 1: Earned, 2: Locked

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(achievementsViewModelProvider);
    final progress = state.progress;

    final badges = _buildBadges(progress);
    final unlockedCount = badges.where((b) => b.isUnlocked).length;
    final totalCount = badges.length;
    final overallRatio = totalCount > 0 ? (unlockedCount / totalCount) : 0.0;

    final filteredBadges = badges.where((b) {
      if (_selectedFilter == 1) return b.isUnlocked;
      if (_selectedFilter == 2) return !b.isUnlocked;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Apple Large Title iOS Navigation Bar ───────────
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 110,
            backgroundColor: AppColors.systemGroupedBackground,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 16, bottom: 14),
              title: Text(
                'Achievements',
                style: TextStyle(
                  color: AppColors.label,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // ── Apple Fitness Overview Card ────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.xs,
              ),
              child: HYCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Glowing Apple Awards Rosette Medal
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFFFFD200), Color(0xFFF7971E)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF7971E).withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.rosette,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Badge Showcase',
                                style: AppTypography.subheadlineSemibold,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$unlockedCount / $totalCount Badges Earned',
                                style: AppTypography.footnote.copyWith(
                                  color: AppColors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '%${(overallRatio * 100).toInt()}',
                          style: AppTypography.title3.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Apple-style smooth progress indicator
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: overallRatio,
                        minHeight: 7,
                        backgroundColor: AppColors.systemFill,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Segmented Filter ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: CupertinoSlidingSegmentedControl<int>(
                groupValue: _selectedFilter,
                backgroundColor: AppColors.systemFill,
                thumbColor: AppColors.secondaryGroupedBackground,
                padding: const EdgeInsets.all(3),
                children: {
                  0: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    child: Text(
                      'All ($totalCount)',
                      style: AppTypography.caption1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  1: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    child: Text(
                      'Earned ($unlockedCount)',
                      style: AppTypography.caption1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  2: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                    child: Text(
                      'Locked (${totalCount - unlockedCount})',
                      style: AppTypography.caption1.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                },
                onValueChanged: (val) {
                  if (val != null) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedFilter = val);
                  }
                },
              ),
            ),
          ),

          // ── Badges Grid ───────────────────────────────────
          if (filteredBadges.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Center(
                  child: Text(
                    _selectedFilter == 1
                        ? 'No badges earned yet.\nComplete your first practice to get started!'
                        : 'All badges earned!',
                    textAlign: TextAlign.center,
                    style: AppTypography.subheadline.copyWith(
                      color: AppColors.secondaryLabel,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 0.76,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final badge = filteredBadges[index];
                    return _AppleBadgeItem(
                      badge: badge,
                      onTap: () => _showBadgeDetailSheet(context, badge),
                    );
                  },
                  childCount: filteredBadges.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetailSheet(BuildContext context, _AchievementBadge badge) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.38),
      isScrollControlled: true,
      builder: (_) => _AppleBadgeDetailModal(badge: badge),
    );
  }

  List<_AchievementBadge> _buildBadges(dynamic progress) {
    final totalPractices = (progress?.totalPractices as int?) ?? 0;
    final totalWorkouts = (progress?.totalWorkouts as int?) ?? 0;
    final totalMinutes = (progress?.totalMinutes as int?) ?? 0;
    final currentStreak = (progress?.currentStreak as int?) ?? 0;
    final longestStreak = (progress?.longestStreak as int?) ?? 0;
    final streak = math.max(currentStreak, longestStreak);

    return [
      _AchievementBadge(
        id: 'first_practice',
        title: 'First Step',
        category: 'Getting Started',
        description: 'Complete your first yoga session on your Home Yoga journey.',
        icon: CupertinoIcons.sparkles,
        gradientColors: const [Color(0xFFFFD200), Color(0xFFF7971E)],
        currentProgress: totalPractices,
        targetProgress: 1,
        unit: 'practices',
      ),
      _AchievementBadge(
        id: 'streak_7',
        title: '7-Day Streak',
        category: 'Consistency',
        description: 'Step onto your mat every day for 7 days to keep the daily streak alive.',
        icon: CupertinoIcons.flame_fill,
        gradientColors: const [Color(0xFFFF5E36), Color(0xFFFF2A68)],
        currentProgress: streak,
        targetProgress: 7,
        unit: 'days',
      ),
      _AchievementBadge(
        id: 'practices_10',
        title: '10 Practices',
        category: 'Milestone',
        description: 'Complete 10 yoga sessions in total with awareness and discipline.',
        icon: CupertinoIcons.leaf_arrow_circlepath,
        gradientColors: const [Color(0xFF00C97B), Color(0xFF00B294)],
        currentProgress: totalPractices,
        targetProgress: 10,
        unit: 'practices',
      ),
      _AchievementBadge(
        id: 'workouts_25',
        title: '25 Workouts',
        category: 'Strength & Focus',
        description: 'Complete 25 yoga workouts to build your strength and balance.',
        icon: CupertinoIcons.bolt_fill,
        gradientColors: const [Color(0xFFFF9500), Color(0xFFFF5E3A)],
        currentProgress: totalWorkouts,
        targetProgress: 25,
        unit: 'workouts',
      ),
      _AchievementBadge(
        id: 'minutes_100',
        title: '100 Minutes',
        category: 'Mindfulness',
        description: 'Spend 100 minutes on the mat in total and rest your mind.',
        icon: CupertinoIcons.heart_fill,
        gradientColors: const [Color(0xFFFF2D55), Color(0xFFE0245E)],
        currentProgress: totalMinutes,
        targetProgress: 100,
        unit: 'minutes',
      ),
      _AchievementBadge(
        id: 'streak_30',
        title: '30-Day Rhythm',
        category: 'Consistency',
        description: 'Practise without a break for a full month (30 days) to lock in the routine.',
        icon: CupertinoIcons.star_fill,
        gradientColors: const [Color(0xFF5856D6), Color(0xFF7B1FA2)],
        currentProgress: streak,
        targetProgress: 30,
        unit: 'days',
      ),
      _AchievementBadge(
        id: 'workouts_50',
        title: '50 Workouts',
        category: 'Strength & Focus',
        description: 'Build a lasting exercise habit with 50 yoga workouts.',
        icon: CupertinoIcons.shield_fill,
        gradientColors: const [Color(0xFF007AFF), Color(0xFF00C7BE)],
        currentProgress: totalWorkouts,
        targetProgress: 50,
        unit: 'workouts',
      ),
      _AchievementBadge(
        id: 'minutes_500',
        title: '500 Minutes',
        category: 'Mindfulness',
        description: 'Reach 500 minutes of deep yoga practice and feel renewed.',
        icon: CupertinoIcons.timer,
        gradientColors: const [Color(0xFF30B0C7), Color(0xFF007AFF)],
        currentProgress: totalMinutes,
        targetProgress: 500,
        unit: 'minutes',
      ),
      _AchievementBadge(
        id: 'practices_100',
        title: '100 Practices',
        category: 'Mastery',
        description: 'Complete 100 yoga sessions and become a true master.',
        icon: CupertinoIcons.rosette,
        gradientColors: const [Color(0xFFAF52DE), Color(0xFFFF2D55)],
        currentProgress: totalPractices,
        targetProgress: 100,
        unit: 'practices',
      ),
      _AchievementBadge(
        id: 'streak_365',
        title: '365-Day Legend',
        category: 'Legendary',
        description: 'Practise yoga without missing a day for a full year and become a legend.',
        icon: CupertinoIcons.sun_max_fill,
        gradientColors: const [Color(0xFFFFD700), Color(0xFFFF8C00)],
        currentProgress: streak,
        targetProgress: 365,
        unit: 'days',
      ),
    ];
  }
}

/// Data model for an achievement badge
class _AchievementBadge {
  final String id;
  final String title;
  final String category;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final int currentProgress;
  final int targetProgress;
  final String unit;

  const _AchievementBadge({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.currentProgress,
    required this.targetProgress,
    required this.unit,
  });

  bool get isUnlocked => currentProgress >= targetProgress;

  double get progressRatio {
    if (targetProgress <= 0) return 1.0;
    return (currentProgress / targetProgress).clamp(0.0, 1.0);
  }

  int get progressPercent => (progressRatio * 100).toInt();
}

/// Tactile Apple-style spring press wrapper.
/// Responds instantly with scale-down, opacity fade and subtle haptics.
class _ApplePressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _ApplePressable({
    required this.child,
    required this.onTap,
  });

  @override
  State<_ApplePressable> createState() => _ApplePressableState();
}

class _ApplePressableState extends State<_ApplePressable>
    with SingleTickerProviderStateMixin {
  static const double _pressedScale = 0.92;
  static const double _pressedOpacity = 0.82;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(begin: 1.0, end: _pressedScale).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _opacity = Tween<double>(begin: 1.0, end: _pressedOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: Opacity(
              opacity: _opacity.value,
              child: child,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Apple Watch / Fitness styled badge item widget with tactile spring press
class _AppleBadgeItem extends StatelessWidget {
  final _AchievementBadge badge;
  final VoidCallback onTap;

  const _AppleBadgeItem({
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;

    return _ApplePressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Apple Medal Circle ────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Outer Medallion Bezel
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isUnlocked
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: badge.gradientColors,
                        )
                      : null,
                  color: isUnlocked ? null : const Color(0xFFE5E5EA),
                  boxShadow: isUnlocked
                      ? [
                          BoxShadow(
                            color: badge.gradientColors.first.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                  border: Border.all(
                    color: isUnlocked
                        ? Colors.white.withValues(alpha: 0.5)
                        : const Color(0xFFD1D1D6),
                    width: isUnlocked ? 2.0 : 1.5,
                  ),
                ),
                child: Center(
                  child: Icon(
                    badge.icon,
                    size: 30,
                    color: isUnlocked
                        ? Colors.white
                        : const Color(0xFF8E8E93).withValues(alpha: 0.6),
                  ),
                ),
              ),

              // Locked Padlock Indicator Badge
              if (!isUnlocked)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.systemBackground,
                      border: Border.all(
                        color: const Color(0xFFD1D1D6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.lock_fill,
                        size: 11,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Badge Title ───────────────────────────────────
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption1.copyWith(
              fontWeight: FontWeight.w600,
              color: isUnlocked ? AppColors.label : AppColors.secondaryLabel,
            ),
          ),

          const SizedBox(height: 2),

          // ── Subtitle / Status ─────────────────────────────
          if (isUnlocked)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 11,
                  color: AppColors.systemGreen,
                ),
                const SizedBox(width: 2),
                Text(
                  'Earned',
                  style: AppTypography.caption2.copyWith(
                    color: AppColors.systemGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            Text(
              '${badge.currentProgress}/${badge.targetProgress}',
              style: AppTypography.caption2.copyWith(
                color: AppColors.tertiaryLabel,
              ),
            ),
        ],
      ),
    );
  }
}

/// Apple-style Award Detail Sheet shown on badge tap with frosted blur & spring animations
class _AppleBadgeDetailModal extends StatelessWidget {
  final _AchievementBadge badge;

  const _AppleBadgeDetailModal({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = badge.isUnlocked;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSpacing.radiusSheet),
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: AppColors.systemBackground.withValues(alpha: 0.94),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusSheet),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // iOS Drag Handle
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.opaqueSeparator,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Large Apple Award Medal with subtle entrance bounce
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.82, end: 1.0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isUnlocked
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: badge.gradientColors,
                          )
                        : null,
                    color: isUnlocked ? null : const Color(0xFFE5E5EA),
                    boxShadow: isUnlocked
                        ? [
                            BoxShadow(
                              color: badge.gradientColors.first.withValues(alpha: 0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                    border: Border.all(
                      color: isUnlocked
                          ? Colors.white.withValues(alpha: 0.7)
                          : const Color(0xFFD1D1D6),
                      width: 3.0,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      badge.icon,
                      size: 44,
                      color: isUnlocked
                          ? Colors.white
                          : const Color(0xFF8E8E93).withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Category Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.systemFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge.category.toUpperCase(),
                  style: AppTypography.caption2.copyWith(
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Badge Title
              Text(
                badge.title,
                style: AppTypography.title2.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xs),

              // Description
              Text(
                badge.description,
                style: AppTypography.subheadline.copyWith(
                  color: AppColors.secondaryLabel,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Progress Box
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.systemGroupedBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isUnlocked ? 'Status: Completed' : 'Progress',
                          style: AppTypography.footnoteSemibold.copyWith(
                            color: isUnlocked
                                ? AppColors.systemGreen
                                : AppColors.secondaryLabel,
                          ),
                        ),
                        Text(
                          '${badge.currentProgress} / ${badge.targetProgress} ${badge.unit}',
                          style: AppTypography.footnoteSemibold.copyWith(
                            color: isUnlocked
                                ? AppColors.systemGreen
                                : AppColors.label,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: badge.progressRatio,
                        minHeight: 6,
                        backgroundColor: AppColors.systemFill,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isUnlocked
                              ? AppColors.systemGreen
                              : badge.gradientColors.first,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Apple Action Button
              _ApplePressable(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.systemFill,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: AppTypography.headline.copyWith(
                        color: AppColors.label,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
