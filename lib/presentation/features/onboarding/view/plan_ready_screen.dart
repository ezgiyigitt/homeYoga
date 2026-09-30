import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/hy_button.dart';
import '../../../shared/widgets/hy_logo.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../../core/constants/app_constants.dart';
import '../viewmodel/onboarding_viewmodel.dart';

/// Summary screen shown after onboarding completes.
class PlanReadyScreen extends ConsumerWidget {
  const PlanReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstName = ref.watch(localStorageProvider).firstName;
    final onboarding = ref.watch(onboardingViewModelProvider);

    final level = onboarding.fitnessLevel;
    final levelIndex = level?.index ?? 0;
    final levelName = AppConstants.levelNames[levelIndex];
    final frequency = onboarding.frequency ?? 3;
    final duration = onboarding.duration ?? 15;
    final goals = onboarding.goals;

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Logo
              const HYLogo(),
              const SizedBox(height: AppSpacing.xxxl),

              // Ready badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '✦  Your plan is ready',
                  style: AppTypography.footnoteSemibold.copyWith(
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                firstName.isEmpty
                    ? 'Welcome!'
                    : 'Welcome, $firstName!',
                style: AppTypography.largeTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Your personalised plan has been created\nbased on your preferences.',
                style: AppTypography.subheadline,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Plan summary card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondaryGroupedBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _PlanRow(
                      icon: Icons.grade_outlined,
                      label: 'Level',
                      value:
                          'LEVEL ${(levelIndex + 1).toString().padLeft(2, '0')} — $levelName',
                      showDivider: true,
                    ),
                    _PlanRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Frequency',
                      value: '$frequency workouts / week',
                      showDivider: true,
                    ),
                    _PlanRow(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: '$duration min / session',
                      showDivider: true,
                    ),
                    _PlanRow(
                      icon: Icons.track_changes_outlined,
                      label: 'Goals',
                      value: goals.isEmpty
                          ? 'General Wellness'
                          : goals.take(2).join(' · ') +
                              (goals.length > 2
                                  ? ' +${goals.length - 2}'
                                  : ''),
                      showDivider: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              HYButton(
                label: 'View My Plan',
                onPressed: () => context.go(RouteNames.home),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  const _PlanRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.subheadline,
                ),
              ),
              Text(
                value,
                style: AppTypography.calloutMedium,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.separator,
            indent: 52,
          ),
      ],
    );
  }
}
