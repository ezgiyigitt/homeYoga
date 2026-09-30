import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/hy_button.dart';
import '../../../../domain/entities/weekly_plan_entity.dart';
import '../viewmodel/plan_viewmodel.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  void _startWorkoutForDay(BuildContext context, DailyPlanItem item, bool isTr) {
    if (item.isRestDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.spa_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTr
                      ? 'Bugün dinlenme günü. Kaslarının toparlanmasına izin ver.'
                      : 'Today is a rest day. Take time to relax and recover.',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final workoutKey = '${item.title}|${item.description}|${item.day}';
    context.push('/workout/${Uri.encodeComponent(workoutKey)}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(planViewModelProvider);
    final vm = ref.read(planViewModelProvider.notifier);
    final activeLocale = Localizations.localeOf(context).languageCode;
    final isTr = activeLocale == 'tr';

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: false,
            pinned: true,
            expandedHeight: 90,
            backgroundColor: AppColors.systemGroupedBackground,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                isTr ? 'Programım & Yolculuk' : 'My Plan & Journey',
                style: AppTypography.headline,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Top Journey Overview Card ───────────────────
                _buildJourneyBanner(context, state, isTr),
                const SizedBox(height: AppSpacing.lg),

                // ── 4-Week Stepper Tabs ─────────────────────────
                _buildWeekTabs(state, vm, isTr),
                const SizedBox(height: AppSpacing.md),

                // ── Selected Phase Description Card ────────────
                _buildPhaseInfoCard(state.selectedWeek, isTr),
                const SizedBox(height: AppSpacing.lg),

                // ── Days List ───────────────────────────────────
                if (state.isLoading)
                  _buildLoadingState(isTr)
                else if (state.error != null)
                  _buildErrorState(state.error!, vm, isTr)
                else
                  _buildDaysList(context, state, vm, isTr),

                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyBanner(BuildContext context, PlanState state, bool isTr) {
    final week1Completed = state.plan?.days.where((d) => d.isCompleted).length ?? 0;
    final totalWeek1 = state.plan?.days.length ?? 7;
    final progress = totalWeek1 > 0 ? (week1Completed / (totalWeek1 * 4)).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.systemGray5, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTr ? '4 HAFTALIK DÖNÜŞÜM' : '4-WEEK TRANSFORMATION',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isTr ? '1. Hafta Aktif' : 'Week 1 Active',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isTr ? 'Esneklik, Omurga & Güç Yolculuğu' : 'Mobility, Spine & Balance Journey',
            style: AppTypography.headline,
          ),
          const SizedBox(height: 4),
          Text(
            isTr
                ? '4 aşamalı kişisel yoga akışınla adım adım ilerle.'
                : 'Progress through 4 structured milestones built for your pace.',
            style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress > 0 ? progress : 0.05,
              backgroundColor: AppColors.systemGray5,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekTabs(PlanState state, PlanViewModel vm, bool isTr) {
    return Row(
      children: List.generate(4, (index) {
        final week = index + 1;
        final isSelected = state.selectedWeek == week;
        final isActiveWeek = week == 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 4,
              right: index == 3 ? 0 : 4,
            ),
            child: InkWell(
              onTap: () => vm.selectWeek(week),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer.withValues(alpha: 0.8)
                      : AppColors.secondaryGroupedBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isActiveWeek
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.systemGray5),
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isTr ? '$week. Hafta' : 'Week $week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? AppColors.primaryDark : AppColors.label,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActiveWeek
                          ? (isTr ? 'Aktif' : 'Active')
                          : (isTr ? 'Beklenen' : 'Upcoming'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isActiveWeek ? AppColors.primary : AppColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPhaseInfoCard(int week, bool isTr) {
    final phase = PlanViewModel.phases.firstWhere(
      (p) => p.week == week,
      orElse: () => PlanViewModel.phases.first,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(phase.icon, size: 22, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase.localizedTitle(isTr ? 'tr' : 'en'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  phase.localizedSubtitle(isTr ? 'tr' : 'en'),
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaysList(
    BuildContext context,
    PlanState state,
    PlanViewModel vm,
    bool isTr,
  ) {
    final days = vm.getDaysForWeek(state.selectedWeek);
    final isWeek1 = state.selectedWeek == 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final day in days) ...[
          _DayCard(
            item: day,
            isInteractive: isWeek1,
            isTr: isTr,
            onToggle: () {
              if (isWeek1) vm.toggleDayCompletion(day.day);
            },
            onStart: () => _startWorkoutForDay(context, day, isTr),
          ),
          const SizedBox(height: AppSpacing.sm + 4),
        ],
      ],
    );
  }

  Widget _buildLoadingState(bool isTr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(strokeWidth: 2),
          const SizedBox(height: AppSpacing.md),
          Text(
            isTr ? 'Programın hazırlanıyor...' : 'Preparing your plan...',
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, dynamic vm, bool isTr) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.systemRed),
          const SizedBox(height: AppSpacing.md),
          Text(error, style: AppTypography.body.copyWith(color: AppColors.systemRed), textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          HYButton(
            label: isTr ? 'Tekrar Dene' : 'Try Again',
            onPressed: () => vm.generateNewPlan(),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final DailyPlanItem item;
  final bool isInteractive;
  final bool isTr;
  final VoidCallback onToggle;
  final VoidCallback onStart;

  const _DayCard({
    required this.item,
    required this.isInteractive,
    required this.isTr,
    required this.onToggle,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = item.isRestDay;
    final isDone = item.isCompleted;

    return Material(
      color: isDone
          ? AppColors.primaryContainer.withValues(alpha: 0.35)
          : AppColors.secondaryGroupedBackground,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onStart,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(
              color: isDone
                  ? AppColors.systemGreen.withValues(alpha: 0.35)
                  : AppColors.systemGray5,
              width: 0.8,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Day Indicator Circle
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isRest
                      ? AppColors.systemGray6
                      : (isDone
                          ? AppColors.systemGreen.withValues(alpha: 0.15)
                          : AppColors.primaryContainer.withValues(alpha: 0.6)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.systemGreen,
                          size: 22,
                        )
                      : (isRest
                          ? Icon(
                              Icons.spa_rounded,
                              size: 18,
                              color: AppColors.secondaryLabel,
                            )
                          : Text(
                              '${item.day}',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            )),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isRest ? (isTr ? 'Dinlenme & Toparlanma' : 'Rest & Recover') : item.title,
                            style: AppTypography.headline.copyWith(fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRest)
                          Text(
                            '${item.durationMinutes} ${isTr ? "dk" : "min"}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Text(
                            isTr ? 'Dinlenme' : 'Rest',
                            style: TextStyle(
                              color: AppColors.secondaryLabel,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action button / Checkbox
              const SizedBox(width: AppSpacing.sm),
              if (isInteractive)
                Checkbox(
                  value: isDone,
                  onChanged: (val) => onToggle(),
                  activeColor: AppColors.systemGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                )
              else
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.tertiaryLabel,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
