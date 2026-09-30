import '../../../core/utils/result.dart';
import '../../entities/workout_entity.dart';
import '../../repositories/i_exercise_repository.dart';

class GetWorkoutByIdUseCase {
  final IExerciseRepository _exerciseRepo;

  GetWorkoutByIdUseCase(this._exerciseRepo);

  Future<Result<WorkoutEntity>> execute(String workoutId) async {
    try {
      return await _exerciseRepo.getWorkoutById(workoutId);
    } catch (e) {
      return Failure(e.toString());
    }
  }
}
