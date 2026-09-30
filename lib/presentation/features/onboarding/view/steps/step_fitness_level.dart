import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/onboarding_viewmodel.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../domain/entities/exercise_entity.dart';

class StepFitnessLevel extends ConsumerWidget {
  const StepFitnessLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingViewModelProvider).fitnessLevel;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    final levels = [
      _Level(
        value: Difficulty.beginner,
        emoji: '🌱',
        title: 'Beginner',
        description: 'New to movement.\nBuilding the foundation.',
        note: 'Gentle pace · Basic poses · No experience needed',
      ),
      _Level(
        value: Difficulty.intermediate,
        emoji: '🌿',
        title: 'Intermediate',
        description: 'Some experience.\nReady to go deeper.',
        note: 'Moderate pace · More variety · Builds on basics',
      ),
      _Level(
        value: Difficulty.advanced,
        emoji: '🌳',
        title: 'Advanced',
        description: 'Consistent practice.\nReady for complex flows.',
        note: 'Higher intensity · Complex movements · Full body',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Fitness Level', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Be honest — there is no wrong answer.',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Level cards
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: levels.asMap().entries.map((e) {
                final i = e.key;
                final level = e.value;
                final isSelected = selected == level.value;
                final isLast = i == levels.length - 1;
                return _LevelCell(
                  level: level,
                  isSelected: isSelected,
                  showDivider: !isLast,
                  onTap: () => vm.setFitnessLevel(level.value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _Level {
  final Difficulty value;
  final String emoji;
  final String title;
  final String description;
  final String note;

  const _Level({
    required this.value,
    required this.emoji,
    required this.title,
    required this.description,
    required this.note,
  });
}

class _LevelCell extends StatelessWidget {
  final _Level level;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onTap;

  const _LevelCell({
    required this.level,
    required this.isSelected,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryMuted
                  : AppColors.secondaryGroupedBackground,
              borderRadius: showDivider
                  ? null
                  : BorderRadius.only(
                      bottomLeft: Radius.circular(AppSpacing.radiusCard),
                      bottomRight: Radius.circular(AppSpacing.radiusCard),
                    ),
            ),
            child: Row(
              children: [
                Text(level.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.title,
                        style: AppTypography.headline.copyWith(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.label,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        level.description,
                        style: AppTypography.subheadline,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        level.note,
                        style: AppTypography.caption1.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.tertiaryLabel,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 22,
                          key: ValueKey('check'),
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          color: AppColors.systemGray4,
                          size: 22,
                          key: const ValueKey('uncheck'),
                        ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.separator,
            indent: 16,
          ),
      ],
    );
  }
}
