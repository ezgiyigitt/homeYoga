import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/workout_entity.dart';
import '../../../../domain/entities/exercise_entity.dart';
import '../../../shared/providers/app_providers.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../../progress/viewmodel/achievements_viewmodel.dart';
import '../../plan/viewmodel/plan_viewmodel.dart';

enum WorkoutStatus { notStarted, playing, paused, resting, finished }

class WorkoutState {
  final WorkoutEntity? workout;
  final WorkoutStatus status;
  final int currentExerciseIndex;
  final int remainingSeconds; // Can be exercise duration or rest duration
  final bool isLoading;

  const WorkoutState({
    this.workout,
    this.status = WorkoutStatus.notStarted,
    this.currentExerciseIndex = 0,
    this.remainingSeconds = 0,
    this.isLoading = true,
  });

  WorkoutState copyWith({
    WorkoutEntity? workout,
    WorkoutStatus? status,
    int? currentExerciseIndex,
    int? remainingSeconds,
    bool? isLoading,
  }) {
    return WorkoutState(
      workout: workout ?? this.workout,
      status: status ?? this.status,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  WorkoutExerciseEntity? get currentExercise {
    if (workout == null || currentExerciseIndex >= workout!.exercises.length) {
      return null;
    }
    return workout!.exercises[currentExerciseIndex];
  }

  double get progress {
    if (workout == null || workout!.exercises.isEmpty) return 0;
    return currentExerciseIndex / workout!.exercises.length;
  }
}

class WorkoutViewModel extends StateNotifier<WorkoutState> {
  final Ref _ref;
  Timer? _timer;

  WorkoutViewModel(this._ref) : super(const WorkoutState());

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void setCustomWorkout(WorkoutEntity workout) {
    final exercises = workout.exercises;
    final initialDuration = exercises.isNotEmpty && exercises.first.exercise != null
        ? exercises.first.effectiveDuration(exercises.first.exercise!)
        : 60;
    state = state.copyWith(
      isLoading: false,
      workout: workout,
      status: WorkoutStatus.notStarted,
      currentExerciseIndex: 0,
      remainingSeconds: initialDuration,
    );
  }

  Future<void> loadWorkout(String userId) async {
    state = state.copyWith(isLoading: true);

    // If HomeViewModel already holds a customized today workout, use that
    final homeWorkout = _ref.read(homeViewModelProvider).todayWorkout;
    if (homeWorkout != null && homeWorkout.exercises.isNotEmpty) {
      setCustomWorkout(homeWorkout);
      return;
    }

    final res = await _ref.read(getTodayWorkoutUseCaseProvider).execute(userId);
    if (res.isSuccess && res.dataOrNull != null) {
      setCustomWorkout(res.dataOrNull!);
    } else {
      state = state.copyWith(isLoading: false); // error handling omitted for brevity
    }
  }

  Future<void> loadWorkoutById(String workoutId) async {
    state = state.copyWith(isLoading: true);
    final res = await _ref.read(getWorkoutByIdUseCaseProvider).execute(workoutId);
    if (res.isSuccess && res.dataOrNull != null) {
      setCustomWorkout(res.dataOrNull!);
    } else {
      state = state.copyWith(isLoading: false); // error handling omitted for brevity
    }
  }

  void start() {
    if (state.status == WorkoutStatus.notStarted || state.status == WorkoutStatus.paused) {
      state = state.copyWith(status: WorkoutStatus.playing);
      _startTimer();
    }
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: WorkoutStatus.paused);
  }

  void skipToNext() {
    _timer?.cancel();
    _nextState();
  }

  void skipToPrevious() {
    if (state.workout == null) return;
    _timer?.cancel();
    final prevIndex = state.currentExerciseIndex > 0 ? state.currentExerciseIndex - 1 : 0;
    final prevEx = state.workout!.exercises[prevIndex].exercise!;
    state = state.copyWith(
      status: WorkoutStatus.playing,
      currentExerciseIndex: prevIndex,
      remainingSeconds: state.workout!.exercises[prevIndex].effectiveDuration(prevEx),
    );
    _startTimer();
  }

  Future<void> completeWorkout() async {
    _timer?.cancel();
    state = state.copyWith(status: WorkoutStatus.finished);
    
    final userId = _ref.read(localStorageProvider).userId ?? 'local';
    final completedExercises = state.workout?.exercises
            .map((we) => we.exercise)
            .whereType<ExerciseEntity>()
            .toList() ??
        const [];
    await _ref.read(completeWorkoutUseCaseProvider).execute(
      userId: userId,
      durationMinutes: state.workout?.estimatedMinutes ?? 15,
      completedExercises: completedExercises,
    );
    
    // Also refresh the home screen and achievements/garden to show updated XP and plants
    _ref.read(homeViewModelProvider.notifier).refresh();
    _ref.read(achievementsViewModelProvider.notifier).refresh();

    // If there is an active weekly plan, automatically check off the completed plan day
    try {
      final planState = _ref.read(planViewModelProvider);
      if (planState.plan != null) {
        int? targetDay;
        final workoutId = state.workout?.id;
        if (workoutId != null) {
          final decoded = Uri.decodeComponent(workoutId);
          if (decoded.contains('|')) {
            final parts = decoded.split('|');
            if (parts.length >= 3) {
              targetDay = int.tryParse(parts[2]);
            }
          }
        }
        targetDay ??= DateTime.now().weekday; // fallback to today's weekday

        final dayItem = planState.plan!.days.where((d) => d.day == targetDay).firstOrNull;
        if (dayItem != null && !dayItem.isCompleted) {
          _ref.read(planViewModelProvider.notifier).toggleDayCompletion(targetDay);
        }
      }
    } catch (_) {}
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        timer.cancel();
        _nextState();
      }
    });
  }

  void _nextState() {
    if (state.workout == null) return;
    
    if (state.status == WorkoutStatus.playing) {
      // Transition to rest
      final ex = state.currentExercise?.exercise;
      if (ex != null && ex.restSeconds > 0) {
        state = state.copyWith(
          status: WorkoutStatus.resting,
          remainingSeconds: ex.restSeconds,
        );
        _startTimer();
        return;
      }
    }

    // Transition to next exercise or finish
    final nextIndex = state.currentExerciseIndex + 1;
    if (nextIndex < state.workout!.exercises.length) {
      final nextEx = state.workout!.exercises[nextIndex].exercise!;
      state = state.copyWith(
        status: WorkoutStatus.playing,
        currentExerciseIndex: nextIndex,
        remainingSeconds: state.workout!.exercises[nextIndex].effectiveDuration(nextEx),
      );
      _startTimer();
    } else {
      completeWorkout();
    }
  }
}

final workoutViewModelProvider = StateNotifierProvider.autoDispose<WorkoutViewModel, WorkoutState>((ref) {
  return WorkoutViewModel(ref);
});
