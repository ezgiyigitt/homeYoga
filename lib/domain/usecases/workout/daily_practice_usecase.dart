import 'dart:math';
import '../../../core/utils/result.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/practice_catalog.dart';
import '../../entities/exercise_entity.dart';
import '../../entities/user_profile_entity.dart';
import '../../entities/user_progress_entity.dart';
import '../../entities/workout_entity.dart';
import '../../repositories/i_exercise_repository.dart';
import '../../repositories/i_profile_repository.dart';
import '../../repositories/i_progress_repository.dart';
import 'session_resolver.dart';

/// ─────────────────────────────────────────────────────────────────────
/// "BUGÜNÜN PRATİĞİ" — seçim motoru.
///
/// Eski hâli katalogdan rastgele klip topluyordu; kullanıcıya kopuk ve
/// gelişigüzel bir liste çıkıyordu ve ekran her yenilendiğinde pratik
/// değişiyordu. Yeni hâli, kullanıcıya İSİMLİ BİR SEANS verir
/// (PracticeCatalog) ve seansı beş kurala göre seçer:
///
///   1. SEVİYE  — Kullanıcının onboarding'de seçtiği seviyenin altındaki
///                ve o seviyedeki seanslar açıktır; üstündekiler görünmez.
///                Beginner bir kullanıcıya asla Advanced Plank Challenge
///                düşmez.
///   2. HAFTALIK RİTİM — Haftanın günü hangi ekseni çalışacağını belirler.
///                Pzt Güç, Sal Esneklik, Çar Denge, Per Güç, Cum Esneklik,
///                Cmt uzun karma, Paz Nefes/toparlanma. Bu, gerçek hayatta
///                bir insanın haftasının nasıl geçtiğine uyar: hafta
///                başında enerjik, hafta sonunda toparlayıcı.
///   3. DENGELEME — Bir beceri ekseni belirgin biçimde geride kaldıysa
///                (bkz. [_axisIsLagging]) günün ekseni onunla değiştirilir.
///                Kullanıcı "eksiğimi kapatıyorum" hisseder.
///   4. SÜRE     — Tercih edilen süre bandı; hafta sonu bir üst band.
///   5. TEKRAR ENGELİ — Son yapılan klipler ve gün indeksi ile aynı seans
///                arka arkaya gelmez; aynı eksende birden çok uygun seans
///                varsa sırayla dönerler.
///
/// Ayrıca: haftada kaç gün pratik yapmak istediği (workoutFrequencyPerWeek)
/// haftanın hangi günlerinin pratik günü olduğunu belirler; dinlenme
/// gününde ağır bir seans değil, kısa bir nefes/toparlanma seansı önerilir.
///
/// Seçim TARİHE BAĞLI ve DETERMİNİSTİKTİR: aynı gün içinde ekranı kaç kez
/// yenilerse yenilesin aynı seansı görür. Rastgelelik sadece eşitlik
/// bozma amaçlı ve yine günün tarihinden türetilir — yani "rastgele"
/// değil, "her gün farklı".
/// ─────────────────────────────────────────────────────────────────────
class DailyPracticeUseCase {
  final IExerciseRepository _exerciseRepo;
  final IProfileRepository _profileRepo;
  final IProgressRepository _progressRepo;
  final Random? _overrideRandom;

  DailyPracticeUseCase(
    this._exerciseRepo,
    this._profileRepo,
    this._progressRepo, {
    Random? random,
  }) : _overrideRandom = random;

  /// Eksen döngüsü. Haftanın gününe DEĞİL, kaçıncı pratik günü olduğuna
  /// bağlıdır — çünkü kullanıcı haftada 2 gün de çalışabilir, 6 gün de.
  /// Takvim gününe bağlasaydık haftada 3 gün çalışan biri (örn. Pzt/Per/Cmt)
  /// bazı eksenleri hiç görmezdi.
  ///
  /// Sıra bilinçli: esneklik ve güç en sık (haftanın omurgası), denge
  /// düzenli ama daha seyrek, nefes/sakinlik her altı seansta bir gelir —
  /// yani gerçek bir insanın haftasında olduğu gibi, arada bir toparlanma
  /// seansı düşer.
  /// Uzunluğu 7 ve tek sayı olması bilinçli: bir eksen döngü içinde iki
  /// kez geçtiğinde (güç, esneklik, denge) iki geçiş arasındaki mesafe
  /// tek sayı olur, böylece aşağıdaki `offset` hesabı o iki gün için
  /// farklı seans seçer. Çift uzunlukta bir döngüde aynı eksenin iki
  /// günü hep aynı seansa denk geliyordu.
  static const List<String> _axisCycle = [
    AppConstants.skillStrength,
    AppConstants.skillFlexibility,
    AppConstants.skillBalance,
    AppConstants.skillBreath,
    AppConstants.skillFlexibility,
    AppConstants.skillStrength,
    AppConstants.skillBalance,
  ];

  /// Bir eksenin "geride kaldı" sayılması için diğerlerinin ortalamasının
  /// bu oranın altında kalması gerekir. Çok küçük tutulursa motor her gün
  /// aynı ekseni seçer ve haftalık ritim anlamsızlaşır.
  static const double _laggingRatio = 0.6;

  Future<Result<WorkoutEntity>> execute(String userId, {DateTime? today}) async {
    try {
      final now = today ?? DateTime.now();

      final profileRes = await _profileRepo.getProfile(userId);
      final profile = (profileRes.isSuccess && profileRes.dataOrNull != null)
          ? profileRes.dataOrNull!
          : UserProfileEntity.initial(userId);

      final progressRes = await _progressRepo.getProgress(userId);
      final progress = (progressRes.isSuccess && progressRes.dataOrNull != null)
          ? progressRes.dataOrNull!
          : UserProgressEntity.initial(userId);

      final poolRes = await _exerciseRepo.getAllExercises();
      final pool = (poolRes.isSuccess && poolRes.dataOrNull != null)
          ? poolRes.dataOrNull!
          : const <ExerciseEntity>[];
      if (pool.isEmpty) {
        return const Failure('No exercises are available yet to build a practice.');
      }

      final session = pickSessionFor(
        profile: profile,
        progress: progress,
        date: now,
        pool: pool,
      );

      final workout = SessionResolver.build(
        session: session,
        pool: pool,
        idPrefix: 'daily',
      );

      if (workout == null || workout.exercises.isEmpty) {
        // Katalogdaki hiçbir klip kütüphanede bulunamadı (isim değişmiş
        // olabilir). Kullanıcıya boş ekran göstermek yerine seviyesine
        // uyan ilk kliplerden bir pratik kur.
        return Success(SessionResolver.emergencyFallback(pool, profile));
      }

      return Success(workout);
    } catch (e) {
      return Failure(e.toString());
    }
  }

  /// Seans seçiminin tamamı — repository'e dokunmadığı için doğrudan
  /// test edilebilir.
  PracticeSession pickSessionFor({
    required UserProfileEntity profile,
    required UserProgressEntity progress,
    required DateTime date,
    List<ExerciseEntity> pool = const [],
  }) {
    final level = profile.fitnessLevel;
    final frequency = profile.workoutFrequencyPerWeek;

    // ── 1. Bugün pratik günü mü, dinlenme günü mü? ──────────────
    final isPracticeDay = _isPracticeDay(
      weekday: date.weekday,
      frequencyPerWeek: frequency,
    );

    // Kaçıncı pratik gün olduğu — eksen döngüsü ve seans sırası buna
    // bağlı, takvim gününe değil.
    final ordinal = _practiceOrdinal(date, frequency);

    // ── 2. Günün ekseni ─────────────────────────────────────────
    var axis = _axisCycle[ordinal % _axisCycle.length];
    final lagging = _laggingAxis(progress);
    if (lagging != null) axis = lagging;
    // Dinlenme günü her zaman nefes/sakinlik ekseninden gelir — seri
    // kırılmasın ama vücut da toparlansın.
    if (!isPracticeDay) axis = AppConstants.skillBreath;

    // ── 3. Süre bandı ───────────────────────────────────────────
    var band = DurationBand.fromMinutes(profile.preferredDurationMinutes);
    final isWeekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    if (isWeekend && isPracticeDay) band = band.longer;
    if (!isPracticeDay) band = DurationBand.short;

    // ── 4. Adaylar: eksen + band + seviye ───────────────────────
    var candidates = PracticeCatalog.query(level: level, axis: axis, band: band);

    // Tek adaya düşmüşse (örn. o eksende o bandda tek seans var) komşu
    // bandları da aç — yoksa aynı seans döngü boyunca tekrar eder.
    if (candidates.length < 2) {
      candidates = {
        ...candidates,
        ...PracticeCatalog.query(level: level, axis: axis, band: band.longer),
        ...PracticeCatalog.query(level: level, axis: axis, band: band.shorter),
      }.toList(growable: false);
    }

    // Band boşsa komşu bandlara aç; yine boşsa eksen kısıtını bırak.
    if (candidates.isEmpty) {
      candidates = PracticeCatalog.query(level: level, axis: axis);
    }
    if (candidates.isEmpty) {
      candidates = PracticeCatalog.query(level: level, band: band);
    }
    if (candidates.isEmpty) {
      candidates = PracticeCatalog.unlockedFor(level);
    }
    if (candidates.isEmpty) {
      // Teorik olarak imkânsız: beginner seansları her zaman açıktır.
      candidates = PracticeCatalog.query(
        level: Difficulty.beginner,
        axis: AppConstants.skillBreath,
      );
    }

    // ── 5. Tekrar engeli ────────────────────────────────────────
    // Son pratiklerin kliplerini büyük ölçüde tekrar eden seansları
    // geri plana at. Karşılaştırma egzersiz ID'si üzerinden yapılır:
    // katalog klip ADI tutar, geçmiş ise ID tutar, o yüzden isimler
    // önce kütüphane üzerinden id'ye çevrilir. (Supabase id'leri uuid
    // olduğu için isimle karşılaştırma hiçbir zaman tutmazdı.)
    final recent = progress.recentExerciseIdSet;
    if (recent.isNotEmpty && candidates.length > 1 && pool.isNotEmpty) {
      final fresh = candidates
          .where((s) => _overlapRatio(s, recent, pool) < 0.6)
          .toList(growable: false);
      if (fresh.isNotEmpty) candidates = fresh;
    }

    // Aynı eksende birkaç aday varsa gün indeksine göre sırayla dön.
    // Böylece seçim hem her gün değişir hem de aynı gün içinde sabittir.
    final sorted = [...candidates]..sort((a, b) => a.id.compareTo(b.id));

    // Sıradaki seans: her tam döngüde bir kayar (böylece aynı eksen bir
    // sonraki hafta farklı bir seansla gelir) ve döngü içindeki konum da
    // eklenir — yoksa aynı eksen döngüde iki kez geçtiğinde (esneklik ve
    // güç öyle) iki gün üst üste tıpatıp aynı seans düşerdi.
    //
    // Dinlenme günlerinde ordinal ilerlemediği için takvim günü kullanılır;
    // aksi hâlde art arda gelen bütün dinlenme günleri aynı seansı gösterir.
    final int offset;
    final random = _overrideRandom;
    if (random != null) {
      offset = random.nextInt(sorted.length);
    } else if (isPracticeDay) {
      offset = (ordinal ~/ _axisCycle.length) + (ordinal % _axisCycle.length);
    } else {
      offset = _dayIndex(date);
    }
    return sorted[offset % sorted.length];
  }

  /// Haftada [frequencyPerWeek] gün pratik isteyen bir kullanıcı için
  /// bugünün pratik günü olup olmadığı. Günler haftaya eşit dağıtılır
  /// (3 gün → Pzt / Çar / Cum gibi), baştan üç güne yığılmaz.
  static bool _isPracticeDay({
    required int weekday,
    required int frequencyPerWeek,
  }) =>
      _isPracticeSlot(weekday - 1, frequencyPerWeek);

  /// [dayOfWeek] 0 = Pazartesi ... 6 = Pazar.
  ///
  /// `(d * f) % 7 < f` haftaya f günü eşit aralıklarla dağıtır ve her
  /// zaman Pazartesi'den başlar: 3 gün → Pzt/Per/Cmt, 4 gün → Pzt/Çar/Cum/Paz,
  /// 5 gün → Pzt/Çar/Per/Cmt/Paz. Baştan üç güne yığılmaz, hafta sonuna da
  /// itilmez.
  static bool _isPracticeSlot(int dayOfWeek, int frequencyPerWeek) {
    final f = frequencyPerWeek.clamp(1, 7);
    if (f >= 7) return true;
    return (dayOfWeek * f) % 7 < f;
  }

  /// Bugünün, kullanıcının pratik takviminde kaçıncı pratik günü olduğu.
  /// Eksen döngüsü ve seans sırası buna bağlıdır; böylece haftada 2 gün
  /// çalışan biri de 6 gün çalışan biri de dört becerinin hepsini görür.
  static int _practiceOrdinal(DateTime date, int frequencyPerWeek) {
    final idx = _dayIndex(date);
    if (idx < 0) return 0;
    final f = frequencyPerWeek.clamp(1, 7);
    // 2024-01-01 bir Pazartesi — bu yüzden idx % 7, haftanın günü
    // indeksiyle (0 = Pzt) birebir örtüşür.
    var count = (idx ~/ 7) * f;
    for (var d = 0; d < idx % 7; d++) {
      if (_isPracticeSlot(d, f)) count++;
    }
    return count;
  }

  /// Diğer eksenlerin ortalamasının belirgin biçimde altında kalan eksen.
  /// Hepsi 0 ise (yeni kullanıcı) null döner — o zaman haftalık ritim
  /// geçerlidir, motor ilk günden "en zayıf eksen" diye tek bir yere
  /// saplanmaz.
  String? _laggingAxis(UserProgressEntity progress) {
    final points = {
      for (final axis in AppConstants.skillAxes) axis: progress.skillPoint(axis)
    };
    final total = points.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) return null;

    final average = total / points.length;
    if (average <= 0) return null;

    String? worst;
    int worstValue = 1 << 30;
    points.forEach((axis, value) {
      if (value < worstValue) {
        worstValue = value;
        worst = axis;
      }
    });

    if (worst == null) return null;
    return worstValue < average * _laggingRatio ? worst : null;
  }

  /// Seansın kliplerinin ne kadarı yakın geçmişte yapılmış? (0.0–1.0)
  double _overlapRatio(
    PracticeSession session,
    Set<String> recentIds,
    List<ExerciseEntity> pool,
  ) {
    if (session.clips.isEmpty) return 0;
    var hits = 0;
    for (final clip in session.clips) {
      final ex = SessionResolver.findClip(clip, pool);
      if (ex != null && recentIds.contains(ex.id)) hits++;
    }
    return hits / session.clips.length;
  }

  /// Takvim gününü tam sayıya çevirir — saat/dakika etkilemez, yani
  /// pratik gün içinde değişmez.
  static int _dayIndex(DateTime date) =>
      DateTime(date.year, date.month, date.day)
          .difference(DateTime(2024, 1, 1))
          .inDays;
}
