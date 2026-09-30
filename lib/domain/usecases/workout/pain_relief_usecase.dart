import 'dart:math';
import '../../../core/constants/pain_rules.dart';
import '../../../core/constants/practice_catalog.dart';
import '../../../core/utils/result.dart';
import '../../entities/exercise_entity.dart';
import '../../entities/user_profile_entity.dart';
import '../../entities/workout_entity.dart';
import '../../repositories/i_exercise_repository.dart';
import '../../repositories/i_profile_repository.dart';
import 'session_resolver.dart';

/// "Bir yerim ağrıyor" dendiğinde üretilen sonuç.
class PainReliefPlan {
  /// Tespit edilen bölge. Kırmızı bayrak durumunda da null olabilir.
  final BodyRegion? region;

  /// Önerilen seans. Kırmızı bayrakta null — bilerek plan üretilmez.
  final WorkoutEntity? workout;

  /// Kullanıcıya gösterilecek başlık ve açıklama (uygulama diline göre).
  final String title;
  final String advice;

  /// Bugün bilerek çıkarılan hareketlerin adları — "neden bu poz yok?"
  /// sorusunun cevabı ekranda gösterilebilsin diye.
  final List<String> avoidedToday;

  /// true ise egzersiz önerilmedi; kişi sağlık profesyoneline yönlendirildi.
  final bool isRedFlag;

  const PainReliefPlan({
    required this.region,
    required this.workout,
    required this.title,
    required this.advice,
    this.avoidedToday = const [],
    this.isRedFlag = false,
  });

  bool get hasWorkout => workout != null && workout!.exercises.isNotEmpty;
}

/// ─────────────────────────────────────────────────────────────────────
/// Serbest metinden ("belim ağrıyor", "my neck is stiff", "çok stresliyim")
/// güvenli bir seans üretir.
///
/// Akış:
///   1. Kırmızı bayrak taraması — uyuşma, kırık, ameliyat, gebelik...
///      Bunlardan biri geçiyorsa PLAN ÜRETİLMEZ. Bu bilinçli: uygulamanın
///      yapabileceği en iyi şey, yapamayacağı şeyi söylemek.
///   2. Bölge tespiti (Türkçe + İngilizce, ekler ve aksan farkları
///      normalize edilerek).
///   3. Bölgenin kuralından güvenli klip listesi alınır; sakıncalı
///      klipler seanstan çıkarılır.
///   4. Kullanıcının süre tercihine göre seans kısaltılır/uzatılır.
///
/// Yapay zekâ bu akışın hiçbir adımında karar vermez; Coach sohbeti
/// üretilen planı sadece kelimelerle sunar.
/// ─────────────────────────────────────────────────────────────────────
class PainReliefUseCase {
  final IExerciseRepository _exerciseRepo;
  final IProfileRepository _profileRepo;

  PainReliefUseCase(this._exerciseRepo, this._profileRepo);

  Future<Result<PainReliefPlan>> execute(
    String userId,
    String complaint, {
    bool turkish = true,
    String? userLang,
    String? appLang,
  }) async {
    final effectiveUserLang = userLang ?? (turkish ? 'tr' : 'en');
    final effectiveAppLang = appLang ?? (turkish ? 'tr' : 'en');

    try {
      if (PainTriage.hasRedFlag(complaint)) {
        final redFlagTitle = switch (effectiveUserLang) {
          'tr' => 'Bugün pratik önermiyorum',
          'fr' => 'Pas de pratique aujourd\'hui',
          'es' => 'No recomiendo practicar hoy',
          'zh' => '今日不建议进行练习',
          _ => 'No practice today',
        };
        return Success(PainReliefPlan(
          region: PainTriage.detectRegion(complaint),
          workout: null,
          title: redFlagTitle,
          advice: PainTriage.localizedRedFlagAdvice(effectiveUserLang),
          isRedFlag: true,
        ));
      }

      final region = PainTriage.detectRegion(complaint);
      if (region == null) {
        final notUnderstood = switch (effectiveUserLang) {
          'tr' => 'Nerenin rahatsız ettiğini anlayamadım.',
          'fr' => 'Je n\'ai pas bien compris quelle zone vous gêne.',
          'es' => 'No entendí bien qué zona te está molestando.',
          'zh' => '未能明确您感到不适的具体部位。',
          _ => 'I could not tell which area is bothering you.',
        };
        return Failure(notUnderstood);
      }

      final rule = PainRules.forRegion(region);
      if (rule == null) {
        final noRule = switch (effectiveUserLang) {
          'tr' => 'Bu bölge için henüz bir kural tanımlı değil.',
          'fr' => 'Aucune règle n\'est encore définie pour cette zone.',
          'es' => 'Aún no hay una regla definida para esta zona.',
          'zh' => '暂未为该部位配置针对性缓解方案。',
          _ => 'No rule is defined for that area yet.',
        };
        return Failure(noRule);
      }

      final profileRes = await _profileRepo.getProfile(userId);
      final profile = (profileRes.isSuccess && profileRes.dataOrNull != null)
          ? profileRes.dataOrNull!
          : UserProfileEntity.initial(userId);

      final poolRes = await _exerciseRepo.getAllExercises();
      final pool = (poolRes.isSuccess && poolRes.dataOrNull != null)
          ? poolRes.dataOrNull!
          : const <ExerciseEntity>[];
      if (pool.isEmpty) {
        return const Failure('No exercises are available yet.');
      }

      final workout = _buildRelief(rule, pool, profile, effectiveAppLang);
      if (workout == null) {
        return const Failure('Could not build a session from the library.');
      }

      return Success(PainReliefPlan(
        region: region,
        workout: workout,
        title: rule.localizedTitle(effectiveUserLang),
        advice: rule.localizedAdvice(effectiveUserLang),
        avoidedToday: rule.avoidClips,
      ));
    } catch (e) {
      return Failure(e.toString());
    }
  }

  WorkoutEntity? _buildRelief(
    PainRule rule,
    List<ExerciseEntity> pool,
    UserProfileEntity profile,
    String appLang,
  ) {
    // Süre tercihine göre kaç hareket alınacağı. Ağrı seansı hiçbir
    // zaman uzun olmaz — rahatlatma amacı taşır, antrenman değil.
    final band = DurationBand.fromMinutes(profile.preferredDurationMinutes);
    final maxClips = switch (band) {
      DurationBand.short => 4,
      DurationBand.medium => 6,
      DurationBand.long => 8,
    };

    final avoid = rule.avoidClips.toSet();
    final resolved = <ExerciseEntity>[];
    for (final clipName in rule.safeClips) {
      if (avoid.contains(clipName)) continue; // savunma amaçlı
      final ex = SessionResolver.findClip(clipName, pool);
      if (ex != null && !resolved.any((e) => e.id == ex.id)) {
        resolved.add(ex);
      }
      if (resolved.length >= maxClips) break;
    }

    if (resolved.isEmpty) return null;

    final exercises = resolved.asMap().entries.map((e) {
      return WorkoutExerciseEntity(
        id: 'relief_${e.key}',
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
      id: 'relief:${rule.region.name}',
      name: rule.localizedTitle(appLang),
      description: rule.localizedAdvice(appLang),
      estimatedMinutes: max(3, (totalSeconds / 60).ceil()),
      difficulty: Difficulty.beginner, // rahatlatma seansı her zaman erişilebilir
      category: 'Relief',
      exercises: exercises,
    );
  }

  /// Ağrı bildirilen gün, normal günlük pratikten de çıkarılması gereken
  /// klipler. HomeViewModel bunu kullanarak "bugün bel ağrım var" dendiğinde
  /// günün seansını da güvenli hâle getirebilir.
  static Set<String> clipsToAvoidFor(BodyRegion region) =>
      PainRules.forRegion(region)?.avoidClips.toSet() ?? const {};
}
