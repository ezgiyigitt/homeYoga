import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user_progress_entity.dart';
import '../../../../domain/entities/workout_entity.dart';
import '../../../../domain/entities/exercise_entity.dart';
import '../../../../domain/entities/checkin_entity.dart';
import '../../../../core/utils/date_key.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shared/providers/app_providers.dart';
import '../models/weekly_timeline_day.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final UserProgressEntity? progress;
  final WorkoutEntity? todayWorkout;
  final Mood? todayMood;

  /// Daily check-in log: date "yyyy-MM-dd" → status. Backs the
  /// monthly progress bar at the top of Home (and, by extension, the
  /// weekly "garden" aggregation in the İlerleme popup).
  final Map<String, String> dailyLog;

  /// Days of the current week (Mon–Sun) for the weekly timeline strip.
  final List<WeeklyTimelineDay> weekDays;

  /// The day currently selected in the weekly timeline strip (defaults to today).
  final DateTime? selectedDate;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.progress,
    this.todayWorkout,
    this.todayMood,
    this.dailyLog = const {},
    this.weekDays = const [],
    this.selectedDate,
  });

  /// The WeeklyTimelineDay currently selected by the user.
  WeeklyTimelineDay? get selectedDay {
    if (weekDays.isEmpty) return null;
    final now = DateTime.now();
    final sel = selectedDate ?? DateTime(now.year, now.month, now.day);
    return weekDays.firstWhere(
      (d) => d.date.year == sel.year && d.date.month == sel.month && d.date.day == sel.day,
      orElse: () => weekDays.firstWhere((d) => d.isToday, orElse: () => weekDays.first),
    );
  }

  /// The workout to display in the primary practice card.
  /// If viewing today, returns today's workout. If viewing another day, returns that day's scheduled session.
  WorkoutEntity? get activeDisplayWorkout => selectedDay?.workout ?? todayWorkout;

  /// True if the user is currently viewing today's practice.
  bool get isViewingToday => selectedDay?.isToday ?? true;

  /// True once today has an explicit entry (done or off).
  bool get isTodayLogged => dailyLog.containsKey(dateKey(DateTime.now()));

  /// True if today's practice has already been completed.
  bool get isTodayCompleted => dailyLog[dateKey(DateTime.now())] == AppConstants.dayStatusDone;

  /// True if the currently selected date's practice is completed.
  bool get isSelectedDateCompleted => selectedDay?.isCompleted ?? (isViewingToday && isTodayCompleted);

  HomeState copyWith({
    bool? isLoading,
    String? error,
    UserProgressEntity? progress,
    WorkoutEntity? todayWorkout,
    Mood? todayMood,
    Map<String, String>? dailyLog,
    List<WeeklyTimelineDay>? weekDays,
    DateTime? selectedDate,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      progress: progress ?? this.progress,
      todayWorkout: todayWorkout ?? this.todayWorkout,
      todayMood: todayMood ?? this.todayMood,
      dailyLog: dailyLog ?? this.dailyLog,
      weekDays: weekDays ?? this.weekDays,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  final Ref _ref;

  HomeViewModel(this._ref) : super(const HomeState(isLoading: true)) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);

    final userId = _ref.read(localStorageProvider).userId ?? 'local';

    final progressRes = await _ref.read(progressRepositoryProvider).getProgress(userId);
    final workoutRes = await _ref.read(getTodayWorkoutUseCaseProvider).execute(userId);
    final logRes = await _ref.read(progressRepositoryProvider).getDailyLog(userId);

    if (progressRes.isFailure) {
      state = state.copyWith(isLoading: false, error: progressRes.errorOrNull);
      return;
    }

    var todayWorkout = workoutRes.dataOrNull;
    if (todayWorkout == null || todayWorkout.exercises.isEmpty) {
      final fallbackRes = await _ref.read(exerciseRepositoryProvider).getTodayWorkout(
        difficulty: Difficulty.beginner,
        durationMinutes: 15,
        goals: [],
      );
      if (fallbackRes.isSuccess) {
        todayWorkout = fallbackRes.dataOrNull;
      }
    }

    final dailyLogMap = logRes.isSuccess ? (logRes.dataOrNull ?? const {}) : const <String, String>{};

    // Calculate the 7 days of the current week (Monday through Sunday)
    final now = DateTime.now();
    final todayClean = DateTime(now.year, now.month, now.day);
    final monday = todayClean.subtract(Duration(days: todayClean.weekday - 1));
    final weekDays = <WeeklyTimelineDay>[];

    for (int i = 0; i < 7; i++) {
      final dayDate = monday.add(Duration(days: i));
      final dayKey = dateKey(dayDate);
      final isDone = dailyLogMap[dayKey] == AppConstants.dayStatusDone;
      final isToday = dayDate.isAtSameMomentAs(todayClean);

      WorkoutEntity? dayWorkout;
      if (isToday) {
        dayWorkout = todayWorkout;
      } else {
        final dayRes = await _ref.read(getTodayWorkoutUseCaseProvider).execute(userId, today: dayDate);
        dayWorkout = dayRes.dataOrNull;
      }

      weekDays.add(WeeklyTimelineDay(
        date: dayDate,
        isToday: isToday,
        isCompleted: isDone,
        workout: dayWorkout,
      ));
    }

    state = state.copyWith(
      isLoading: false,
      progress: progressRes.dataOrNull,
      todayWorkout: todayWorkout,
      dailyLog: dailyLogMap,
      weekDays: weekDays,
      selectedDate: state.selectedDate ?? todayClean,
    );
  }

  void refresh() => _loadData();

  /// Changes the currently viewed day in the weekly timeline strip.
  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setMood(Mood mood) {
    state = state.copyWith(todayMood: mood);
  }

  /// Sets today's active practice (e.g. when user accepts a personalized
  /// relief session suggested by AI Coach).
  void setTodayWorkout(WorkoutEntity workout) {
    state = state.copyWith(todayWorkout: workout);
  }

  /// Explicitly marks today as an off day — the affordance behind the
  /// monthly progress bar's "off günü" action.
  Future<void> markTodayOff() async {
    final userId = _ref.read(localStorageProvider).userId ?? 'local';
    await _ref.read(markDayOffUseCaseProvider).execute(userId);
    await _loadData();
  }
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel(ref);
});
