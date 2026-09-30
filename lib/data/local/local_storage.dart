import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Thin wrapper around SharedPreferences with typed accessors.
class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // ── Auth ──────────────────────────────────────────────
  bool get isLoggedIn => _prefs.getBool(AppConstants.kIsLoggedIn) ?? false;
  String? get email => _prefs.getString(AppConstants.kUserEmail);
  String? get userId => _prefs.getString(AppConstants.kUserId);
  bool get onboardingComplete =>
      _prefs.getBool(AppConstants.kOnboardingComplete) ?? false;

  Future<void> saveSession({
    required String userId,
    required String email,
  }) async {
    await _prefs.setBool(AppConstants.kIsLoggedIn, true);
    await _prefs.setString(AppConstants.kUserId, userId);
    await _prefs.setString(AppConstants.kUserEmail, email);
  }

  Future<void> clearSession() async {
    await _prefs.remove(AppConstants.kIsLoggedIn);
    await _prefs.remove(AppConstants.kUserId);
    await _prefs.remove(AppConstants.kUserEmail);
    await _prefs.setBool(AppConstants.kOnboardingComplete, false);
  }

  // ── Onboarding ────────────────────────────────────────
  Future<void> saveOnboardingComplete({
    required String firstName,
    required String lastName,
  }) async {
    await _prefs.setBool(AppConstants.kOnboardingComplete, true);
    await _prefs.setString(AppConstants.kUserFirstName, firstName);
    await _prefs.setString(AppConstants.kUserLastName, lastName);
  }

  String get firstName => _prefs.getString(AppConstants.kUserFirstName) ?? '';
  String get lastName => _prefs.getString(AppConstants.kUserLastName) ?? '';

  // ── Profile Cache ─────────────────────────────────────
  static const _kUserProfileData = 'user_profile_data';

  Map<String, dynamic>? get userProfileData {
    final raw = _prefs.getString(_kUserProfileData);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserProfileData(Map<String, dynamic> data) async {
    await _prefs.setString(_kUserProfileData, jsonEncode(data));
  }

  // ── Progress ──────────────────────────────────────────
  int get xp => _prefs.getInt(AppConstants.kProgressXp) ?? 0;
  int get level => _prefs.getInt(AppConstants.kProgressLevel) ?? 1;
  int get currentStreak => _prefs.getInt(AppConstants.kProgressCurrentStreak) ?? 0;
  int get longestStreak => _prefs.getInt(AppConstants.kProgressLongestStreak) ?? 0;
  int get totalWorkouts => _prefs.getInt(AppConstants.kProgressTotalWorkouts) ?? 0;
  int get totalMinutes => _prefs.getInt(AppConstants.kProgressTotalMinutes) ?? 0;
  DateTime? get lastWorkoutDate {
    final str = _prefs.getString(AppConstants.kProgressLastWorkoutDate);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  Future<void> saveProgress({
    required int xp,
    required int level,
    required int currentStreak,
    required int longestStreak,
    required int totalWorkouts,
    required int totalMinutes,
    DateTime? lastWorkoutDate,
  }) async {
    await _prefs.setInt(AppConstants.kProgressXp, xp);
    await _prefs.setInt(AppConstants.kProgressLevel, level);
    await _prefs.setInt(AppConstants.kProgressCurrentStreak, currentStreak);
    await _prefs.setInt(AppConstants.kProgressLongestStreak, longestStreak);
    await _prefs.setInt(AppConstants.kProgressTotalWorkouts, totalWorkouts);
    await _prefs.setInt(AppConstants.kProgressTotalMinutes, totalMinutes);
    if (lastWorkoutDate != null) {
      await _prefs.setString(AppConstants.kProgressLastWorkoutDate, lastWorkoutDate.toIso8601String());
    }
  }

  // ── Endless-flow progress (practices, season, skills) ──
  int get totalPractices => _prefs.getInt(AppConstants.kProgressTotalPractices) ?? 0;
  int get seasonNumber => _prefs.getInt(AppConstants.kProgressSeasonNumber) ?? 1;
  int get seasonDay => _prefs.getInt(AppConstants.kProgressSeasonDay) ?? 1;

  List<String> get recentExerciseIds {
    final raw = _prefs.getString(AppConstants.kProgressRecentExercises);
    if (raw == null || raw.isEmpty) return const [];
    return raw.split('|').where((s) => s.isNotEmpty).toList();
  }

  Map<String, int> get skillPoints => {
        AppConstants.skillFlexibility: _prefs.getInt(AppConstants.kSkillFlexibilityPoints) ?? 0,
        AppConstants.skillStrength: _prefs.getInt(AppConstants.kSkillStrengthPoints) ?? 0,
        AppConstants.skillBalance: _prefs.getInt(AppConstants.kSkillBalancePoints) ?? 0,
        AppConstants.skillBreath: _prefs.getInt(AppConstants.kSkillBreathPoints) ?? 0,
      };

  Future<void> saveEndlessProgress({
    required int totalPractices,
    required int seasonNumber,
    required int seasonDay,
    required Map<String, int> skillPoints,
    required List<String> recentExerciseIds,
  }) async {
    await _prefs.setInt(AppConstants.kProgressTotalPractices, totalPractices);
    await _prefs.setInt(AppConstants.kProgressSeasonNumber, seasonNumber);
    await _prefs.setInt(AppConstants.kProgressSeasonDay, seasonDay);
    await _prefs.setInt(AppConstants.kSkillFlexibilityPoints, skillPoints[AppConstants.skillFlexibility] ?? 0);
    await _prefs.setInt(AppConstants.kSkillStrengthPoints, skillPoints[AppConstants.skillStrength] ?? 0);
    await _prefs.setInt(AppConstants.kSkillBalancePoints, skillPoints[AppConstants.skillBalance] ?? 0);
    await _prefs.setInt(AppConstants.kSkillBreathPoints, skillPoints[AppConstants.skillBreath] ?? 0);
    await _prefs.setString(AppConstants.kProgressRecentExercises, recentExerciseIds.join('|'));
  }

  // ── Daily check-in log (date "yyyy-MM-dd" → status) ────
  // Backing store for the Home monthly progress bar and the İlerleme
  // "garden" popup. Kept as a flat JSON map here (rather than its own
  // repository) since it's small and read/written as a whole.
  Map<String, String> get dailyLog {
    final raw = _prefs.getString(AppConstants.kDailyLog);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return const {};
    }
  }

  Future<void> saveDailyLog(Map<String, String> log) async {
    await _prefs.setString(AppConstants.kDailyLog, jsonEncode(log));
  }

  /// Sets (or overwrites) the status for a single date, merging into
  /// whatever is already stored.
  Future<void> setDayStatus(String dateKey, String status) async {
    final log = Map<String, String>.from(dailyLog);
    log[dateKey] = status;
    await saveDailyLog(log);
  }

  // ── Weekly Plan ───────────────────────────────────────
  String? get weeklyPlanJson => _prefs.getString(AppConstants.kWeeklyPlan);

  Future<void> saveWeeklyPlan(String jsonString) async {
    await _prefs.setString(AppConstants.kWeeklyPlan, jsonString);
  }

  Future<void> clearWeeklyPlan() async {
    await _prefs.remove(AppConstants.kWeeklyPlan);
  }

  // ── Data reset ────────────────────────────────────────

  /// Wipes this device's practice history, progress and weekly plan while
  /// leaving the sign-in session and the user's profile alone. Backs the
  /// "Clear local data" action in Settings → Privacy & Security.
  Future<void> clearProgressData() async {
    const keys = [
      AppConstants.kDailyLog,
      AppConstants.kWeeklyPlan,
      AppConstants.kProgressXp,
      AppConstants.kProgressLevel,
      AppConstants.kProgressCurrentStreak,
      AppConstants.kProgressLongestStreak,
      AppConstants.kProgressTotalWorkouts,
      AppConstants.kProgressTotalMinutes,
      AppConstants.kProgressTotalPractices,
      AppConstants.kProgressLastWorkoutDate,
      AppConstants.kProgressSeasonNumber,
      AppConstants.kProgressSeasonDay,
      AppConstants.kProgressRecentExercises,
      AppConstants.kSkillFlexibilityPoints,
      AppConstants.kSkillStrengthPoints,
      AppConstants.kSkillBalancePoints,
      AppConstants.kSkillBreathPoints,
    ];
    for (final key in keys) {
      await _prefs.remove(key);
    }
  }

  // ── Pro / Subscription ──────────────────────────────
  bool get isPro => _prefs.getBool('is_pro_member') ?? false;
  Future<void> setPro(bool value) async => _prefs.setBool('is_pro_member', value);

  // ── AI Coach Questions & Rewarded Ads ─────────────────
  static const String _kCoachQuestionsDate = 'coach_questions_date';
  static const String _kCoachQuestionsRemaining = 'coach_questions_remaining';
  static const int kDailyFreeCoachQuestions = 5;
  int? _coachQuestionsCache;

  String _todayDateKey() => DateTime.now().toIso8601String().substring(0, 10);

  int getCoachQuestionsRemaining() {
    if (_coachQuestionsCache != null) {
      return _coachQuestionsCache!;
    }
    final today = _todayDateKey();
    final savedDate = _prefs.getString(_kCoachQuestionsDate);

    // If it's a new day, automatically reset to daily free allowance (5)
    if (savedDate != today) {
      _prefs.setString(_kCoachQuestionsDate, today);
      _prefs.setInt(_kCoachQuestionsRemaining, kDailyFreeCoachQuestions);
      _coachQuestionsCache = kDailyFreeCoachQuestions;
      return kDailyFreeCoachQuestions;
    }

    final val = _prefs.getInt(_kCoachQuestionsRemaining) ?? kDailyFreeCoachQuestions;
    _coachQuestionsCache = val;
    return val;
  }

  Future<void> decrementCoachQuestion() async {
    final current = getCoachQuestionsRemaining();
    final updated = (current - 1).clamp(0, 9999);
    _coachQuestionsCache = updated;
    await _prefs.setString(_kCoachQuestionsDate, _todayDateKey());
    await _prefs.setInt(_kCoachQuestionsRemaining, updated);
  }

  Future<void> addCoachQuestions(int count) async {
    final current = getCoachQuestionsRemaining();
    final updated = current + count;
    _coachQuestionsCache = updated;
    await _prefs.setString(_kCoachQuestionsDate, _todayDateKey());
    await _prefs.setInt(_kCoachQuestionsRemaining, updated);
  }

  Future<void> resetCoachQuestionsForTesting({int count = 5}) async {
    _coachQuestionsCache = count;
    await _prefs.setString(_kCoachQuestionsDate, _todayDateKey());
    await _prefs.setInt(_kCoachQuestionsRemaining, count);
  }

  // ── Single Workout Pro Voiceover Trial ────────────────
  static const String _kHasUsedVoiceoverTrial = 'has_used_voiceover_trial';

  bool get hasUsedVoiceoverTrial =>
      _prefs.getBool(_kHasUsedVoiceoverTrial) ?? false;

  Future<void> setUsedVoiceoverTrial() async {
    await _prefs.setBool(_kHasUsedVoiceoverTrial, true);
  }

  /// Completely wipes all user data, session, profile, progress and subscriptions.
  Future<void> clearAll() async {
    await clearSession();
    await clearProgressData();
    await _prefs.remove(AppConstants.kOnboardingComplete);
    await _prefs.remove(AppConstants.kUserFirstName);
    await _prefs.remove(AppConstants.kUserLastName);
    await _prefs.remove('is_pro_member');
    await _prefs.remove(_kCoachQuestionsDate);
    await _prefs.remove(_kCoachQuestionsRemaining);
    await _prefs.remove(_kHasUsedVoiceoverTrial);
  }
}
