import '../../../core/utils/result.dart';
import '../../../core/constants/app_constants.dart';
import '../../repositories/i_progress_repository.dart';

/// Records a finished sound-meditation session through the same
/// completePractice write path as CompleteWorkoutUseCase — smaller XP,
/// and all of its skill points go to 'breath' rather than being split
/// across weighted axes (a meditation track isn't tagged per-exercise
/// like ExerciseEntity is).
class CompleteMeditationUseCase {
  final IProgressRepository _progressRepo;

  CompleteMeditationUseCase(this._progressRepo);

  Future<Result<void>> execute({
    required String userId,
    required int durationMinutes,
  }) async {
    try {
      final res = await _progressRepo.completePractice(
        userId,
        xpAmount: AppConstants.xpMeditationComplete,
        durationMinutes: durationMinutes,
        exerciseIds: const [],
        skillGains: {AppConstants.skillBreath: AppConstants.skillPointsPerMeditation},
      );
      if (res.isFailure) return Failure(res.errorOrNull!);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
