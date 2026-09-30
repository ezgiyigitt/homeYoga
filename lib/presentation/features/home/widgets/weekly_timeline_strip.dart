import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/weekly_timeline_day.dart';

/// A sleek, breathable 7-day horizontal timeline strip for the Home screen.
/// Lets the user see their weekly rhythm at a glance without cluttering the screen.
class WeeklyTimelineStrip extends StatelessWidget {
  final List<WeeklyTimelineDay> days;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelectDate;

  const WeeklyTimelineStrip({
    super.key,
    required this.days,
    required this.selectedDate,
    required this.onSelectDate,
  });

  String _weekdayShort(int weekday, String langCode) {
    if (langCode == 'tr') {
      const trDays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
      return trDays[(weekday - 1) % 7];
    } else if (langCode == 'es') {
      const esDays = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      return esDays[(weekday - 1) % 7];
    } else if (langCode == 'fr') {
      const frDays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      return frDays[(weekday - 1) % 7];
    } else if (langCode == 'zh') {
      const zhDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
      return zhDays[(weekday - 1) % 7];
    }
    const enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return enDays[(weekday - 1) % 7];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();

    final langCode = Localizations.localeOf(context).languageCode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isSelected = _isSameDay(day.date, selectedDate);
        final isToday = day.isToday;
        final isDone = day.isCompleted;

        Color bgColor;
        Border border;

        if (isSelected) {
          bgColor = AppColors.primaryContainer.withValues(alpha: 0.8);
          border = Border.all(color: AppColors.primary, width: 1.5);
        } else if (isToday) {
          bgColor = AppColors.primaryContainer.withValues(alpha: 0.3);
          border = Border.all(
            color: AppColors.primary.withValues(alpha: 0.35),
            width: 1.2,
          );
        } else {
          bgColor = AppColors.secondaryGroupedBackground;
          border = Border.all(color: AppColors.systemGray5, width: 0.8);
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onSelectDate(day.date),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _weekdayShort(day.date.weekday, langCode),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primaryDark
                              : (isToday
                                  ? AppColors.primary
                                  : AppColors.secondaryLabel),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${day.date.day}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.label,
                        ),
                      ),
                      const SizedBox(height: 3),
                      SizedBox(
                        height: 12,
                        child: Center(
                          child: isDone
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  size: 11,
                                  color: AppColors.systemGreen,
                                )
                              : (isToday
                                  ? Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : (day.isRestDay
                                      ? Container(
                                          width: 3,
                                          height: 3,
                                          decoration: BoxDecoration(
                                            color: AppColors.tertiaryLabel,
                                            shape: BoxShape.circle,
                                          ),
                                        )
                                      : const SizedBox.shrink())),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
