import 'exercise_entity.dart';

/// A workout exercise slot — exercise within a workout with overrides.
class WorkoutExerciseEntity {
  final String id;
  final String exerciseId;
  final int orderIndex;
  final int? durationOverride;
  final int? repsOverride;
  final int? restSecondsOverride;
  final ExerciseEntity? exercise;

  const WorkoutExerciseEntity({
    required this.id,
    required this.exerciseId,
    required this.orderIndex,
    this.durationOverride,
    this.repsOverride,
    this.restSecondsOverride,
    this.exercise,
  });

  int effectiveDuration(ExerciseEntity ex) =>
      durationOverride ?? ex.durationSeconds;

  int effectiveRest(ExerciseEntity ex) =>
      restSecondsOverride ?? ex.restSeconds;
}

/// A workout — named collection of exercises with metadata.
class WorkoutEntity {
  final String id;
  final String? programId;
  final String name;
  final String? description;
  final int estimatedMinutes;
  final Difficulty difficulty;
  final String category;
  final List<WorkoutExerciseEntity> exercises;

  const WorkoutEntity({
    required this.id,
    this.programId,
    required this.name,
    this.description,
    required this.estimatedMinutes,
    required this.difficulty,
    required this.category,
    this.exercises = const [],
  });

  int get exerciseCount => exercises.length;

  @override
  bool operator ==(Object other) =>
      other is WorkoutEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
