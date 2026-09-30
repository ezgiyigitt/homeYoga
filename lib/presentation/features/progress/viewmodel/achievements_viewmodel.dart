import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user_progress_entity.dart';
import '../../../shared/providers/app_providers.dart';

class AchievementsState {
  final bool isLoading;
  final String? error;
  final UserProgressEntity? progress;
  final Map<String, String> dailyLog;

  const AchievementsState({
    this.isLoading = false,
    this.error,
    this.progress,
    this.dailyLog = const {},
  });

  AchievementsState copyWith({
    bool? isLoading,
    String? error,
    UserProgressEntity? progress,
    Map<String, String>? dailyLog,
  }) {
    return AchievementsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      progress: progress ?? this.progress,
      dailyLog: dailyLog ?? this.dailyLog,
    );
  }
}

/// Own ViewModel for the Achievements tab (formerly the near-stub
/// ProgressScreen) — kept separate from HomeViewModel so this screen
/// doesn't depend on Home having already loaded, even though both
/// read from the same [progressRepositoryProvider].
class AchievementsViewModel extends StateNotifier<AchievementsState> {
  final Ref _ref;

  AchievementsViewModel(this._ref) : super(const AchievementsState(isLoading: true)) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true, error: null);
    final userId = _ref.read(localStorageProvider).userId ?? 'local';

    final progressRes = await _ref.read(progressRepositoryProvider).getProgress(userId);
    final logRes = await _ref.read(progressRepositoryProvider).getDailyLog(userId);

    if (progressRes.isFailure) {
      state = state.copyWith(isLoading: false, error: progressRes.errorOrNull);
      return;
    }

    state = state.copyWith(
      isLoading: false,
      progress: progressRes.dataOrNull,
      dailyLog: logRes.isSuccess ? (logRes.dataOrNull ?? const {}) : const {},
    );
  }

  void refresh() => _load();
}

final achievementsViewModelProvider =
    StateNotifierProvider<AchievementsViewModel, AchievementsState>((ref) {
  return AchievementsViewModel(ref);
});
