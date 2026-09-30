import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/hy_card.dart';

class LevelJourneyCard extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final bool isLocked;
  final bool isCompleted;
  final double progressPercentage;
  final VoidCallback onTap;

  const LevelJourneyCard({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.isLocked,
    required this.isCompleted,
    required this.progressPercentage,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isLocked ? AppColors.systemGray6 : AppColors.systemBackground;
    final titleColor = isLocked ? AppColors.secondaryLabel : AppColors.label;
    
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: HYCard(
        color: bgColor,
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // Level Icon / Indicator
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primary
                    : isLocked
                        ? AppColors.systemGray4
                        : AppColors.primary.withValues(alpha: 0.1),
                border: isCompleted || isLocked
                    ? null
                    : Border.all(color: AppColors.primary, width: 2),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
                    : isLocked
                        ? Icon(Icons.lock_rounded, color: AppColors.secondaryLabel, size: 24)
                        : Text(
                            '$levelNumber',
                            style: AppTypography.title2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            
            // Level Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LEVEL ${levelNumber.toString().padLeft(2, '0')}',
                    style: AppTypography.caption1Medium.copyWith(
                      color: isLocked ? AppColors.tertiaryLabel : AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    levelName,
                    style: AppTypography.headline.copyWith(color: titleColor),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Progress Bar
                  if (!isLocked && !isCompleted) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressPercentage,
                        minHeight: 6,
                        backgroundColor: AppColors.systemGray5,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ] else if (isCompleted) ...[
                    Text(
                      'Completed',
                      style: AppTypography.caption1.copyWith(color: AppColors.primary),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
