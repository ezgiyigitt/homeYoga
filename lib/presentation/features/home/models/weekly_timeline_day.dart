import '../../../../domain/entities/workout_entity.dart';

/// Represents a single day in the home screen's weekly timeline strip.
class WeeklyTimelineDay {
  final DateTime date;
  final bool isToday;
  final bool isCompleted;
  final WorkoutEntity? workout;

  const WeeklyTimelineDay({
    required this.date,
    required this.isToday,
    this.isCompleted = false,
    this.workout,
  });

  bool get isRestDay => workout == null || workout!.exercises.isEmpty;
  bool get isPast => !isToday && date.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
  bool get isFuture => !isToday && date.isAfter(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));
}
