import '../../core/constants/app_constants.dart';

/// User's gamification state — XP, level, streaks, totals.
///
/// Extended for the "endless flow" model (see ENDLESS_PLAN.md): alongside
/// the original XP/level/streak fields there's now [totalPractices],
/// [seasonNumber]/[seasonDay] (the 28-day rotating theme, Faz 3), a
/// [skillPoints] map (the four never-capped skill axes, Faz 4), and
/// [recentExerciseIds] which the daily practice engine uses so it
/// doesn't repeat what you just did.
class UserProgressEntity {
  final String userId;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;
  final int totalMinutes;
  final DateTime? lastWorkoutDate;

  final int totalPractices;
  final int seasonNumber;
  final int seasonDay;
  final Map<String, int> skillPoints;

  /// Son yapılan pratiklerin geçmişi — her eleman BİR pratiktir ve o
  /// pratikte tamamlanan egzersiz id'lerini virgülle birleştirilmiş
  /// hâlde taşır ("id1,id2,id3").
  ///
  /// Neden böyle: liste eskiden düz bir egzersiz id listesiydi ve
  /// AppConstants.recentExerciseCooldownCount kadar *id* tutuyordu. Bir
  /// seans 5–11 klipten oluştuğu için bu, "son 14 pratik" değil ancak
  /// "son bir buçuk pratik" demek oluyordu; tekrar engeli fiilen
  /// çalışmıyordu. Artık aynı sayı kadar *pratik* saklanıyor.
  ///
  /// Eski (virgülsüz) kayıtlar tek egzersizlik pratik olarak okunur —
  /// yani geçişte veri kaybı ya da çökme olmaz.
  final List<String> recentExerciseIds;

  const UserProgressEntity({
    required this.userId,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalWorkouts = 0,
    this.totalMinutes = 0,
    this.lastWorkoutDate,
    this.totalPractices = 0,
    this.seasonNumber = 1,
    this.seasonDay = 1,
    this.skillPoints = const {},
    this.recentExerciseIds = const [],
  });

  factory UserProgressEntity.initial(String userId) =>
      UserProgressEntity(userId: userId);

  // ── Level ─────────────────────────────────────────────
  // Level is kept as a counter/rozet, not a content gate — its math now
  // comes from the unbounded AppConstants.xpForLevel formula instead of
  // the old fixed 7-entry table, so it never hits a ceiling.
  String get levelLabel =>
      'LEVEL ${level.toString().padLeft(2, '0')}';

  String get levelName {
    final i = (level - 1).clamp(0, AppConstants.levelNames.length - 1);
    return AppConstants.levelNames[i];
  }

  int get levelStartXp => AppConstants.xpForLevel(level);

  int get levelEndXp => AppConstants.xpForLevel(level + 1);

  int get xpInCurrentLevel => xp - levelStartXp;
  int get xpRequiredForLevel => levelEndXp - levelStartXp;

  double get levelProgress {
    if (xpRequiredForLevel <= 0) return 1.0;
    return (xpInCurrentLevel / xpRequiredForLevel).clamp(0.0, 1.0);
  }

  int get xpToNextLevel => (levelEndXp - xp).clamp(0, 9999);

  // ── Practice history ──────────────────────────────────
  /// [recentExerciseIds]'in çözülmüş hâli: her eleman bir pratikte
  /// yapılan egzersiz id'leri.
  List<Set<String>> get recentPractices => recentExerciseIds
      .map((p) => p.split(',').where((s) => s.trim().isNotEmpty).map((s) => s.trim()).toSet())
      .where((s) => s.isNotEmpty)
      .toList(growable: false);

  /// Yakın geçmişte yapılmış bütün egzersiz id'leri, tek bir kümede.
  /// Günlük pratik motorunun tekrar engeli bunu okur.
  Set<String> get recentExerciseIdSet => {
        for (final practice in recentPractices) ...practice,
      };

  // ── Skills ────────────────────────────────────────────
  int skillPoint(String axis) => skillPoints[axis] ?? 0;

  /// The skill axis with the fewest points so far — the daily practice
  /// engine weights its picks toward this axis so the four skills stay
  /// roughly balanced instead of the user only ever doing what they're
  /// already good at.
  String get weakestSkillAxis {
    String weakest = AppConstants.skillAxes.first;
    int lowest = skillPoint(weakest);
    for (final axis in AppConstants.skillAxes.skip(1)) {
      final v = skillPoint(axis);
      if (v < lowest) {
        lowest = v;
        weakest = axis;
      }
    }
    return weakest;
  }

  // ── Season ────────────────────────────────────────────
  int get seasonDaysRemaining =>
      (AppConstants.seasonLengthDays - seasonDay).clamp(0, AppConstants.seasonLengthDays);

  UserProgressEntity copyWith({
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    int? totalWorkouts,
    int? totalMinutes,
    DateTime? lastWorkoutDate,
    int? totalPractices,
    int? seasonNumber,
    int? seasonDay,
    Map<String, int>? skillPoints,
    List<String>? recentExerciseIds,
  }) {
    return UserProgressEntity(
      userId: userId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      totalPractices: totalPractices ?? this.totalPractices,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      seasonDay: seasonDay ?? this.seasonDay,
      skillPoints: skillPoints ?? this.skillPoints,
      recentExerciseIds: recentExerciseIds ?? this.recentExerciseIds,
    );
  }
}
