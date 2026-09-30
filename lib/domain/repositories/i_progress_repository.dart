import '../entities/user_progress_entity.dart';
import '../../core/utils/result.dart';

abstract class IProgressRepository {
  Future<Result<UserProgressEntity>> getProgress(String userId);
  Future<Result<void>> saveProgress(UserProgressEntity progress);
  
  /// Adds XP, updates streak if needed, and checks for level up
  Future<Result<UserProgressEntity>> addXP(String userId, int amount);

  /// Records one completed practice: adds XP, advances streak/season,
  /// bumps totalPractices, merges [skillGains] into the skill-axis
  /// totals, and appends [exerciseIds] to the recent-exercise history
  /// (capped, most-recent-first) so the daily practice engine can avoid
  /// repeating them. This is the single write path the endless-flow
  /// model uses instead of calling addXP + saveProgress separately.
  Future<Result<UserProgressEntity>> completePractice(
    String userId, {
    required int xpAmount,
    required int durationMinutes,
    required List<String> exerciseIds,
    required Map<String, int> skillGains,
  });

  /// The full daily check-in log: date "yyyy-MM-dd" → status
  /// (AppConstants.dayStatusDone/Off/Missed). Days not present are
  /// simply "nothing recorded yet" — the UI decides how to render a
  /// missing past day (as missed) vs a missing future day (as empty).
  Future<Result<Map<String, String>>> getDailyLog(String userId);

  /// Explicitly records [status] for [dateKey] ("yyyy-MM-dd"). Used
  /// both automatically (a completed practice marks today as "done")
  /// and explicitly by the user (marking an off day so no day is ever
  /// silently skipped).
  Future<Result<void>> setDayStatus(String userId, String dateKey, String status);
}
