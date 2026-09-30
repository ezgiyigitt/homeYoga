import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/onboarding_viewmodel.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

class StepFrequency extends ConsumerWidget {
  const StepFrequency({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingViewModelProvider).frequency;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Training &\nOff Days', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'How many days a week will you practice — and how many will be off days?',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),
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
              children: AppConstants.workoutFrequencies.asMap().entries.map((e) {
                final i = e.key;
                final days = e.value;
                final offDays = 7 - days;
                final isSelected = selected == days;
                final isLast = i == AppConstants.workoutFrequencies.length - 1;
                return _SelectionCell(
                  title: '$days days on · $offDays days off',
                  subtitle: _subtitle(days),
                  isSelected: isSelected,
                  showDivider: !isLast,
                  onTap: () => vm.setFrequency(days),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // The whole point of asking this up front: off days still
          // need an explicit check-in — the app never assumes one for
          // you, so the user knows what to expect from day one.
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primaryDark, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Even on an off day, open the app and mark it as off — no day is ever skipped silently.',
                    style: AppTypography.footnote.copyWith(color: AppColors.primaryDark),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _subtitle(int days) {
    if (days <= 2) return 'Light — great for getting started';
    if (days <= 3) return 'Balanced — recommended for beginners';
    if (days <= 4) return 'Active — builds real momentum';
    if (days <= 5) return 'Dedicated — strong commitment';
    return 'Intensive — for experienced practitioners';
  }
}

class StepDuration extends ConsumerWidget {
  const StepDuration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingViewModelProvider).duration;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Workout\nDuration', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'How much time can you set aside per session?',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),
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
              children: AppConstants.workoutDurations.asMap().entries.map((e) {
                final i = e.key;
                final mins = e.value;
                final isSelected = selected == mins;
                final isLast = i == AppConstants.workoutDurations.length - 1;
                final label = mins >= 45 ? '45+ min' : '$mins min';
                return _SelectionCell(
                  title: label,
                  subtitle: _subtitle(mins),
                  isSelected: isSelected,
                  showDivider: !isLast,
                  onTap: () => vm.setDuration(mins),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  String _subtitle(int mins) {
    if (mins <= 5) return 'Micro-session — better than nothing';
    if (mins <= 10) return 'Quick — fits into any schedule';
    if (mins <= 15) return 'Short — effective and focused';
    if (mins <= 20) return 'Standard — comfortable commitment';
    if (mins <= 30) return 'Full — comprehensive session';
    return 'Extended — deep practice';
  }
}

/// Reusable single-selection list cell used in frequency and duration steps.
class _SelectionCell extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onTap;

  const _SelectionCell({
    required this.title,
    required this.subtitle,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            color: isSelected ? AppColors.primaryMuted : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.calloutMedium.copyWith(
                          color: isSelected
                              ? AppColors.primaryDark
                              : AppColors.label,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.caption1),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 20,
                          key: ValueKey('c'),
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          color: AppColors.systemGray4,
                          size: 20,
                          key: const ValueKey('u'),
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
