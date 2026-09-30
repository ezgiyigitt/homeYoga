import 'dart:math';
import '../../../core/constants/practice_catalog.dart';
import '../../entities/exercise_entity.dart';
import '../../entities/user_profile_entity.dart';
import '../../entities/workout_entity.dart';

/// Katalogdaki bir seansı (isim listesi) gerçek video kayıtlarına
/// bağlayan tek yer. Seans tanımları klip ADI tutar; kütüphane ise
/// Supabase'den gelen [ExerciseEntity] listesidir. Eşleştirme burada
/// yapılır ki isim eşleştirme mantığı projede tek bir yerde dursun.
abstract class SessionResolver {
  SessionResolver._();

  /// Bir seansı çalıştırılabilir bir antrenmana çevirir.
  ///
  /// [excludeClips] verilirse (ağrı kuralları) o klipler seanstan
  /// sessizce çıkarılır — kullanıcı planı görür, sakıncalı hareket
  /// hiç ekrana gelmez.
  ///
  /// Kütüphanede karşılığı bulunmayan klip atlanır: uydurma bir kayıt
  /// üretmek yerine seans bir hareket kısa oynar. Hiç klip kalmazsa
  /// null döner, çağıran taraf yedeğe düşer.
  static WorkoutEntity? build({
    required PracticeSession session,
    required List<ExerciseEntity> pool,
    String idPrefix = 'session',
    Set<String> excludeClips = const {},
    String? nameOverride,
    String? descriptionOverride,
  }) {
    final resolved = <ExerciseEntity>[];
    for (final clipName in session.clips) {
      if (excludeClips.contains(clipName)) continue;
      final ex = findClip(clipName, pool);
      if (ex != null && !resolved.any((e) => e.id == ex.id)) {
        resolved.add(ex);
      }
    }

    if (resolved.isEmpty) return null;

    final exercises = resolved.asMap().entries.map((e) {
      return WorkoutExerciseEntity(
        id: '${idPrefix}_${e.key}',
        exerciseId: e.value.id,
        orderIndex: e.key,
        exercise: e.value,
      );
    }).toList(growable: false);

    final totalSeconds = resolved.fold<int>(
      0,
      (sum, ex) => sum + ex.durationSeconds + ex.restSeconds,
    );

    return WorkoutEntity(
      id: 'session:${session.id}',
      name: nameOverride ?? session.name,
      description: descriptionOverride ?? session.description,
      estimatedMinutes: max(3, (totalSeconds / 60).ceil()),
      difficulty: session.level,
      category: session.axisLabel,
      exercises: exercises,
    );
  }

  /// Klip adını kütüphanede arar. Önce birebir eşleşme, sonra içerme,
  /// en son noktalama/boşluk sadeleştirilmiş karşılaştırma.
  static ExerciseEntity? findClip(String name, List<ExerciseEntity> pool) {
    final target = name.toLowerCase().trim();

    for (final e in pool) {
      if (e.name.toLowerCase().trim() == target) return e;
    }
    for (final e in pool) {
      final n = e.name.toLowerCase();
      if (n.contains(target) || target.contains(n)) return e;
    }
    final key = _key(name);
    for (final e in pool) {
      if (_key(e.name) == key) return e;
    }
    return null;
  }

  static String _key(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  /// Katalogdaki hiçbir klip bulunamadığında son çare: kullanıcının
  /// seviyesine uyan ilk birkaç kliple bir pratik kur. Boş ekran
  /// göstermekten her zaman iyidir.
  static WorkoutEntity emergencyFallback(
    List<ExerciseEntity> pool,
    UserProfileEntity profile,
  ) {
    var candidates =
        pool.where((e) => e.difficulty.index <= profile.fitnessLevel.index).toList();
    if (candidates.isEmpty) candidates = pool;

    final picks = candidates.take(min(4, candidates.length)).toList();
    final exercises = picks.asMap().entries.map((e) {
      return WorkoutExerciseEntity(
        id: 'fallback_${e.key}',
        exerciseId: e.value.id,
        orderIndex: e.key,
        exercise: e.value,
      );
    }).toList(growable: false);

    return WorkoutEntity(
      id: 'session:fallback',
      name: "Today's Practice",
      description: 'A short practice picked from your library.',
      estimatedMinutes: max(5, profile.preferredDurationMinutes),
      difficulty: profile.fitnessLevel,
      category: 'Daily',
      exercises: exercises,
    );
  }
}
