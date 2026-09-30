import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_key.dart';
import '../../../../core/utils/plant_level.dart';

/// The İlerleme (Progress) tab's popup: 52 cards, one per week, each
/// holding a real pot sprite — see plant_level.dart for how a week's
/// practiced/off/missed days turn into a level, and [_PlantSprite] for
/// how that level is cropped out of the user-supplied spritesheets.
class WeeklyGardenPopup extends StatelessWidget {
  final Map<String, String> dailyLog;

  const WeeklyGardenPopup({super.key, required this.dailyLog});

  static Future<void> show(BuildContext context, Map<String, String> dailyLog) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WeeklyGardenPopup(dailyLog: dailyLog),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    // This week's Monday.
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final firstLogDate = earliestLoggedDate(dailyLog);
    final journeyStartMonday = firstLogDate != null && firstLogDate.isBefore(thisWeekStart)
        ? firstLogDate.subtract(Duration(days: firstLogDate.weekday - 1))
        : thisWeekStart;

    final weeks = List<DateTime>.generate(
      AppConstants.gardenWeeksCount,
      (i) => journeyStartMonday.add(Duration(days: 7 * i)),
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.systemGroupedBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusSheet)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.systemGray4,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Garden', style: AppTypography.title2),
                          const SizedBox(height: 2),
                          Text(
                            '52 weeks — one pot each. Practice keeps it growing; a missed day wilts it a little.',
                            style: AppTypography.subheadline,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: weeks.length,
                  itemBuilder: (context, index) {
                    final weekStart = weeks[index];
                    final isFuture = weekStart.isAfter(today);
                    final weekNumber = index + 1;

                    final level = isFuture
                        ? 0
                        : computeWeekPlantLevel(weekStart: weekStart, dailyLog: dailyLog, today: today);
                    final sprite = PlantSpriteState.fromLevel(level);

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondaryGroupedBackground,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                        boxShadow: [
                          BoxShadow(color: AppColors.shadowLight, blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: Opacity(
                                opacity: isFuture ? 0.3 : 1.0,
                                child: _PlantSprite(
                                  assetPath: sprite.assetPath,
                                  frameIndex: sprite.frameIndex,
                                  height: 85,
                                ),
                              ),
                            ),
                          ),
                          Text(
                            'W$weekNumber',
                            style: AppTypography.caption2.copyWith(color: AppColors.tertiaryLabel),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Crops a single frame out of a horizontal spritesheet.
///
/// The two sheets the user supplied (`saksı_canlı.png` — growing,
/// `saksı_solgun.png` — wilting) are 7 evenly-spaced frames in a
/// single row, but with slightly different native aspect ratios per
/// frame, so [_frameAspect] takes the sheet's *measured* pixel
/// dimensions rather than assuming both are identical — that's what
/// keeps each pot rendering undistorted instead of stretched.
class _PlantSprite extends StatelessWidget {
  final String assetPath;
  final int frameIndex; // 0-based
  final double height;

  const _PlantSprite({
    required this.assetPath,
    required this.frameIndex,
    required this.height,
  });

  // Measured directly from the source PNGs: (totalWidth / 7) / totalHeight.
  static const double _growingFrameAspect = (2116 / 7) / 743; // ≈ 0.4068
  static const double _wiltingFrameAspect = (2172 / 7) / 724; // ≈ 0.4285

  double get _frameAspect =>
      assetPath == AppConstants.plantGrowingAsset ? _growingFrameAspect : _wiltingFrameAspect;

  @override
  Widget build(BuildContext context) {
    final frameCount = AppConstants.plantSpriteFrameCount;
    final frameWidth = height * _frameAspect;
    final sheetWidth = frameWidth * frameCount;

    return SizedBox(
      width: frameWidth,
      height: height,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: sheetWidth,
          minWidth: sheetWidth,
          maxHeight: height,
          minHeight: height,
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(-frameWidth * frameIndex, 0),
            child: Image.asset(
              assetPath,
              width: sheetWidth,
              height: height,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }
}
