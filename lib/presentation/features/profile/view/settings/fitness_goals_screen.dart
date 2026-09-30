import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../domain/entities/exercise_entity.dart';
import '../../../../shared/widgets/hy_button.dart';
import '../../../home/viewmodel/home_viewmodel.dart';
import '../../viewmodel/profile_viewmodel.dart';
import 'widgets/settings_kit.dart';

/// Edit the goals, level and schedule that shape the daily practice.
///
/// The row in Settings promised "weekly goals and focus areas" but the screen
/// only offered a fitness level. Goals, weekly frequency and session length
/// were all collected during onboarding and used by the plan generator, with
/// no way to change them afterwards — they are all editable here now.
class FitnessGoalsScreen extends ConsumerStatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  ConsumerState<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends ConsumerState<FitnessGoalsScreen> {
  late Difficulty _level;
  late Set<String> _goals;
  late int _frequency;
  late int _duration;

  static const _durations = [10, 15, 20, 30, 45];

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileViewModelProvider).profile;
    _level = p?.fitnessLevel ?? Difficulty.beginner;
    _goals = {...?p?.goals};
    _frequency = p?.workoutFrequencyPerWeek ?? 3;
    _duration = p?.preferredDurationMinutes ?? 20;
  }

  Future<void> _save() async {
    final profile = ref.read(profileViewModelProvider).profile;
    if (profile == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    await ref.read(profileViewModelProvider.notifier).updateProfile(
          profile.copyWith(
            fitnessLevel: _level,
            goals: _goals.toList(),
            workoutFrequencyPerWeek: _frequency,
            preferredDurationMinutes: _duration,
          ),
        );

    // Ana ekrandaki bugünün dersini anlık olarak yeni seviyeye göre güncelle
    ref.read(homeViewModelProvider.notifier).refresh();

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Goals updated — your next practice will use them.')),
    );
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileViewModelProvider).isLoading;

    return SettingsScaffold(
      title: 'Yoga & Fitness Goals',
      children: [
        SettingsGroup(
          header: 'Your goals',
          footer: _goals.isEmpty
              ? 'Pick at least one so sessions can be tailored to you.'
              : '${_goals.length} selected — your daily practice leans towards these.',
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final goal in AppConstants.goals)
                    _Chip(
                      label: goal,
                      selected: _goals.contains(goal),
                      onTap: () => setState(() {
                        if (!_goals.remove(goal)) _goals.add(goal);
                      }),
                    ),
                ],
              ),
            ),
          ],
        ),
        SettingsGroup(
          header: 'Fitness level',
          children: [
            for (final level in Difficulty.values)
              SettingsRow(
                title: level.label,
                subtitle: _levelHint(level),
                onTap: () => setState(() => _level = level),
                trailing: Icon(
                  _level == level
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 22,
                  color: _level == level
                      ? AppColors.primary
                      : AppColors.systemGray3,
                ),
              ),
          ],
        ),
        SettingsGroup(
          header: 'Weekly rhythm',
          footer: '$_frequency ${_frequency == 1 ? 'day' : 'days'} on · '
              '${7 - _frequency} off',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Days per week', style: AppTypography.body),
                      const Spacer(),
                      Text(
                        '$_frequency',
                        style: AppTypography.body
                            .copyWith(color: AppColors.secondaryLabel),
                      ),
                    ],
                  ),
                  Slider(
                    value: _frequency.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.systemGray5,
                    label: '$_frequency',
                    onChanged: (v) => setState(() => _frequency = v.round()),
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsGroup(
          header: 'Session length',
          footer: 'The daily practice is built to fit this length.',
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final mins in _durations)
                    _Chip(
                      label: '$mins min',
                      selected: _duration == mins,
                      onTap: () => setState(() => _duration = mins),
                    ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: HYButton(
            label: 'Save Changes',
            onPressed: (isSaving || _goals.isEmpty) ? null : _save,
            isLoading: isSaving,
          ),
        ),
      ],
    );
  }

  static String _levelHint(Difficulty level) {
    switch (level) {
      case Difficulty.beginner:
        return 'Gentle pace · basic poses · no experience needed';
      case Difficulty.intermediate:
        return 'Moderate pace · more variety · builds on basics';
      case Difficulty.advanced:
        return 'Higher intensity · complex movements · full body';
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryContainer
              : AppColors.systemGroupedBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.separator,
            width: selected ? 1.4 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.subheadline.copyWith(
            color: selected ? AppColors.primaryDark : AppColors.label,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
