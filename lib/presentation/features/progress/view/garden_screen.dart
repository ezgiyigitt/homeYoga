import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/date_key.dart';
import '../../../../core/utils/plant_level.dart';
import '../viewmodel/achievements_viewmodel.dart';
import '../widgets/plant_sprite_widget.dart';

/// Full-screen Garden / Progress view that lives inside the MainShell
/// so the bottom navigation bar remains visible and interactive.
class GardenScreen extends ConsumerWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(achievementsViewModelProvider);
    final dailyLog = state.dailyLog;

    final today = dateOnly(DateTime.now());
    // This week's Monday
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    // The user starts their 52-week journey from their first practice week or current week
    final firstLogDate = earliestLoggedDate(dailyLog);
    final journeyStartMonday = firstLogDate != null && firstLogDate.isBefore(thisWeekStart)
        ? firstLogDate.subtract(Duration(days: firstLogDate.weekday - 1))
        : thisWeekStart;

    final weeks = List<DateTime>.generate(
      AppConstants.gardenWeeksCount,
      (i) => journeyStartMonday.add(Duration(days: 7 * i)),
    );

    // Current week index (W1 for new users)
    final currentWeekIndex = weeks.indexWhere(
      (w) => w.year == thisWeekStart.year && w.month == thisWeekStart.month && w.day == thisWeekStart.day,
    );

    final currentLevel = computeWeekPlantLevel(
      weekStart: thisWeekStart,
      dailyLog: dailyLog,
      today: today,
    );

    final activeLocale = Localizations.localeOf(context).languageCode;
    final isTr = activeLocale == 'tr';

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: AppBar(
        title: Text(
          isTr ? 'Gelişim Bahçesi' : 'Progress Garden',
          style: TextStyle(
            color: AppColors.label,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.systemGroupedBackground,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ── Header Summary Card ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: AppSpacing.xs,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryGroupedBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.separator.withValues(alpha: 0.5), width: 0.6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.local_florist_rounded,
                          color: AppColors.primaryDark,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isTr ? '52 Haftalık Bahçen' : 'Your 52-Week Garden',
                            style: AppTypography.subheadlineSemibold.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _currentLevelSummary(currentLevel, isTr),
                            style: AppTypography.caption1.copyWith(
                              color: AppColors.secondaryLabel,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

          // ── Section Title ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenHorizontal,
                vertical: 4,
              ),
              child: Text(
                'YEARLY PROGRESS',
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),

          // ── 52 Pots Grid ─────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenHorizontal,
              vertical: 8,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 125,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final weekStart = weeks[index];
                  final isFuture = weekStart.isAfter(today);
                  final isCurrentWeek = index == currentWeekIndex;
                  final weekNumber = index + 1;

                  final level = isFuture
                      ? 0
                      : computeWeekPlantLevel(
                          weekStart: weekStart,
                          dailyLog: dailyLog,
                          today: today,
                        );
                  final sprite = PlantSpriteState.fromLevel(level);

                  return GestureDetector(
                    onTap: () => _showWeekDetail(
                      context,
                      weekNumber: weekNumber,
                      weekStart: weekStart,
                      isCurrentWeek: isCurrentWeek,
                      isFuture: isFuture,
                      level: level,
                      sprite: sprite,
                      dailyLog: dailyLog,
                      today: today,
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGroupedBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrentWeek
                              ? AppColors.primary
                              : AppColors.separator.withValues(alpha: 0.7),
                          width: isCurrentWeek ? 2 : 0.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isCurrentWeek
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.black.withValues(alpha: 0.02),
                            blurRadius: isCurrentWeek ? 8 : 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Week header & badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'W$weekNumber',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isCurrentWeek ? FontWeight.w800 : FontWeight.w600,
                                  color: isCurrentWeek ? AppColors.primary : AppColors.secondaryLabel,
                                ),
                              ),
                              if (isCurrentWeek)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Text(
                                    'NOW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          // Big Pot Sprite
                          Expanded(
                            child: Center(
                              child: Opacity(
                                opacity: isFuture ? 0.3 : 1.0,
                                child: PlantSpriteWidget(
                                  assetPath: sprite.assetPath,
                                  frameIndex: sprite.frameIndex,
                                  height: 88,
                                ),
                              ),
                            ),
                          ),

                          // Status Label
                          Text(
                            isFuture
                                ? (isTr ? 'Kilitli' : 'Locked')
                                : (level == 0
                                    ? (isTr ? 'Tohum' : 'Seedling')
                                    : (level == 1
                                        ? (isTr ? 'Filiz (+1)' : 'Sprout (+1)')
                                        : (level == 2
                                            ? (isTr ? 'Kökleniyor (+2)' : 'Growing (+2)')
                                            : (level == 3
                                                ? (isTr ? 'Yapraklı (+3)' : 'Leafy (+3)')
                                                : (level == 4
                                                    ? (isTr ? 'Tomurcuk (+4)' : 'Budding (+4)')
                                                    : (level >= 5
                                                        ? (isTr ? 'Çiçek (+$level)' : 'Bloomed (+$level)')
                                                        : (isTr ? 'Soluyor' : 'Wilting'))))))),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isFuture
                                  ? AppColors.tertiaryLabel
                                  : (level > 0
                                      ? AppColors.systemGreen
                                      : (level < 0 ? AppColors.systemOrange : AppColors.secondaryLabel)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: weeks.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  String _currentLevelSummary(int level, bool isTr) {
    if (level == 0) {
      return isTr
          ? 'Bu haftanın saksısı hazır. İlk filizi çıkarmak için bugünün seansını tamamla.'
          : 'This week\'s pot is ready. Complete today\'s practice to sprout the first shoot.';
    } else if (level == 1) {
      return isTr
          ? 'Haftanın ilk seansını tamamladın (+1). Saksında taze bir filiz yeşerdi.'
          : 'First practice completed (+1). A fresh sprout is growing in your pot.';
    } else if (level == 2) {
      return isTr
          ? '2 gün üst üste pratik (+2)! Bitkin kökleniyor ve gövdesi güçleniyor.'
          : 'Two days in a row (+2)! Your plant is taking strong root and growing taller.';
    } else if (level == 3) {
      return isTr
          ? '3 seans tamamlandı (+3)! Yeni yapraklar açıyor, canlılığı belirginleşiyor.'
          : 'Three sessions done (+3)! New leaves are unfolding steadily.';
    } else if (level == 4) {
      return isTr
          ? '4 gün harika disiplin (+4)! Çiçek tomurcukları belirmeye başladı.'
          : 'Four days completed (+4)! Flower buds are forming.';
    } else if (level >= 5) {
      return isTr
          ? 'Muhteşem bir hafta (+$level)! Disiplinin sayesinde saksın çiçek açtı.'
          : 'Incredible week (+$level)! Your plant has fully blossomed into a flower.';
    } else {
      return isTr
          ? 'Bu hafta biraz aksadı. Yeni bir seansla bitkine can suyu ver.'
          : 'This week slipped a little. A new session will bring your pot back to life.';
    }
  }

  void _showWeekDetail(
    BuildContext context, {
    required int weekNumber,
    required DateTime weekStart,
    required bool isCurrentWeek,
    required bool isFuture,
    required int level,
    required PlantSpriteState sprite,
    required Map<String, String> dailyLog,
    required DateTime today,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeekDetailModal(
        weekNumber: weekNumber,
        weekStart: weekStart,
        isCurrentWeek: isCurrentWeek,
        isFuture: isFuture,
        level: level,
        sprite: sprite,
        dailyLog: dailyLog,
        today: today,
      ),
    );
  }
}

class _WeekDetailModal extends StatelessWidget {
  final int weekNumber;
  final DateTime weekStart;
  final bool isCurrentWeek;
  final bool isFuture;
  final int level;
  final PlantSpriteState sprite;
  final Map<String, String> dailyLog;
  final DateTime today;

  const _WeekDetailModal({
    required this.weekNumber,
    required this.weekStart,
    required this.isCurrentWeek,
    required this.isFuture,
    required this.level,
    required this.sprite,
    required this.dailyLog,
    required this.today,
  });

  static const _monthNamesEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  static const _monthNamesTr = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
  ];

  static const _dayLabelsEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _dayLabelsTr = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

  String _formatRange(bool isTr) {
    final end = weekStart.add(const Duration(days: 6));
    final months = isTr ? _monthNamesTr : _monthNamesEn;
    final startMonth = months[weekStart.month - 1];
    final endMonth = months[end.month - 1];

    if (startMonth == endMonth) {
      return '${weekStart.day} — ${end.day} $startMonth';
    }
    return '${weekStart.day} $startMonth — ${end.day} $endMonth';
  }

  String _statusBadgeText(int level, bool isFuture, bool isTr) {
    if (isFuture) return isTr ? 'Kilitli Hafta' : 'Locked Week';
    if (level == 0) return isTr ? 'Tohum Ekildi' : 'Seedling (Just Planted)';
    if (level == 1) return isTr ? 'İlk Filiz Çıktı (+1)' : 'First Sprout (+1)';
    if (level == 2) return isTr ? 'Kökleniyor & Büyüyor (+2)' : 'Rooting & Growing (+2)';
    if (level == 3) return isTr ? 'Yapraklar Açıyor (+3)' : 'Leaves Sprouting (+3)';
    if (level == 4) return isTr ? 'Tomurcuklandı (+4)' : 'Budding (+4)';
    if (level >= 5) return isTr ? 'Çiçek Açtı (+$level)' : 'In Full Bloom (+$level)';
    return isTr ? 'Can Suyu Bekliyor' : 'Wilting (Needs Practice)';
  }

  String _statusDescription(int level, bool isFuture, bool isTr) {
    if (isFuture) {
      return isTr
          ? 'Bu haftaya henüz gelmedin. Zamanı geldiğinde saksın otomatik olarak açılacak.'
          : 'You haven\'t reached this week yet. Your pot will activate automatically when the time comes.';
    }
    if (level == 0) {
      return isTr
          ? 'Bu haftanın saksısı hazır. İlk filizi çıkarmak için bugünün seansını tamamla.'
          : 'This week\'s pot is ready. Complete today\'s session to sprout the first shoot.';
    }
    if (level == 1) {
      return isTr
          ? 'Harika bir başlangıç! Haftanın ilk seansıyla saksında taze bir filiz yeşerdi.'
          : 'Great start! Your first practice this week sprouted a fresh little shoot in your pot.';
    }
    if (level == 2) {
      return isTr
          ? 'İki gün üst üste pratik yaptın! Bitkin kökleniyor, gövdesi güçleniyor ve boy atıyor.'
          : 'Two days of practice! Your plant is taking strong root and growing taller.';
    }
    if (level == 3) {
      return isTr
          ? 'İstikrarın harika! 3 seansla bitkin yeni yapraklar açıyor, canlılığı gözle görülüyor.'
          : 'Steady progress! With 3 sessions, your plant is unfolding fresh leaves and flourishing.';
    }
    if (level == 4) {
      return isTr
          ? 'Çiçek açmaya çok az kaldı! 4 seanslık muazzam disiplinin sayesinde tomurcuklar belirdi.'
          : 'Almost in full bloom! Thanks to your 4 days of dedication, flower buds are forming.';
    }
    if (level >= 5) {
      return isTr
          ? 'Tebrikler! Bu haftaki muazzam disiplinin sayesinde saksın rengarenk çiçek açtı.'
          : 'Incredible dedication! Your plant has fully blossomed into a vibrant flower this week.';
    }
    return isTr
        ? 'Bu hafta bazı günler aksadı. Bitkine can suyu vermek için bugünün seansını tamamla.'
        : 'Some days slipped this week. Complete today\'s practice to bring your plant back to life.';
  }

  @override
  Widget build(BuildContext context) {
    final activeLocale = Localizations.localeOf(context).languageCode;
    final isTr = activeLocale == 'tr';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.systemGroupedBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        12,
        AppSpacing.screenHorizontal,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.systemGray3,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 16),

          // Header: Week badge & title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCurrentWeek ? AppColors.primary : AppColors.systemGray5,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'W$weekNumber',
                      style: TextStyle(
                        color: isCurrentWeek ? Colors.white : AppColors.secondaryLabel,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentWeek
                            ? (isTr ? 'Bu Haftanın Bahçesi' : "This Week's Garden")
                            : (isTr ? '$weekNumber. Hafta İlerlemesi' : 'Week $weekNumber Progress'),
                        style: AppTypography.headline.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        _formatRange(isTr),
                        style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 22),
                color: AppColors.secondaryLabel,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Plant Stage Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.separator.withValues(alpha: 0.5), width: 0.6),
            ),
            child: Column(
              children: [
                Opacity(
                  opacity: isFuture ? 0.35 : 1.0,
                  child: PlantSpriteWidget(
                    assetPath: sprite.assetPath,
                    frameIndex: sprite.frameIndex,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 12),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isFuture
                        ? AppColors.systemGray5
                        : (level > 0
                            ? AppColors.systemGreen.withValues(alpha: 0.15)
                            : (level < 0
                                ? AppColors.systemOrange.withValues(alpha: 0.15)
                                : AppColors.primaryContainer)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFuture
                            ? Icons.lock_outline_rounded
                            : (level > 0
                                ? Icons.eco_rounded
                                : (level < 0 ? Icons.water_drop_outlined : Icons.park_outlined)),
                        size: 14,
                        color: isFuture
                            ? AppColors.secondaryLabel
                            : (level > 0
                                ? AppColors.systemGreen
                                : (level < 0 ? AppColors.systemOrange : AppColors.primaryDark)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _statusBadgeText(level, isFuture, isTr),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isFuture
                              ? AppColors.secondaryLabel
                              : (level > 0
                                  ? AppColors.systemGreen
                                  : (level < 0 ? AppColors.systemOrange : AppColors.primaryDark)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    _statusDescription(level, isFuture, isTr),
                    textAlign: TextAlign.center,
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.secondaryLabel,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 7-Day Mini Tracker
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.separator.withValues(alpha: 0.5), width: 0.6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isTr ? 'HAFTANIN GÜNLERİ' : 'DAYS OF THE WEEK',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.secondaryLabel,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final dayDate = weekStart.add(Duration(days: i));
                    final dayKey = dateKey(dayDate);
                    final status = dailyLog[dayKey];
                    final isPastDay = dayDate.isBefore(today);
                    final isToday = dayDate.year == today.year &&
                        dayDate.month == today.month &&
                        dayDate.day == today.day;
                    
                    final dayLabels = isTr ? _dayLabelsTr : _dayLabelsEn;

                    Color circleColor;
                    Widget iconWidget;

                    if (status == AppConstants.dayStatusDone) {
                      circleColor = AppColors.systemGreen.withValues(alpha: 0.18);
                      iconWidget = const Icon(
                        Icons.check_rounded,
                        size: 15,
                        color: AppColors.systemGreen,
                      );
                    } else if (status == AppConstants.dayStatusOff) {
                      circleColor = AppColors.systemGray5;
                      iconWidget = Icon(
                        Icons.spa_rounded,
                        size: 13,
                        color: AppColors.secondaryLabel,
                      );
                    } else if (isPastDay) {
                      circleColor = AppColors.systemOrange.withValues(alpha: 0.15);
                      iconWidget = const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.systemOrange,
                      );
                    } else if (isToday) {
                      circleColor = AppColors.primaryContainer;
                      iconWidget = Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      );
                    } else {
                      circleColor = AppColors.systemGray6;
                      iconWidget = const SizedBox();
                    }

                    return Column(
                      children: [
                        Text(
                          dayLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                            color: isToday ? AppColors.primary : AppColors.secondaryLabel,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: circleColor,
                            shape: BoxShape.circle,
                            border: isToday
                                ? Border.all(color: AppColors.primary, width: 1.5)
                                : null,
                          ),
                          child: Center(child: iconWidget),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${dayDate.day}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isToday ? AppColors.label : AppColors.tertiaryLabel,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Bottom Action Button
          if (isCurrentWeek)
            Builder(
              builder: (context) {
                final isTodayDone = dailyLog[dateKey(today)] == AppConstants.dayStatusDone;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.push(RouteNames.workout);
                    },
                    icon: Icon(
                      isTodayDone ? Icons.check_circle_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      isTodayDone
                          ? (isTr ? 'Bugün Tamamlandı ✓ (Tekrar Yap)' : 'Completed Today ✓ (Do It Again)')
                          : (isTr ? 'Bugünün Seansını Başlat' : 'Start Today\'s Practice'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isTodayDone ? AppColors.systemGreen : AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                );
              },
            )
          else
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  isTr ? 'Kapat' : 'Close',
                  style: TextStyle(
                    color: AppColors.label,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
