import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';

class LevelWorkoutsBottomSheet extends StatelessWidget {
  final int levelNumber;
  final String levelName;
  final List<String> workouts;
  final int completedWorkoutsCount;
  final bool isCompleted;

  const LevelWorkoutsBottomSheet({
    super.key,
    required this.levelNumber,
    required this.levelName,
    required this.workouts,
    required this.completedWorkoutsCount,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.systemBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              // Drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.systemGray4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Header
              Text(
                'LEVEL ${levelNumber.toString().padLeft(2, '0')}',
                style: AppTypography.caption1Medium.copyWith(
                  color: isCompleted ? AppColors.primary : AppColors.secondaryLabel,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(levelName, style: AppTypography.title2),
              
              if (isCompleted) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Level Completed',
                        style: AppTypography.caption1Medium.copyWith(color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: AppSpacing.xl),
              // List of workouts
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  itemCount: workouts.length,
                  separatorBuilder: (context, index) => Divider(color: AppColors.systemGray5, height: 32),
                  itemBuilder: (context, index) {
                    final isWorkoutCompleted = index < completedWorkoutsCount || isCompleted;
                    
                    return Row(
                      children: [
                        // Status Icon
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isWorkoutCompleted
                                ? AppColors.primary
                                : AppColors.systemGray6,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isWorkoutCompleted ? Icons.check_rounded : Icons.play_arrow_rounded,
                            color: isWorkoutCompleted ? Colors.white : AppColors.secondaryLabel,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workouts[index],
                                style: AppTypography.headline.copyWith(
                                  color: isWorkoutCompleted ? AppColors.label : AppColors.secondaryLabel,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Workout ${index + 1} • ~10 min',
                                style: AppTypography.caption1,
                              ),
                            ],
                          ),
                        ),
                        // Start Button
                        if (!isWorkoutCompleted && index == completedWorkoutsCount)
                          TextButton(
                            onPressed: () {
                              context.pop(); // close sheet
                              // Route to specific workout based on index
                              context.push('/workout/${Uri.encodeComponent(workouts[index])}');
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              foregroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text('Start'),
                          )
                        else if (isWorkoutCompleted)
                          TextButton(
                            onPressed: () {
                              context.pop();
                              context.push('/workout/${Uri.encodeComponent(workouts[index])}');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.secondaryLabel,
                            ),
                            child: const Text('Replay'),
                          ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}
