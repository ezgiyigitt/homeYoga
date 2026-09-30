import '../../domain/entities/exercise_entity.dart';
import 'app_constants.dart';

/// ─────────────────────────────────────────────────────────────────────
/// PRACTICE CATALOG — "hangi video ne zaman çıkar" sorusunun tek kaynağı.
///
/// Kütüphanede 24 atomik klip var (Supabase `exercises` tablosu). Bunlar
/// tek başına bir "seans" değil, seansın yapı taşları. Kullanıcının
/// gördüğü şey ise adı olan, başı-sonu olan bir seans: "Morning Mobility
/// Wake-Up", "Core Strength Flow", "Deep Sleep Body Scan"...
///
/// Bu dosya o seansları tanımlar: her seans bir eksen (Esneklik / Güç /
/// Denge / Nefes), bir süre bandı (kısa / orta / uzun), bir seviye ve
/// SIRALI bir klip listesi taşır. Sıra rastgele değil — her seans
/// ısınma → ana blok → soğuma mantığıyla dizilmiştir.
///
/// Dağılım ENDLESS_PLAN.md bölüm 8'deki hedef tabloyla birebir aynıdır:
///
///   Eksen      Kısa  Orta  Uzun
///   Esneklik    3     3     2
///   Güç         3     3     2
///   Denge       2     3     1
///   Nefes       3     2     1
///
/// = 28 seans. Yeni klip çekilmeden 28 farklı, isimli, mantıklı oturum.
/// ─────────────────────────────────────────────────────────────────────

/// Seansın süre bandı. Kullanıcının onboarding'de seçtiği
/// `preferredDurationMinutes` buna çevrilir.
enum DurationBand {
  short, // 5–10 dk
  medium, // 15–20 dk
  long; // 25–30 dk

  String get label => switch (this) {
        DurationBand.short => '5–10 min',
        DurationBand.medium => '15–20 min',
        DurationBand.long => '25–30 min',
      };

  int get typicalMinutes => switch (this) {
        DurationBand.short => 8,
        DurationBand.medium => 18,
        DurationBand.long => 28,
      };

  /// Kullanıcının tercih ettiği süreden bandı bulur.
  static DurationBand fromMinutes(int minutes) {
    if (minutes <= 12) return DurationBand.short;
    if (minutes <= 22) return DurationBand.medium;
    return DurationBand.long;
  }

  /// Bir üst band (hafta sonu / "bugün enerjiğim" için).
  DurationBand get longer => switch (this) {
        DurationBand.short => DurationBand.medium,
        DurationBand.medium => DurationBand.long,
        DurationBand.long => DurationBand.long,
      };

  /// Bir alt band (yorgun gün / off günü için).
  DurationBand get shorter => switch (this) {
        DurationBand.long => DurationBand.medium,
        DurationBand.medium => DurationBand.short,
        DurationBand.short => DurationBand.short,
      };
}

/// Katalogdaki klip adları. Supabase `exercises.name` ile BİREBİR aynı
/// olmak zorunda — seans çözümlemesi isimle eşleşiyor. Sabit olarak
/// tutuluyorlar ki yazım hatası derleme anında değil, tek yerde yakalansın.
abstract class Clip {
  Clip._();

  // Esneklik / mobilite
  static const catCow = 'Cat-Cow Stretch';
  static const childsPose = "Child's Pose";
  static const cobra = 'Cobra Pose';
  static const downwardDog = 'Downward Facing Dog';
  static const seatedForwardBend = 'Seated Forward Bend';
  static const supineTwist = 'Supine Spinal Twist';
  static const neckShoulder = 'Neck & Shoulder Release';
  static const hipOpener = 'Hip Opener Basics';
  static const hamstringCalf = 'Hamstring & Calf Stretch';
  static const deepLunge = 'Deep Lunge Stretch';

  // Güç
  static const plank = 'Plank';
  static const warriorI = 'Warrior I';
  static const warriorII = 'Warrior II';
  static const standingCore = 'Standing Core Activation';
  static const gluteBridge = 'Glute Bridge Series';
  static const sidePlank = 'Side Plank Series';
  static const squatCore = 'Squat & Core Combo';
  static const advancedPlank = 'Advanced Plank Challenge';

  // Denge
  static const treePose = 'Tree Pose Progression';
  static const warriorIII = 'Warrior III Hold';
  static const standingBalance = 'Standing Balance Basics';
  static const singleLegReach = 'Single Leg Reach';

  // Nefes / sakinlik
  static const boxBreathing = 'Box Breathing';
  static const calmReset = '5-Minute Calm Reset';
  static const savasana = 'Savasana';

  /// Kütüphanedeki tüm klipler — AI Coach'a "sadece bunları önerebilirsin"
  /// demek ve katalog bütünlüğünü test etmek için.
  static const List<String> all = [
    catCow, childsPose, cobra, downwardDog, seatedForwardBend, supineTwist,
    neckShoulder, hipOpener, hamstringCalf, deepLunge,
    plank, warriorI, warriorII, standingCore, gluteBridge, sidePlank, squatCore,
    advancedPlank,
    treePose, warriorIII, standingBalance, singleLegReach,
    boxBreathing, calmReset, savasana,
  ];
}

/// Tek bir isimli seans.
class PracticeSession {
  /// Kalıcı kimlik. Rota/derin bağlantı ve "son yapılanlar" geçmişi bunu
  /// kullanır — seansın adı değişse bile id sabit kalmalı.
  final String id;

  final String name;

  /// Türkçe görünen ad (l10n gelene kadar tek yerde durur).
  final String nameTr;

  /// AppConstants.skillAxes içinden biri.
  final String axis;

  final DurationBand band;

  /// Bu seansı görmeye hak kazanmak için gereken en düşük seviye.
  /// Beginner kullanıcı intermediate/advanced seansları GÖRMEZ.
  final Difficulty level;

  /// Sıralı klip listesi (ısınma → ana blok → soğuma).
  final List<String> clips;

  /// Bu seansın çalıştırdığı bölgeler — ağrı motorunun ve "neden bu
  /// seans" açıklamasının kullandığı etiketler.
  final List<String> focusAreas;

  final String description;
  final String descriptionTr;

  const PracticeSession({
    required this.id,
    required this.name,
    required this.nameTr,
    required this.axis,
    required this.band,
    required this.level,
    required this.clips,
    required this.focusAreas,
    required this.description,
    required this.descriptionTr,
  });

  String get axisLabel => AppConstants.skillAxisLabels[axis] ?? axis;

  /// Kullanıcının seviyesi bu seansa yetiyor mu?
  bool isUnlockedFor(Difficulty userLevel) =>
      userLevel.index >= level.index;
}

abstract class PracticeCatalog {
  PracticeCatalog._();

  // ── ESNEKLİK ────────────────────────────────────────────────────
  static const List<PracticeSession> _flexibility = [
    PracticeSession(
      id: 'flex_morning_mobility',
      name: 'Morning Mobility Wake-Up',
      nameTr: 'Sabah Mobilite Uyanışı',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.catCow, Clip.neckShoulder, Clip.downwardDog, Clip.childsPose],
      focusAreas: ['Spine', 'Neck', 'Shoulders', 'Back'],
      description: 'Gently wake the spine and shoulders before the day starts.',
      descriptionTr: 'Güne başlamadan omurgayı ve omuzları nazikçe uyandırır.',
    ),
    PracticeSession(
      id: 'flex_neck_shoulder',
      name: 'Neck & Shoulder Release',
      nameTr: 'Boyun & Omuz Rahatlatma',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.neckShoulder, Clip.catCow, Clip.childsPose],
      focusAreas: ['Neck', 'Shoulders', 'Upper Back'],
      description: 'Unwind desk tension from the neck and shoulder line.',
      descriptionTr: 'Masa başı gerginliğini boyun ve omuz hattından çözer.',
    ),
    PracticeSession(
      id: 'flex_hip_opener',
      name: 'Hip Opener Basics',
      nameTr: 'Kalça Açıcı Temelleri',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.hipOpener, Clip.deepLunge, Clip.childsPose],
      focusAreas: ['Hips', 'Glutes', 'Groin'],
      description: 'Open tight hips with slow, supported holds.',
      descriptionTr: 'Sıkışmış kalçaları yavaş ve destekli tutuşlarla açar.',
    ),
    PracticeSession(
      id: 'flex_deep_flow',
      name: 'Deep Flexibility Flow',
      nameTr: 'Derin Esneklik Akışı',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.catCow,
        Clip.downwardDog,
        Clip.deepLunge,
        Clip.seatedForwardBend,
        Clip.supineTwist,
        Clip.childsPose,
      ],
      focusAreas: ['Spine', 'Hips', 'Hamstrings'],
      description: 'A continuous flow that takes each joint through full range.',
      descriptionTr: 'Her eklemi tam hareket açıklığında gezdiren kesintisiz akış.',
    ),
    PracticeSession(
      id: 'flex_full_body_stretch',
      name: 'Full Body Stretch',
      nameTr: 'Tüm Vücut Esneme',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.medium,
      level: Difficulty.beginner,
      clips: [
        Clip.catCow,
        Clip.neckShoulder,
        Clip.hamstringCalf,
        Clip.hipOpener,
        Clip.supineTwist,
        Clip.childsPose,
      ],
      focusAreas: ['Full Body', 'Spine', 'Hips', 'Hamstrings', 'Neck'],
      description: 'Head-to-toe stretch that leaves nothing tight behind.',
      descriptionTr: 'Baştan ayağa, hiçbir bölgeyi atlamayan esneme.',
    ),
    PracticeSession(
      id: 'flex_hamstring_calf',
      name: 'Hamstring & Calf Release',
      nameTr: 'Arka Bacak & Baldır Rahatlatma',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.medium,
      level: Difficulty.beginner,
      clips: [
        Clip.downwardDog,
        Clip.hamstringCalf,
        Clip.deepLunge,
        Clip.seatedForwardBend,
        Clip.childsPose,
      ],
      focusAreas: ['Hamstrings', 'Calves', 'Legs'],
      description: 'For legs that feel short and stiff after sitting or walking.',
      descriptionTr: 'Uzun oturma ya da yürüyüş sonrası kısalan bacaklar için.',
    ),
    PracticeSession(
      id: 'flex_splits_prep',
      name: 'Splits Prep Deep Stretch',
      nameTr: 'Split Hazırlık Derin Esneme',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.long,
      level: Difficulty.advanced,
      clips: [
        Clip.catCow,
        Clip.downwardDog,
        Clip.deepLunge,
        Clip.hamstringCalf,
        Clip.hipOpener,
        Clip.seatedForwardBend,
        Clip.supineTwist,
        Clip.childsPose,
        Clip.savasana,
      ],
      focusAreas: ['Hips', 'Hamstrings', 'Groin', 'Legs'],
      description: 'The long road to the splits — hips and hamstrings, patiently.',
      descriptionTr: "Split'e giden uzun yol — kalça ve arka bacak, sabırla.",
    ),
    PracticeSession(
      id: 'flex_total_journey',
      name: 'Total Body Flexibility Journey',
      nameTr: 'Tüm Vücut Esneklik Yolculuğu',
      axis: AppConstants.skillFlexibility,
      band: DurationBand.long,
      level: Difficulty.intermediate,
      clips: [
        Clip.catCow,
        Clip.neckShoulder,
        Clip.downwardDog,
        Clip.cobra,
        Clip.deepLunge,
        Clip.hamstringCalf,
        Clip.hipOpener,
        Clip.seatedForwardBend,
        Clip.supineTwist,
        Clip.childsPose,
        Clip.savasana,
      ],
      focusAreas: ['Full Body', 'Spine', 'Hips', 'Hamstrings', 'Shoulders'],
      description: 'The complete tour: every major line of the body, then rest.',
      descriptionTr: 'Tam tur: vücudun her ana hattı, ardından dinlenme.',
    ),
  ];

  // ── GÜÇ ─────────────────────────────────────────────────────────
  static const List<PracticeSession> _strength = [
    PracticeSession(
      id: 'str_basic_plank',
      name: 'Basic Plank Series',
      nameTr: 'Temel Plank Serisi',
      axis: AppConstants.skillStrength,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.standingCore, Clip.plank, Clip.childsPose],
      focusAreas: ['Core', 'Shoulders', 'Abs'],
      description: 'Find the plank line and learn to hold it honestly.',
      descriptionTr: 'Plank hattını bul ve onu dürüstçe tutmayı öğren.',
    ),
    PracticeSession(
      id: 'str_standing_core',
      name: 'Standing Core Activation',
      nameTr: 'Ayakta Merkez Aktivasyonu',
      axis: AppConstants.skillStrength,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.standingCore, Clip.gluteBridge, Clip.childsPose],
      focusAreas: ['Core', 'Posture', 'Lower Back'],
      description: 'Core work with no floor time — kind to wrists and knees.',
      descriptionTr: 'Yere inmeden merkez çalışması — bilek ve dize nazik.',
    ),
    PracticeSession(
      id: 'str_glute_activation',
      name: 'Glute Activation Basics',
      nameTr: 'Kalça Aktivasyon Temelleri',
      axis: AppConstants.skillStrength,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.gluteBridge, Clip.squatCore, Clip.childsPose],
      focusAreas: ['Glutes', 'Hamstrings', 'Lower Back'],
      description: 'Wake up glutes that switched off from sitting all day.',
      descriptionTr: 'Gün boyu oturmaktan uyuyan kalça kaslarını uyandırır.',
    ),
    PracticeSession(
      id: 'str_core_flow',
      name: 'Core Strength Flow',
      nameTr: 'Merkez Güç Akışı',
      axis: AppConstants.skillStrength,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.standingCore,
        Clip.plank,
        Clip.sidePlank,
        Clip.gluteBridge,
        Clip.supineTwist,
        Clip.childsPose,
      ],
      focusAreas: ['Core', 'Obliques', 'Abs', 'Glutes'],
      description: 'Front, side and back of the core in one continuous set.',
      descriptionTr: 'Merkezin önü, yanı ve arkası tek bir kesintisiz sette.',
    ),
    PracticeSession(
      id: 'str_full_body',
      name: 'Full Body Strength',
      nameTr: 'Tüm Vücut Güç',
      axis: AppConstants.skillStrength,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.warriorI,
        Clip.squatCore,
        Clip.plank,
        Clip.gluteBridge,
        Clip.sidePlank,
        Clip.childsPose,
      ],
      focusAreas: ['Full Body', 'Legs', 'Core', 'Glutes'],
      description: 'Legs, core and shoulders — a balanced strength session.',
      descriptionTr: 'Bacak, merkez ve omuz — dengeli bir güç seansı.',
    ),
    PracticeSession(
      id: 'str_warrior_power',
      name: 'Warrior Power Flow',
      nameTr: 'Savaşçı Güç Akışı',
      axis: AppConstants.skillStrength,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.warriorI,
        Clip.warriorII,
        Clip.downwardDog,
        Clip.cobra,
        Clip.warriorIII,
        Clip.squatCore,
        Clip.childsPose,
      ],
      focusAreas: ['Legs', 'Glutes', 'Core', 'Back'],
      description: 'Standing power poses linked by breath.',
      descriptionTr: 'Nefesle birbirine bağlanan ayakta güç duruşları.',
    ),
    PracticeSession(
      id: 'str_advanced_plank',
      name: 'Advanced Plank Challenge',
      nameTr: 'İleri Plank Meydan Okuması',
      axis: AppConstants.skillStrength,
      band: DurationBand.long,
      level: Difficulty.advanced,
      clips: [
        Clip.standingCore,
        Clip.plank,
        Clip.sidePlank,
        Clip.advancedPlank,
        Clip.gluteBridge,
        Clip.childsPose,
        Clip.savasana,
      ],
      focusAreas: ['Core', 'Shoulders', 'Abs', 'Glutes'],
      description: 'Every plank variation, stacked. Bring your breath.',
      descriptionTr: 'Tüm plank varyasyonları üst üste. Nefesini yanında getir.',
    ),
    PracticeSession(
      id: 'str_vinyasa_builder',
      name: 'Strength Vinyasa Builder',
      nameTr: 'Güç Vinyasa Kurucu',
      axis: AppConstants.skillStrength,
      band: DurationBand.long,
      level: Difficulty.advanced,
      clips: [
        Clip.catCow,
        Clip.downwardDog,
        Clip.warriorI,
        Clip.cobra,
        Clip.plank,
        Clip.sidePlank,
        Clip.squatCore,
        Clip.warriorIII,
        Clip.childsPose,
        Clip.savasana,
      ],
      focusAreas: ['Full Body', 'Core', 'Legs', 'Shoulders'],
      description: 'A full vinyasa built for strength rather than sweat.',
      descriptionTr: 'Ter için değil, güç için kurgulanmış tam bir vinyasa.',
    ),
  ];

  // ── DENGE ───────────────────────────────────────────────────────
  static const List<PracticeSession> _balance = [
    PracticeSession(
      id: 'bal_foundation',
      name: 'Balance Foundation',
      nameTr: 'Denge Temeli',
      axis: AppConstants.skillBalance,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.standingBalance, Clip.treePose, Clip.childsPose],
      focusAreas: ['Ankles', 'Feet', 'Core', 'Posture'],
      description: 'Where balance actually starts: the feet and the gaze.',
      descriptionTr: 'Dengenin gerçekte başladığı yer: ayaklar ve bakış.',
    ),
    PracticeSession(
      id: 'bal_tree_progressions',
      name: 'Tree Pose Progressions',
      nameTr: 'Ağaç Duruşu Aşamaları',
      axis: AppConstants.skillBalance,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.standingBalance, Clip.treePose, Clip.savasana],
      focusAreas: ['Hips', 'Ankles', 'Core', 'Calves'],
      description: 'Tree pose step by step, from calf to inner thigh.',
      descriptionTr: 'Baldırdan iç uyluğa, adım adım ağaç duruşu.',
    ),
    PracticeSession(
      id: 'bal_mastery',
      name: 'Balance Mastery',
      nameTr: 'Denge Ustalığı',
      axis: AppConstants.skillBalance,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.standingBalance,
        Clip.treePose,
        Clip.singleLegReach,
        Clip.warriorIII,
        Clip.childsPose,
      ],
      focusAreas: ['Ankles', 'Core', 'Glutes', 'Hamstrings'],
      description: 'Hold longer, wobble less — balance as a trainable skill.',
      descriptionTr: 'Daha uzun tut, daha az salın — denge çalışılabilir bir beceri.',
    ),
    PracticeSession(
      id: 'bal_single_leg',
      name: 'Single-Leg Stability Flow',
      nameTr: 'Tek Bacak Stabilite Akışı',
      axis: AppConstants.skillBalance,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.standingBalance,
        Clip.singleLegReach,
        Clip.gluteBridge,
        Clip.warriorIII,
        Clip.childsPose,
      ],
      focusAreas: ['Glutes', 'Ankles', 'Hamstrings', 'Core'],
      description: 'The hip stability that keeps one-legged poses honest.',
      descriptionTr: 'Tek bacak duruşlarını ayakta tutan kalça stabilitesi.',
    ),
    PracticeSession(
      id: 'bal_warrior_iii',
      name: 'Warrior III Series',
      nameTr: 'Savaşçı III Serisi',
      axis: AppConstants.skillBalance,
      band: DurationBand.medium,
      level: Difficulty.intermediate,
      clips: [
        Clip.warriorI,
        Clip.warriorIII,
        Clip.singleLegReach,
        Clip.standingCore,
        Clip.childsPose,
      ],
      focusAreas: ['Glutes', 'Hamstrings', 'Core', 'Ankles'],
      description: 'Build to Warrior III one hinge at a time.',
      descriptionTr: "Savaşçı III'e adım adım, her seferinde bir kalça kırılmasıyla.",
    ),
    PracticeSession(
      id: 'bal_expert_challenge',
      name: 'Expert Balance Challenge',
      nameTr: 'Uzman Denge Meydan Okuması',
      axis: AppConstants.skillBalance,
      band: DurationBand.long,
      level: Difficulty.advanced,
      clips: [
        Clip.standingBalance,
        Clip.treePose,
        Clip.warriorI,
        Clip.warriorIII,
        Clip.singleLegReach,
        Clip.sidePlank,
        Clip.squatCore,
        Clip.childsPose,
        Clip.savasana,
      ],
      focusAreas: ['Ankles', 'Core', 'Glutes', 'Full Body'],
      description: 'Long holds, tight transitions, nowhere to hide.',
      descriptionTr: 'Uzun tutuşlar, sıkı geçişler, saklanacak yer yok.',
    ),
  ];

  // ── NEFES / SAKİNLİK ────────────────────────────────────────────
  static const List<PracticeSession> _breath = [
    PracticeSession(
      id: 'brt_box_breathing',
      name: 'Box Breathing Basics',
      nameTr: 'Kutu Nefesi Temelleri',
      axis: AppConstants.skillBreath,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.boxBreathing, Clip.savasana],
      focusAreas: ['Mind', 'Diaphragm', 'Nervous System'],
      description: '4-4-4-4. The fastest way back to a steady nervous system.',
      descriptionTr: '4-4-4-4. Sinir sistemini yatıştırmanın en hızlı yolu.',
    ),
    PracticeSession(
      id: 'brt_evening_wind_down',
      name: 'Evening Wind-Down',
      nameTr: 'Akşam Yavaşlama',
      axis: AppConstants.skillBreath,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [
        Clip.neckShoulder,
        Clip.supineTwist,
        Clip.boxBreathing,
        Clip.savasana,
      ],
      focusAreas: ['Neck', 'Spine', 'Mind'],
      description: 'Put the day down before you put your head down.',
      descriptionTr: 'Başını yastığa koymadan önce günü bırak.',
    ),
    PracticeSession(
      id: 'brt_calm_reset',
      name: '5-Minute Calm Reset',
      nameTr: '5 Dakikalık Sakinlik',
      axis: AppConstants.skillBreath,
      band: DurationBand.short,
      level: Difficulty.beginner,
      clips: [Clip.calmReset],
      focusAreas: ['Mind', 'Nervous System'],
      description: 'Five minutes, eyes closed, nothing to achieve.',
      descriptionTr: 'Beş dakika, gözler kapalı, başarılacak hiçbir şey yok.',
    ),
    PracticeSession(
      id: 'brt_relaxation',
      name: 'Relaxation & Breathing',
      nameTr: 'Gevşeme & Nefes',
      axis: AppConstants.skillBreath,
      band: DurationBand.medium,
      level: Difficulty.beginner,
      clips: [
        Clip.childsPose,
        Clip.supineTwist,
        Clip.boxBreathing,
        Clip.calmReset,
        Clip.savasana,
      ],
      focusAreas: ['Mind', 'Spine', 'Nervous System'],
      description: 'Slow shapes on the floor, then breath, then stillness.',
      descriptionTr: 'Yerde yavaş şekiller, sonra nefes, sonra durgunluk.',
    ),
    PracticeSession(
      id: 'brt_stress_relief',
      name: 'Stress Relief Flow',
      nameTr: 'Stres Atma Akışı',
      axis: AppConstants.skillBreath,
      band: DurationBand.medium,
      level: Difficulty.beginner,
      clips: [
        Clip.catCow,
        Clip.neckShoulder,
        Clip.childsPose,
        Clip.supineTwist,
        Clip.boxBreathing,
        Clip.savasana,
      ],
      focusAreas: ['Neck', 'Shoulders', 'Spine', 'Mind'],
      description: 'Where stress physically sits — neck, jaw, shoulders — released.',
      descriptionTr: 'Stresin fiziksel olarak biriktiği yer — boyun, çene, omuz — çözülür.',
    ),
    PracticeSession(
      id: 'brt_deep_sleep',
      name: 'Deep Sleep Body Scan',
      nameTr: 'Derin Uyku Beden Taraması',
      axis: AppConstants.skillBreath,
      band: DurationBand.long,
      level: Difficulty.beginner,
      clips: [
        Clip.hipOpener,
        Clip.seatedForwardBend,
        Clip.supineTwist,
        Clip.childsPose,
        Clip.boxBreathing,
        Clip.calmReset,
        Clip.savasana,
      ],
      focusAreas: ['Hips', 'Spine', 'Mind', 'Nervous System'],
      description: 'A long, floor-based descent into sleep.',
      descriptionTr: 'Uykuya inen uzun, tamamen yerde geçen bir seans.',
    ),
  ];

  /// Tüm seanslar.
  static const List<PracticeSession> all = [
    ..._flexibility,
    ..._strength,
    ..._balance,
    ..._breath,
  ];

  static PracticeSession? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }

  static List<PracticeSession> byAxis(String axis) =>
      all.where((s) => s.axis == axis).toList(growable: false);

  /// Kullanıcının seviyesinin açtığı seanslar.
  static List<PracticeSession> unlockedFor(Difficulty level) =>
      all.where((s) => s.isUnlockedFor(level)).toList(growable: false);

  /// Eksen + band + seviye filtresi. Seçim motorunun ana sorgusu.
  static List<PracticeSession> query({
    required Difficulty level,
    String? axis,
    DurationBand? band,
  }) {
    return all
        .where((s) =>
            s.isUnlockedFor(level) &&
            (axis == null || s.axis == axis) &&
            (band == null || s.band == band))
        .toList(growable: false);
  }
}
