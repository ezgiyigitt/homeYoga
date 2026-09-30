abstract class AppConstants {
  AppConstants._();

  // ── SharedPreferences Keys ─────────────────────────────
  static const String kIsLoggedIn = 'hy_is_logged_in';
  static const String kOnboardingComplete = 'hy_onboarding_complete';
  static const String kUserFirstName = 'hy_user_first_name';
  static const String kUserLastName = 'hy_user_last_name';
  static const String kUserEmail = 'hy_user_email';
  static const String kUserId = 'hy_user_id';
  static const String kProgressXp = 'hy_prog_xp';
  static const String kProgressLevel = 'hy_prog_level';
  static const String kProgressCurrentStreak = 'hy_prog_c_streak';
  static const String kProgressLongestStreak = 'hy_prog_l_streak';
  static const String kProgressTotalWorkouts = 'hy_prog_t_workouts';
  static const String kProgressTotalMinutes = 'hy_prog_t_minutes';
  static const String kProgressLastWorkoutDate = 'hy_prog_last_date';
  static const String kWeeklyPlan = 'hy_weekly_plan';

  // ── Endless-flow progress keys (added for the "never-ending app"
  // model — see ENDLESS_PLAN.md) ─────────────────────────────────
  static const String kProgressTotalPractices = 'hy_prog_t_practices';
  static const String kProgressSeasonNumber = 'hy_prog_season_num';
  static const String kProgressSeasonDay = 'hy_prog_season_day';
  static const String kProgressRecentExercises = 'hy_prog_recent_ex';
  static const String kSkillFlexibilityPoints = 'hy_skill_flexibility';
  static const String kSkillStrengthPoints = 'hy_skill_strength';
  static const String kSkillBalancePoints = 'hy_skill_balance';
  static const String kSkillBreathPoints = 'hy_skill_breath';

  // ── Daily check-in log (monthly progress bar / 52-card garden) ──
  // Map<String date "yyyy-MM-dd", String status> stored as JSON. The
  // user is asked to open the app and explicitly mark even an "off"
  // day — a day is never silently skipped, it's either done/off
  // (explicit) or, once it's in the past with nothing recorded,
  // rendered as "missed" (computed on the fly, not written).
  static const String kDailyLog = 'hy_daily_log';

  static const String dayStatusDone = 'done';
  static const String dayStatusOff = 'off';
  static const String dayStatusMissed = 'missed';

  // Rolling window shown in the Home monthly progress bar.
  static const int monthlyBarDays = 30;

  // Weeks shown in the İlerleme (Progress) "garden" popup — 52 cards,
  // one per week, each holding a real pot sprite (see plant_level.dart
  // for how a week's practice/miss days turn into a frame index).
  static const int gardenWeeksCount = 52;

  // ── Garden pot sprites ──────────────────────────────────
  // Two 7-frame horizontal spritesheets the user supplied directly
  // (assets/images/, already covered by the blanket 'assets/images/'
  // entry in pubspec.yaml — no separate pubspec entry needed). Frame 1
  // is the mildest state on each side, frame 7 the most extreme.
  static const String plantGrowingAsset = 'assets/images/saksı_canlı.png';
  static const String plantWiltingAsset = 'assets/images/saksı_solgun.png';
  static const int plantSpriteFrameCount = 7;

  // ── XP ────────────────────────────────────────────────
  static const int xpWorkoutComplete = 50;
  static const int xpDailyCheckin = 5;
  static const int xpSevenDayStreak = 100;
  static const int xpAchievement = 100;

  // ── Skill axes (Ustalık ekseni — Faz 4'te radar grafikle
  // gösterilecek, tavansız ilerleyen dört beceri) ──────────
  static const String skillFlexibility = 'flexibility';
  static const String skillStrength = 'strength';
  static const String skillBalance = 'balance';
  static const String skillBreath = 'breath';

  static const List<String> skillAxes = [
    skillFlexibility,
    skillStrength,
    skillBalance,
    skillBreath,
  ];

  static const Map<String, String> skillAxisLabels = {
    skillFlexibility: 'Flexibility',
    skillStrength: 'Strength',
    skillBalance: 'Balance',
    skillBreath: 'Breath',
  };

  // Points awarded per skill axis, per completed practice, weighted by
  // how strongly the exercise targets that axis (see
  // ExerciseEntity.effectiveSkillWeights).
  static const int skillPointsPerPractice = 10;

  // How many days make up one season (Faz 3). A season always ends and
  // a new one begins automatically — the app itself never does.
  static const int seasonLengthDays = 28;

  // How many recently-done exercises are kept to avoid repeats when
  // picking today's practice (see DailyPracticeUseCase).
  static const int recentExerciseCooldownCount = 14;

  /// Cumulative XP required to *reach* [level]. Unbounded on purpose —
  /// this replaces the old fixed 7-entry [levelThresholds] table so
  /// leveling never hits a ceiling. Level is now just a counter, not a
  /// content gate (see ENDLESS_PLAN.md, section 3).
  static int xpForLevel(int level) {
    if (level <= 1) return 0;
    int total = 0;
    for (int i = 1; i < level; i++) {
      total += 150 + 50 * i;
    }
    return total;
  }

  // ── Level Thresholds (cumulative XP) ──────────────────
  // Kept only so older/legacy screens still compile; new progress math
  // should use [xpForLevel] instead, which has no ceiling.
  static const List<int> levelThresholds = [
    0,    // Lv 1 — Foundation
    200,  // Lv 2 — Build
    500,  // Lv 3 — Strength
    900,  // Lv 4 — Flexibility
    1400, // Lv 5 — Balance
    2000, // Lv 6 — Flow
    2800, // Lv 7 — Master
  ];

  static const List<String> levelNames = [
    'Yoga Basics & Breathing', 
    'Core Activation & Posture', 
    'Full Body Strength',
    'Deep Flexibility & Stretching', 
    'Advanced Balance & Focus', 
    'Dynamic Vinyasa Flows', 
    'Yoga Masterclass',
  ];

  // ── Curriculum (Workouts per level) ───────────────────
  static const Map<int, List<String>> levelCurriculum = {
    1: ['Child\'s Pose & Cat-Cow', 'Seated Forward Bend', 'Basic Plank'],
    2: ['Warrior I Flow', 'Supine Spinal Twist', 'Downward Dog Series'],
    3: ['Core Strength', 'Balance Foundation', 'Full Body Stretch'],
    4: ['Deep Flexibility', 'Advanced Plank', 'Morning Yoga Flow'],
    5: ['Balance Mastery', 'Pilates Core', 'Relaxation & Breathing'],
    6: ['Continuous Vinyasa', 'Dynamic Flow', 'Stretching Masterclass'],
    7: ['The Ultimate Master Flow', 'Mind & Body Harmony', 'Expert Balance'],
  };

  // ── Onboarding Options ────────────────────────────────
  static const List<String> goals = [
    'Flexibility', 'Strength', 'Mobility',
    'Stress Relief', 'Weight Management', 'Better Posture',
    'Build Exercise Habit', 'Core Strength', 'Better Sleep',
  ];

  static const List<String> equipment = [
    'No Equipment', 'Yoga Mat', 'Resistance Band',
    'Pilates Ball', 'Dumbbell',
  ];

  static const List<int> workoutDurations = [5, 10, 15, 20, 30, 45];
  static const List<int> workoutFrequencies = [2, 3, 4, 5, 6];
  static const List<String> preferredTimes = ['Morning', 'Afternoon', 'Evening'];

  // ── Categories ────────────────────────────────────────
  static const List<String> mainCategories = ['Yoga', 'Pilates', 'Stretching', 'Breathing'];

  static const Map<String, List<String>> subCategories = {
    'Yoga': ['Beginner Yoga', 'Morning Yoga', 'Relaxation', 'Flexibility', 'Balance'],
    'Pilates': ['Core', 'Full Body', 'Legs & Glutes', 'Posture', 'Beginner Pilates'],
    'Stretching': ['Morning Stretch', 'Back & Neck', 'Full Body', 'Recovery'],
    'Breathing': ['Relax', 'Focus', 'Sleep'],
  };

  static const Map<String, String> categoryEmojis = {
    'Yoga': '🧘',
    'Pilates': '🏃',
    'Stretching': '🌿',
    'Breathing': '🌬️',
  };

  // ── Sound Meditation (mantra + frequency audio) ────────
  // Text-only mantras plus ambient/frequency audio tracks — no video and
  // no voice recording needed, so it can ship without waiting on new
  // filming. Always-accessible from Home, not part of the daily-practice
  // rotation (see MeditationScreen / MeditationViewModel). Feeds the
  // 'breath' skill axis on completion, same as Breathing category clips.
  static const List<String> meditationCategories = ['Calm', 'Focus', 'Sleep', 'Energy'];

  static const Map<String, String> meditationCategoryEmojis = {
    'Calm': '🌊',
    'Focus': '🎯',
    'Sleep': '🌙',
    'Energy': '☀️',
  };

  static const int xpMeditationComplete = 15;
  static const int skillPointsPerMeditation = 10;

  // Rotates on screen while a track plays (no voice narration). ~30 is
  // enough for it not to repeat obviously within a single session.
  static const List<String> mantras = [
    'Breathe in calm, breathe out tension.',
    'This moment is enough.',
    'You are exactly where you need to be.',
    'Let your shoulders soften.',
    'Every breath is a new beginning.',
    'You don\'t have to earn rest.',
    'Slow down. There is no rush here.',
    'Your body knows how to heal.',
    'Peace is already within you.',
    'Let go of what you cannot control.',
    'You are allowed to take up space to breathe.',
    'Stillness is also progress.',
    'Notice the breath. Notice yourself.',
    'You showed up. That is enough.',
    'Release the day, one exhale at a time.',
    'Your calm is not far away — it\'s right here.',
    'Nothing to fix. Just be.',
    'You are safe in this moment.',
    'Let the quiet hold you.',
    'Soften your jaw, soften your mind.',
    'One breath at a time is all you need.',
    'You are allowed to rest without reason.',
    'Trust the pause.',
    'Your presence is enough right now.',
    'Exhale the noise. Inhale the quiet.',
    'You are not behind. You are here.',
    'Let this breath be the only thing that matters.',
    'Gentleness is strength too.',
    'You carry more calm than you think.',
    'Return to the breath, again and again.',
  ];
}
