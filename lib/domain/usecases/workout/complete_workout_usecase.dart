import '../../../core/utils/result.dart';
import '../../../core/constants/app_constants.dart';
import '../../entities/exercise_entity.dart';
import '../../repositories/i_progress_repository.dart';

class CompleteWorkoutUseCase {
  final IProgressRepository _progressRepo;

  CompleteWorkoutUseCase(this._progressRepo);

  Future<Result<void>> execute({
    required String userId,
    required int durationMinutes,
    List<ExerciseEntity> completedExercises = const [],
  }) async {
    try {
      final skillGains = _computeSkillGains(completedExercises);

      final res = await _progressRepo.completePractice(
        userId,
        xpAmount: AppConstants.xpWorkoutComplete,
        durationMinutes: durationMinutes,
        exerciseIds: completedExercises.map((e) => e.id).toList(),
        skillGains: skillGains,
      );

      if (res.isFailure) return Failure(res.errorOrNull!);
      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  /// Turns each completed exercise's skill weights into whole skill
  /// points, split across AppConstants.skillPointsPerPractice so a
  /// practice made of 5 flexibility-heavy clips gives more Flexibility
  /// than one made of 5 mixed clips — without any axis ever capping out.
  Map<String, int> _computeSkillGains(List<ExerciseEntity> exercises) {
    if (exercises.isEmpty) return const {};

    final totals = <String, double>{};
    for (final ex in exercises) {
      ex.effectiveSkillWeights.forEach((axis, weight) {
        totals[axis] = (totals[axis] ?? 0) + weight;
      });
    }

    final pointsPerExercise = AppConstants.skillPointsPerPractice / exercises.length;
    return totals.map((axis, weightSum) => MapEntry(axis, (weightSum * pointsPerExercise).round()));
  }
}
