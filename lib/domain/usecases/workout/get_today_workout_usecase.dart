import '../../../core/utils/result.dart';
import '../../entities/workout_entity.dart';
import '../../repositories/i_exercise_repository.dart';
import '../../repositories/i_profile_repository.dart';

class GetTodayWorkoutUseCase {
  final IExerciseRepository _exerciseRepo;
  final IProfileRepository _profileRepo;

  GetTodayWorkoutUseCase(this._exerciseRepo, this._profileRepo);

  Future<Result<WorkoutEntity>> execute(String userId) async {
    try {
      // 1. Get user profile to determine their level and preferences
      final profileRes = await _profileRepo.getProfile(userId);
      if (profileRes.isFailure) return Failure(profileRes.errorOrNull!);

      final profile = profileRes.dataOrNull!;

      // 2. Fetch or generate a workout based on profile
      return await _exerciseRepo.getTodayWorkout(
        difficulty: profile.fitnessLevel,
        durationMinutes: profile.preferredDurationMinutes,
        goals: profile.goals,
      );
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
