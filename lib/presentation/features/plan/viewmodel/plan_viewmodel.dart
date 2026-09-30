import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/weekly_plan_entity.dart';
import '../../../../domain/usecases/generate_plan_usecase.dart';
import '../../../../domain/repositories/i_plan_repository.dart';
import '../../../shared/providers/app_providers.dart';

class WeekPhase {
  final int week;
  final String titleTr;
  final String titleEn;
  final String subtitleTr;
  final String subtitleEn;
  final IconData icon;

  const WeekPhase({
    required this.week,
    required this.titleTr,
    required this.titleEn,
    required this.subtitleTr,
    required this.subtitleEn,
    required this.icon,
  });

  String localizedTitle(String lang) => lang == 'tr' ? titleTr : titleEn;
  String localizedSubtitle(String lang) => lang == 'tr' ? subtitleTr : subtitleEn;
}

class PlanState {
  final WeeklyPlanEntity? plan;
  final int selectedWeek;
  final bool isLoading;
  final String? error;

  const PlanState({
    this.plan,
    this.selectedWeek = 1,
    this.isLoading = false,
    this.error,
  });

  PlanState copyWith({
    WeeklyPlanEntity? plan,
    int? selectedWeek,
    bool? isLoading,
    String? error,
  }) {
    return PlanState(
      plan: plan ?? this.plan,
      selectedWeek: selectedWeek ?? this.selectedWeek,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PlanViewModel extends StateNotifier<PlanState> {
  final IPlanRepository _planRepository;
  final GeneratePlanUseCase _generatePlanUseCase;
  final Ref _ref;

  static const phases = [
    WeekPhase(
      week: 1,
      titleTr: '1. Hafta: Temel & Omurga',
      titleEn: 'Week 1: Foundations & Spine',
      subtitleTr: 'Omurga hareketliliği, nefes farkındalığı ve temel akış.',
      subtitleEn: 'Spine mobility, breath awareness, and foundational flow.',
      icon: Icons.spa_rounded,
    ),
    WeekPhase(
      week: 2,
      titleTr: '2. Hafta: Derin Kalça & Bacak',
      titleEn: 'Week 2: Deep Hip & Leg Opening',
      subtitleTr: 'Kalça açıcılar ve arka bacak esnekliğiyle gerginliği boşaltma.',
      subtitleEn: 'Releasing deep tension with hip openers and hamstring stretches.',
      icon: Icons.accessibility_new_rounded,
    ),
    WeekPhase(
      week: 3,
      titleTr: '3. Hafta: Savaşçı & Güç Serisi',
      titleEn: 'Phase 3: Warrior & Core Power',
      subtitleTr: 'Savaşçı I, II ve III duruşlarıyla bacak ve merkez dayanıklılığı.',
      subtitleEn: 'Building stamina and core stability with Warrior I, II, and III series.',
      icon: Icons.fitness_center_rounded,
    ),
    WeekPhase(
      week: 4,
      titleTr: '4. Hafta: Zirve Akışı & Bütünleşme',
      titleEn: 'Phase 4: Peak Flow & Harmony',
      subtitleTr: 'Tüm duruşları kesintisiz nefesle birleştiren tam vücut akışı.',
      subtitleEn: 'A fluid whole-body practice linking movement and breath in complete harmony.',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  PlanViewModel(this._planRepository, this._generatePlanUseCase, this._ref) : super(const PlanState()) {
    _loadPlan();
  }

  Future<void> _loadPlan() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _planRepository.getWeeklyPlan();
    
    result.when(
      onSuccess: (plan) => state = state.copyWith(plan: plan, isLoading: false),
      onFailure: (err) => state = state.copyWith(error: err, isLoading: false),
    );
  }

  void selectWeek(int week) {
    state = state.copyWith(selectedWeek: week);
  }

  List<DailyPlanItem> getDaysForWeek(int week) {
    if (week == 1 && state.plan != null && state.plan!.days.isNotEmpty) {
      return state.plan!.days;
    }

    switch (week) {
      case 2:
        return [
          DailyPlanItem(
            day: 1,
            title: 'Hip Opener Flow',
            description: 'Hip Opener Basics, Cat-Cow Stretch',
            durationMinutes: 15,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 2,
            title: 'Deep Lunge Series',
            description: 'Deep Lunge Stretch, Cobra Pose',
            durationMinutes: 12,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 3,
            title: 'Rest & Recover',
            description: 'Gentle walk or mindful resting',
            durationMinutes: 0,
            isRestDay: true,
          ),
          DailyPlanItem(
            day: 4,
            title: 'Hamstring & Calf Mobility',
            description: 'Hamstring & Calf Stretch, Downward Facing Dog',
            durationMinutes: 15,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 5,
            title: 'Evening Forward Bend',
            description: 'Seated Forward Bend, Box Breathing',
            durationMinutes: 12,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 6,
            title: 'Rest & Recover',
            description: 'Recovery and muscle regeneration',
            durationMinutes: 0,
            isRestDay: true,
          ),
          DailyPlanItem(
            day: 7,
            title: 'Restorative Hip Reset',
            description: 'Hip Opener Basics, Supine Spinal Twist, Savasana',
            durationMinutes: 18,
            isRestDay: false,
          ),
        ];

      case 3:
        return [
          DailyPlanItem(
            day: 1,
            title: 'Warrior I Power Flow',
            description: 'Warrior I, Plank, Downward Facing Dog',
            durationMinutes: 16,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 2,
            title: 'Warrior II Focus',
            description: 'Warrior II, Standing Core Activation, Cobra Pose',
            durationMinutes: 15,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 3,
            title: 'Rest & Recover',
            description: 'Gentle stretching or mindful breath',
            durationMinutes: 0,
            isRestDay: true,
          ),
          DailyPlanItem(
            day: 4,
            title: 'Warrior III Balance Hold',
            description: 'Warrior III Hold, Single Leg Reach, Standing Balance Basics',
            durationMinutes: 16,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 5,
            title: 'Core & Warrior Combo',
            description: 'Warrior II, Squat & Core Combo, Side Plank Series',
            durationMinutes: 15,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 6,
            title: 'Rest & Recover',
            description: 'Recovery day for body and mind',
            durationMinutes: 0,
            isRestDay: true,
          ),
          DailyPlanItem(
            day: 7,
            title: 'Complete Warrior Celebration',
            description: 'Warrior I, Warrior II, Warrior III Hold, Savasana',
            durationMinutes: 20,
            isRestDay: false,
          ),
        ];

      case 4:
        return [
          DailyPlanItem(
            day: 1,
            title: 'Morning Awakening Flow',
            description: 'Cat-Cow Stretch, Downward Facing Dog, Cobra Pose',
            durationMinutes: 16,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 2,
            title: 'Root & Rise Balance',
            description: 'Tree Pose Progression, Standing Balance Basics',
            durationMinutes: 15,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 3,
            title: 'Rest & Recover',
            description: 'Rest and mindful reflection',
            durationMinutes: 0,
            isRestDay: true,
          ),
          DailyPlanItem(
            day: 4,
            title: 'Whole Body Synergy',
            description: 'Warrior II, Deep Lunge Stretch, Advanced Plank Challenge',
            durationMinutes: 18,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 5,
            title: 'Soulful Cooldown Flow',
            description: 'Seated Forward Bend, Supine Spinal Twist, 5-Minute Calm Reset',
            durationMinutes: 15,
            isRestDay: false,
          ),
          DailyPlanItem(
            day: 6,
            title: 'Rest & Recover',
            description: 'Recovery day before the graduation flow',
            durationMinutes: 0,
            isRestDay: true,
          ),
          DailyPlanItem(
            day: 7,
            title: 'Grand Mastery Flow & Savasana',
            description: 'Full body yoga journey followed by deep Savasana relaxation',
            durationMinutes: 25,
            isRestDay: false,
          ),
        ];

      default:
        return state.plan?.days ?? [];
    }
  }

  Future<void> generateNewPlan() async {
    state = state.copyWith(isLoading: true, error: null);
    
    final profileRepo = _ref.read(profileRepositoryProvider);
    final userId = _ref.read(localStorageProvider).userId;
    
    if (userId == null) {
      state = state.copyWith(error: 'User not logged in. Please log in again.', isLoading: false);
      return;
    }

    final profileRes = await profileRepo.getProfile(userId);
    if (!profileRes.isSuccess || profileRes.dataOrNull == null) {
      state = state.copyWith(error: 'Failed to load user profile.', isLoading: false);
      return;
    }

    final profile = profileRes.dataOrNull!;
    final result = await _generatePlanUseCase.execute(profile);
    
    result.when(
      onSuccess: (plan) => state = state.copyWith(plan: plan, isLoading: false),
      onFailure: (err) => state = state.copyWith(error: err, isLoading: false),
    );
  }

  Future<void> toggleDayCompletion(int dayIndex) async {
    final currentPlan = state.plan;
    if (currentPlan == null) return;

    final updatedDays = List<DailyPlanItem>.from(currentPlan.days);
    final dayItem = updatedDays.firstWhere((d) => d.day == dayIndex);
    
    final itemIndex = updatedDays.indexOf(dayItem);
    updatedDays[itemIndex] = dayItem.copyWith(isCompleted: !dayItem.isCompleted);

    final updatedPlan = currentPlan.copyWith(days: updatedDays);
    
    state = state.copyWith(plan: updatedPlan);

    final result = await _planRepository.saveWeeklyPlan(updatedPlan);
    result.when(
      onSuccess: (_) {},
      onFailure: (err) {
        state = state.copyWith(plan: currentPlan, error: 'Failed to update progress: $err');
      },
    );
  }
}

final planViewModelProvider = StateNotifierProvider<PlanViewModel, PlanState>((ref) {
  return PlanViewModel(
    ref.watch(planRepositoryProvider),
    ref.watch(generatePlanUseCaseProvider),
    ref,
  );
});
