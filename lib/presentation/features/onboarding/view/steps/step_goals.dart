import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/onboarding_viewmodel.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

class StepGoals extends ConsumerWidget {
  const StepGoals({super.key});

  static const Map<String, String> _goalEmojis = {
    'Flexibility': '🤸',
    'Strength': '💪',
    'Mobility': '🦵',
    'Stress Relief': '🧘',
    'Weight Management': '⚖️',
    'Better Posture': '🏛',
    'Build Exercise Habit': '📅',
    'Core Strength': '🎯',
    'Better Sleep': '😴',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingViewModelProvider).goals;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Your Goals', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Select all that apply. You can always update these later.',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: AppConstants.goals.map((goal) {
              final isSelected = selected.contains(goal);
              return _GoalChip(
                label: goal,
                emoji: _goalEmojis[goal] ?? '✨',
                isSelected: isSelected,
                onTap: () => vm.toggleGoal(goal),
              );
            }).toList(),
          ),
          if (selected.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              ),
              child: Text(
                '${selected.length} goal${selected.length > 1 ? 's' : ''} selected — your plan will be tailored to these.',
                style: AppTypography.footnote.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.secondaryGroupedBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withAlpha(40)
                  : AppColors.shadowLight,
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.subheadlineSemibold.copyWith(
                color: isSelected ? Colors.white : AppColors.label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
