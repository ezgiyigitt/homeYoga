import '../entities/exercise_entity.dart';
import '../entities/workout_entity.dart';
import '../../core/utils/result.dart';

abstract class IExerciseRepository {
  Future<Result<List<ExerciseEntity>>> getAllExercises();
  Future<Result<ExerciseEntity>> getExerciseById(String id);
  Future<Result<List<ExerciseEntity>>> getExercisesByDifficulty(Difficulty difficulty);
  
  /// Generates or fetches a customized workout based on the user's level and available time
  Future<Result<WorkoutEntity>> getTodayWorkout({
    required Difficulty difficulty,
    required int durationMinutes,
    required List<String> goals,
  });

  /// Fetches a specific workout by its ID
  Future<Result<WorkoutEntity>> getWorkoutById(String id);
}
