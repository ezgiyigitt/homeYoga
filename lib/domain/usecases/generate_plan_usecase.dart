import 'dart:math';
import '../../core/utils/result.dart';
import '../entities/exercise_entity.dart';
import '../entities/user_profile_entity.dart';
import '../entities/weekly_plan_entity.dart';
import '../repositories/i_exercise_repository.dart';
import '../repositories/i_plan_repository.dart';

/// Builds the user's 7-day plan from the exercise catalog, matched to the
/// fitness level they chose during onboarding and their preferred weekly
/// workout frequency.
///
/// This used to call the Gemini API to "generate" the plan with AI. That
/// was removed on purpose: it made the weekly plan dependent on an external
/// service (with its own outages, quotas, and API key issues), for
/// something that doesn't need to be AI-generated at all — the app already
/// has a leveled exercise catalog, so the plan is now just a deterministic
/// pick from it. The AI Coach chat is the one remaining place in the app
/// that talks to Gemini.
class GeneratePlanUseCase {
  final IExerciseRepository _exerciseRepository;
  final IPlanRepository _planRepository;

  GeneratePlanUseCase(this._exerciseRepository, this._planRepository);

  Future<Result<WeeklyPlanEntity>> execute(UserProfileEntity profile) async {
    try {
      // 1. Pull exercises matching the user's declared level.
      final byLevelRes = await _exerciseRepository.getExercisesByDifficulty(profile.fitnessLevel);
      List<ExerciseEntity> pool = byLevelRes.isSuccess ? (byLevelRes.dataOrNull ?? const []) : const [];

      // Fall back to the full catalog if nothing matches that level yet.
      if (pool.isEmpty) {
        final allRes = await _exerciseRepository.getAllExercises();
        pool = allRes.isSuccess ? (allRes.dataOrNull ?? const []) : const [];
      }

      if (pool.isEmpty) {
        return const Failure('No exercises are available yet to build a plan.');
      }

      // 2. Decide which of the 7 days are workout days vs. rest days,
      // spread evenly across the week instead of bunched at the start
      // (e.g. 3x/week lands roughly on day 2, 4, 6 rather than 1, 2, 3).
      final frequency = profile.workoutFrequencyPerWeek.clamp(1, 7);
      final days = <DailyPlanItem>[];
      double acc = 0;
      int poolIndex = 0;

      for (int day = 1; day <= 7; day++) {
        acc += frequency / 7;
        final isWorkoutDay = acc >= 1;
        if (isWorkoutDay) acc -= 1;

        if (isWorkoutDay) {
          // Pick a few exercises for this day, cycling through the pool so
          // consecutive workout days don't repeat the exact same session.
          final pickCount = min(3, pool.length);
          final picks = <ExerciseEntity>[
            for (int i = 0; i < pickCount; i++) pool[(poolIndex + i) % pool.length],
          ];
          poolIndex += pickCount;

          final category = picks.first.category;
          days.add(DailyPlanItem(
            day: day,
            title: '$category Flow',
            description: picks.map((e) => e.name).join(', '),
            durationMinutes: profile.preferredDurationMinutes,
            isRestDay: false,
          ));
        } else {
          days.add(DailyPlanItem(
            day: day,
            title: 'Rest & Recover',
            description: 'Take today to rest, stretch lightly, or go for a gentle walk.',
            durationMinutes: 0,
            isRestDay: true,
          ));
        }
      }

      final plan = WeeklyPlanEntity(
        id: 'plan_${DateTime.now().millisecondsSinceEpoch}',
        userId: profile.id,
        days: days,
        createdAt: DateTime.now(),
      );

      final saveRes = await _planRepository.saveWeeklyPlan(plan);
      if (saveRes.isFailure) {
        return Failure(saveRes.errorOrNull!);
      }

      return Success(plan);
    } catch (e) {
      return Failure('Failed to generate plan: $e');
    }
  }
}
