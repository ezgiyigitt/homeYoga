import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../viewmodel/home_viewmodel.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/navigation/route_names.dart';
import '../widgets/studio_hero_banner.dart';
import '../widgets/today_practice_card.dart';
import '../widgets/calm_shortcut_card.dart';
import '../widgets/ai_coach_shortcut_card.dart';
import '../widgets/monthly_progress_bar.dart';
import '../widgets/weekly_timeline_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Home page is strictly portrait-only
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  String _greeting(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.homeGreetingMorning;
    if (hour < 17) return l10n.homeGreetingAfternoon;
    return l10n.homeGreetingEvening;
  }

  // Off days are never assumed — the user has to actively say "today
  // is an off day" via this confirmation, which is the whole point of
  // the monthly bar's tap affordance.
  Future<void> _confirmMarkTodayOff(BuildContext context, HomeViewModel vm) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.homeMarkOffTitle),
        content: Text(l10n.homeMarkOffBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.homeMarkOffConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.markTodayOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final local = ref.watch(localStorageProvider);
    final firstName = local.firstName;

    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // ── Monthly Progress bar ─────────────────────────────
          // Sits above everything else, including the nav bar.
          SliverToBoxAdapter(
            child: MonthlyProgressBar(
              dailyLog: state.dailyLog,
              onMarkTodayOff: () => _confirmMarkTodayOff(context, vm),
            ),
          ),

          // Large title navigation bar
          SliverAppBar(
            pinned: true,
            floating: false,
            expandedHeight: 90,
            backgroundColor: AppColors.systemGroupedBackground,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
              title: Text(
                l10n.homeGreetingLine(
                  _greeting(context),
                  firstName.isEmpty ? l10n.homeGreetingFallbackName : firstName,
                ),
                style: AppTypography.headline,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Studio Community Flow (Hero Video Banner) ───
                _SectionLabel(l10n.homeSectionStudioFlow),
                const SizedBox(height: AppSpacing.xs),
                StudioHeroBanner(
                  onTap: () => context.push(RouteNames.workout),
                ),

                // ── Weekly Schedule & Practice ──────────────────
                _SectionLabel(
                  Localizations.localeOf(context).languageCode == 'tr'
                      ? 'HAFTALIK AKIŞ'
                      : l10n.homeSectionTodaysPractice,
                ),
                const SizedBox(height: AppSpacing.xs),
                if (state.weekDays.isNotEmpty) ...[
                  WeeklyTimelineStrip(
                    days: state.weekDays,
                    selectedDate: state.selectedDate ?? DateTime.now(),
                    onSelectDate: (date) => vm.selectDate(date),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                TodayPracticeCard(
                  workout: state.activeDisplayWorkout,
                  isLoading: state.isLoading,
                  isCompleted: state.isSelectedDateCompleted,
                  isViewingToday: state.isViewingToday,
                  viewedDate: state.selectedDay?.date ?? state.selectedDate,
                  onStart: () {
                    final w = state.activeDisplayWorkout;
                    context.push(RouteNames.workout, extra: w);
                  },
                ),

                // ── Calm / sound meditation shortcut ────────────
                // Always reachable, independent of the daily rotation —
                // see MeditationScreen.
                const SizedBox(height: AppSpacing.md),
                CalmShortcutCard(onTap: () => context.push(RouteNames.meditation)),

                // ── AI Coach shortcut ───────────────────────────
                const SizedBox(height: AppSpacing.md),
                AiCoachShortcutCard(onTap: () => context.go(RouteNames.coach)),

                const SizedBox(height: AppSpacing.xxxl),
              ]),
            ),
          ),
        ],
      ),
    );
  }

}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl, bottom: AppSpacing.xs),
      child: Text(
        text,
        style: AppTypography.caption1.copyWith(
          color: AppColors.secondaryLabel,
          letterSpacing: 0.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

