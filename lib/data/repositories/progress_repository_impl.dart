import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../../core/utils/result.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/supabase_config.dart';
import '../../domain/entities/user_progress_entity.dart';
import '../../domain/repositories/i_progress_repository.dart';
import '../../core/utils/date_key.dart';
import '../local/local_storage.dart';

class ProgressRepositoryImpl implements IProgressRepository {
  final LocalStorage _local;

  ProgressRepositoryImpl(this._local);

  @override
  Future<Result<UserProgressEntity>> getProgress(String userId) async {
    try {
      // Buluttan okuma kendi try'ı içinde: Supabase erişilemezse ya da
      // sorgu hata verirse (eksik kolon, uyumsuz user_id, ağ yok) ekran
      // hata göstermek yerine yerel veriye düşer. Egzersiz katmanı zaten
      // bu deseni kullanıyor (ExerciseRepositoryImpl).
      Map<String, dynamic>? data;
      if (SupabaseConfig.isConfigured) {
        try {
          data = await Supabase.instance.client
              .from('progress')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
        } catch (e) {
          debugPrint('getProgress Supabase error, falling back to local: $e');
        }
      }

      {
        if (data != null) {
          final progress = UserProgressEntity(
            userId: data['user_id'] as String,
            xp: data['xp'] as int? ?? 0,
            level: data['level'] as int? ?? 1,
            currentStreak: data['current_streak'] as int? ?? 0,
            longestStreak: data['longest_streak'] as int? ?? 0,
            totalWorkouts: data['total_workouts'] as int? ?? 0,
            totalMinutes: data['total_minutes'] as int? ?? 0,
            lastWorkoutDate: data['last_workout_date'] != null
                ? DateTime.parse(data['last_workout_date'] as String)
                : null,
            // These columns are optional on the Supabase side (older
            // 'progress' rows / tables won't have them yet) — default to
            // the same values a fresh local user would get.
            totalPractices: data['total_practices'] as int? ?? 0,
            seasonNumber: data['season_number'] as int? ?? 1,
            seasonDay: data['season_day'] as int? ?? 1,
            skillPoints: (data['skill_points'] as Map<String, dynamic>?)
                    ?.map((k, v) => MapEntry(k, v as int)) ??
                const {},
            recentExerciseIds: (data['recent_exercise_ids'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const [],
          );
          return Success(progress);
        }
      }

      // Fallback to local
      final progress = UserProgressEntity(
        userId: userId,
        xp: _local.xp,
        level: _local.level,
        currentStreak: _local.currentStreak,
        longestStreak: _local.longestStreak,
        totalWorkouts: _local.totalWorkouts,
        totalMinutes: _local.totalMinutes,
        lastWorkoutDate: _local.lastWorkoutDate,
        totalPractices: _local.totalPractices,
        seasonNumber: _local.seasonNumber,
        seasonDay: _local.seasonDay,
        skillPoints: _local.skillPoints,
        recentExerciseIds: _local.recentExerciseIds,
      );
      return Success(progress);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> saveProgress(UserProgressEntity progress) async {
    try {
      await _local.saveProgress(
        xp: progress.xp,
        level: progress.level,
        currentStreak: progress.currentStreak,
        longestStreak: progress.longestStreak,
        totalWorkouts: progress.totalWorkouts,
        totalMinutes: progress.totalMinutes,
        lastWorkoutDate: progress.lastWorkoutDate,
      );
      await _local.saveEndlessProgress(
        totalPractices: progress.totalPractices,
        seasonNumber: progress.seasonNumber,
        seasonDay: progress.seasonDay,
        skillPoints: progress.skillPoints,
        recentExerciseIds: progress.recentExerciseIds,
      );

      // Bulut yazımı ayrı bir try içinde ve HATASI LOGLANIR.
      //
      // Eskiden bu upsert dıştaki try'a düşüyordu ve `completePractice`
      // dönüş değerine bakmadığı için hata tamamen sessizdi. Supabase'deki
      // 'progress' tablosunda endless-flow kolonları (total_practices,
      // season_number, season_day, skill_points, recent_exercise_ids)
      // yoksa her kayıt buluta yazılamaz — yerel kayıt yukarıda zaten
      // yapıldığı için veri kaybı olmaz, ama sorun görünür olmalı.
      // Kolonları eklemek için: supabase/migration_progress_endless.sql
      if (SupabaseConfig.isConfigured) {
        try {
          await Supabase.instance.client.from('progress').upsert({
            'user_id': progress.userId,
            'xp': progress.xp,
            'level': progress.level,
            'current_streak': progress.currentStreak,
            'longest_streak': progress.longestStreak,
            'total_workouts': progress.totalWorkouts,
            'total_minutes': progress.totalMinutes,
            'last_workout_date': progress.lastWorkoutDate?.toIso8601String(),
            'total_practices': progress.totalPractices,
            'season_number': progress.seasonNumber,
            'season_day': progress.seasonDay,
            'skill_points': progress.skillPoints,
            'recent_exercise_ids': progress.recentExerciseIds,
          });
        } catch (e) {
          debugPrint(
              'saveProgress Supabase upsert failed (local save kept): $e');
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<UserProgressEntity>> addXP(String userId, int amount) async {
    try {
      final res = await getProgress(userId);
      if (res.isFailure) return res;

      var p = res.dataOrNull!;
      final updated = _applyXpAndStreak(p, amount);

      await saveProgress(updated);
      return Success(updated);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<UserProgressEntity>> completePractice(
    String userId, {
    required int xpAmount,
    required int durationMinutes,
    required List<String> exerciseIds,
    required Map<String, int> skillGains,
  }) async {
    try {
      final res = await getProgress(userId);
      if (res.isFailure) return res;

      final before = res.dataOrNull!;

      // Bugünün ilk pratiği mi? Gün bazlı sayaçlar (sezon günü) yalnızca
      // ilkinde ilerlemeli — yoksa gün içinde iki seans yapan biri sezonu
      // iki gün ileri sarıyor ve "28 günlük sezon" fiilen "28 pratik"
      // oluyordu. XP, süre, toplam pratik ve beceri puanları ise her
      // seansta kazanılmaya devam eder.
      final isFirstPracticeToday = before.lastWorkoutDate == null ||
          dateOnly(before.lastWorkoutDate!) != dateOnly(DateTime.now());

      var p = _applyXpAndStreak(before, xpAmount);

      // Merge skill gains (uncapped — see UserProgressEntity docs).
      final mergedSkills = Map<String, int>.from(p.skillPoints);
      skillGains.forEach((axis, gain) {
        mergedSkills[axis] = (mergedSkills[axis] ?? 0) + gain;
      });

      // Sezon günü GÜNDE BİR ilerler; sezon dolduğunda bir sonrakine
      // kendiliğinden geçer (ENDLESS_PLAN.md, Faz 3) — uygulama hiç
      // "bitmez".
      int newSeasonDay = p.seasonDay;
      int newSeasonNumber = p.seasonNumber;
      if (isFirstPracticeToday) {
        newSeasonDay += 1;
        if (newSeasonDay > AppConstants.seasonLengthDays) {
          newSeasonDay = 1;
          newSeasonNumber++;
        }
      }

      // Tekrar engeli geçmişi: her eleman BİR pratik (o pratiğin egzersiz
      // id'leri virgülle birleşik). Böylece cooldown gerçekten son
      // [recentExerciseCooldownCount] *pratiği* kapsar; eskiden o kadar
      // *egzersiz* tutuluyordu ve bir seans 5–11 klip içerdiği için
      // hafıza ancak bir buçuk seans geriye gidiyordu.
      final thisPractice = exerciseIds.where((e) => e.trim().isNotEmpty).join(',');
      final recent = [
        if (thisPractice.isNotEmpty) thisPractice,
        ...p.recentExerciseIds,
      ];
      final trimmedRecent =
          recent.take(AppConstants.recentExerciseCooldownCount).toList();

      p = p.copyWith(
        totalWorkouts: p.totalWorkouts + 1,
        totalMinutes: p.totalMinutes + durationMinutes,
        totalPractices: p.totalPractices + 1,
        seasonNumber: newSeasonNumber,
        seasonDay: newSeasonDay,
        skillPoints: mergedSkills,
        recentExerciseIds: trimmedRecent,
      );

      await saveProgress(p);

      // A completed practice always counts as today's check-in — the
      // user never has to separately confirm "I did it today".
      await setDayStatus(userId, dateKey(DateTime.now()), AppConstants.dayStatusDone);

      return Success(p);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<Map<String, String>>> getDailyLog(String userId) async {
    try {
      if (SupabaseConfig.isConfigured) {
        try {
          final res = await Supabase.instance.client
              .from('daily_log')
              .select('day, status')
              .eq('user_id', userId);

          final cloudMap = <String, String>{};
          for (final row in (res as List)) {
            final day = row['day']?.toString();
            final status = row['status']?.toString();
            if (day != null && status != null) {
              cloudMap[day] = status;
            }
          }

          final localLog = _local.dailyLog;
          final merged = Map<String, String>.from(localLog)..addAll(cloudMap);
          await _local.saveDailyLog(merged);

          // Cihazda olup henüz buluta gitmemiş kayıtlar varsa senkronize et
          final unsynced = localLog.entries
              .where((e) =>
                  !cloudMap.containsKey(e.key) &&
                  (e.value == AppConstants.dayStatusDone ||
                      e.value == AppConstants.dayStatusOff))
              .toList();
          if (unsynced.isNotEmpty) {
            try {
              await Supabase.instance.client.from('daily_log').upsert(
                unsynced.map((e) => {
                  'user_id': userId,
                  'day': e.key,
                  'status': e.value,
                  'updated_at': DateTime.now().toUtc().toIso8601String(),
                }).toList(),
              );
            } catch (e) {
              debugPrint('daily_log sync to Supabase failed: $e');
            }
          }

          return Success(merged);
        } catch (e) {
          debugPrint('getDailyLog Supabase error, falling back to local: $e');
        }
      }

      return Success(_local.dailyLog);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  @override
  Future<Result<void>> setDayStatus(
      String userId, String dateKey, String status) async {
    try {
      await _local.setDayStatus(dateKey, status);

      if (SupabaseConfig.isConfigured) {
        try {
          await Supabase.instance.client.from('daily_log').upsert({
            'user_id': userId,
            'day': dateKey,
            'status': status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          });
        } catch (e) {
          debugPrint(
              'setDayStatus Supabase upsert failed (local save kept): $e');
        }
      }

      return const Success(null);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  /// Shared XP/level/streak math used by both [addXP] and
  /// [completePractice] so the two write paths can never drift apart.
  UserProgressEntity _applyXpAndStreak(UserProgressEntity p, int xpAmount) {
    final newXp = p.xp + xpAmount;
    int newLevel = p.level;

    // Level is unbounded now — AppConstants.xpForLevel has no ceiling,
    // unlike the old fixed levelThresholds table.
    while (newXp >= AppConstants.xpForLevel(newLevel + 1)) {
      newLevel++;
    }

    // Streak TAKVİM GÜNÜ farkına bakar — saat farkına değil.
    //
    // Eskiden `now.difference(lastWorkoutDate).inDays` kullanılıyordu ve
    // bu iki yönde birden yanlıştı: dün 20:00 + bugün 09:00 = 13 saat →
    // 0 gün → seri artmıyordu; Pzt 22:00 + Çar 09:00 = 35 saat → 1 gün →
    // araya bir gün girmesine rağmen seri artıyordu. Günü sadeleştirip
    // (dateOnly) karşılaştırmak ikisini de çözüyor.
    int newStreak = p.currentStreak;
    int newLongest = p.longestStreak;
    final now = DateTime.now();

    if (p.lastWorkoutDate != null) {
      final dayDiff =
          dateOnly(now).difference(dateOnly(p.lastWorkoutDate!)).inDays;
      if (dayDiff == 0) {
        // Aynı gün ikinci pratik — bugün seriye zaten sayıldı.
        if (newStreak < 1) newStreak = 1;
      } else if (dayDiff == 1) {
        newStreak++;
      } else {
        newStreak = 1;
      }
    } else {
      newStreak = 1;
    }

    if (newStreak > newLongest) {
      newLongest = newStreak;
    }

    return p.copyWith(
      xp: newXp,
      level: newLevel,
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastWorkoutDate: now,
    );
  }
}
