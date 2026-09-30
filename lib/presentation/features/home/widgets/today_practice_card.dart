import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/entities/workout_entity.dart';
import '../../../../core/constants/pain_rules.dart';
import '../../../../core/constants/practice_catalog.dart';
import '../../../shared/widgets/hy_card.dart';
import '../../../shared/widgets/hy_button.dart';

/// The home screen's main practice card.
/// Automatically adapts between Today's active practice, past completed sessions,
/// and future scheduled sessions (upcoming preview) selected from the weekly timeline strip.
class TodayPracticeCard extends StatelessWidget {
  final WorkoutEntity? workout;
  final bool isLoading;
  final bool isCompleted;
  final bool isViewingToday;
  final DateTime? viewedDate;
  final VoidCallback onStart;

  const TodayPracticeCard({
    super.key,
    required this.workout,
    required this.isLoading,
    this.isCompleted = false,
    this.isViewingToday = true,
    this.viewedDate,
    required this.onStart,
  });

  String _weekdayName(int weekday, String langCode) {
    if (langCode == 'tr') {
      const days = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
      return days[(weekday - 1) % 7];
    } else if (langCode == 'es') {
      const days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
      return days[(weekday - 1) % 7];
    } else if (langCode == 'fr') {
      const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
      return days[(weekday - 1) % 7];
    }
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[(weekday - 1) % 7];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isLoading) {
      return const HYCard(
        child: SizedBox(
          height: 96,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    final activeLocale = Localizations.localeOf(context).languageCode;
    final isTr = activeLocale == 'tr';

    // Check for rest day or empty workout
    if (workout == null || workout!.exercises.isEmpty) {
      return HYCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 28,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isViewingToday
                            ? (isTr ? 'DİNLENME GÜNÜ' : 'REST & RECOVERY')
                            : (viewedDate != null
                                ? '${_weekdayName(viewedDate!.weekday, activeLocale).toUpperCase()} • ${isTr ? "DİNLENME" : "REST"}'
                                : (isTr ? 'DİNLENME GÜNÜ' : 'REST & RECOVERY')),
                        style: AppTypography.caption1Medium.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTr ? 'Bedenini Dinlendir' : 'Rest Your Body',
                        style: AppTypography.headline,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isTr ? 'Yenilenme ve nefes günü' : 'Recovery and breath day',
                        style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              isTr
                  ? 'Bugün kaslarının toparlanmasına izin ver. İstersen zihnini sakinleştirmek için Meditasyon & Nefes bölümüne göz atabilirsin.'
                  : 'Take today to recover and replenish. You can explore gentle breathing and sound meditations to calm your mind.',
              style: AppTypography.subheadline.copyWith(color: AppColors.secondaryLabel),
            ),
          ],
        ),
      );
    }

    final w = workout!;
    final sessionId = w.id.startsWith('session:')
        ? w.id.substring('session:'.length)
        : w.id;
    final catalogSession = PracticeCatalog.byId(sessionId);

    final displayTitle = w.id.startsWith('relief:')
        ? (PainRules.forRegion(
                BodyRegion.values.firstWhere(
                  (r) => 'relief:${r.name}' == w.id,
                  orElse: () => BodyRegion.neckShoulder,
                ),
              )?.localizedTitle(activeLocale) ??
              w.name)
        : (isTr && catalogSession?.nameTr != null
            ? catalogSession!.nameTr
            : w.name);

    final displayDescription = w.id.startsWith('relief:')
        ? (PainRules.forRegion(
                BodyRegion.values.firstWhere(
                  (r) => 'relief:${r.name}' == w.id,
                  orElse: () => BodyRegion.neckShoulder,
                ),
              )?.localizedAdvice(activeLocale) ??
              w.description)
        : (isTr && catalogSession?.descriptionTr != null
            ? catalogSession!.descriptionTr
            : w.description);

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final isFuture = viewedDate != null &&
        DateTime(viewedDate!.year, viewedDate!.month, viewedDate!.day).isAfter(todayMidnight);
    final isTomorrow = viewedDate != null &&
        DateTime(viewedDate!.year, viewedDate!.month, viewedDate!.day) ==
            todayMidnight.add(const Duration(days: 1));

    // Header label text & badge
    String headerLabel;
    if (isViewingToday) {
      headerLabel = l10n.todayPracticeLabel;
    } else if (viewedDate != null) {
      final dayName = _weekdayName(viewedDate!.weekday, activeLocale);
      if (isTomorrow) {
        headerLabel = isTr ? 'YARINKİ SEANS' : "TOMORROW'S SESSION";
      } else if (isFuture) {
        headerLabel = '$dayName • ${isTr ? "SEANS" : "SESSION"}'.toUpperCase();
      } else {
        headerLabel = '$dayName • ${isTr ? "GEÇMİŞ SEANS" : "PAST SESSION"}'.toUpperCase();
      }
    } else {
      headerLabel = isTr ? 'PLANLANAN SEANS' : 'SCHEDULED PRACTICE';
    }

    return HYCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.systemGreen.withValues(alpha: 0.18)
                      : AppColors.primaryContainer,
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : (isViewingToday ? Icons.self_improvement_rounded : Icons.schedule_rounded),
                    size: isCompleted ? 32 : 28,
                    color: isCompleted ? AppColors.systemGreen : AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            headerLabel,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption1Medium.copyWith(
                              color: isCompleted ? AppColors.systemGreen : AppColors.primary,
                              letterSpacing: 0.8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isCompleted) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.systemGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded, size: 12, color: AppColors.systemGreen),
                                const SizedBox(width: 3),
                                Text(
                                  l10n.todayPracticeCompletedBadge,
                                  style: const TextStyle(
                                    color: AppColors.systemGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else if (!isViewingToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isTr ? 'Önizleme' : 'Preview',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(displayTitle, style: AppTypography.headline),
                    const SizedBox(height: 2),
                    Text(
                      l10n.todayPracticeMeta(w.estimatedMinutes, w.exerciseCount),
                      style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (displayDescription != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              displayDescription,
              style: AppTypography.subheadline.copyWith(color: AppColors.secondaryLabel),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.check_circle_rounded, color: AppColors.systemGreen, size: 18),
                label: Text(
                  l10n.todayPracticeRepeat,
                  style: const TextStyle(
                    color: AppColors.systemGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.systemGreen, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusCard)),
                  backgroundColor: AppColors.systemGreen.withValues(alpha: 0.06),
                ),
              ),
            )
          else if (isFuture)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.secondaryGroupedBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                border: Border.all(
                  color: AppColors.separator.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_clock_rounded,
                    size: 18,
                    color: AppColors.secondaryLabel,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isTomorrow
                          ? (isTr ? 'Yarın açılacak • Sadece Önizleme' : 'Unlocks tomorrow • Preview only')
                          : (isTr
                              ? '${_weekdayName(viewedDate!.weekday, activeLocale)} günü açılacak • Önizleme'
                              : 'Unlocks on ${_weekdayName(viewedDate!.weekday, activeLocale)} • Preview'),
                      style: AppTypography.subheadline.copyWith(
                        color: AppColors.secondaryLabel,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          else
            HYButton(
              label: isViewingToday
                  ? l10n.commonStart
                  : (isTr ? 'Bu Seansı Başlat' : 'Start This Session'),
              onPressed: onStart,
            ),
        ],
      ),
    );
  }
}
