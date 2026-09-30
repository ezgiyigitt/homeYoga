import 'practice_catalog.dart';

/// ─────────────────────────────────────────────────────────────────────
/// PAIN RULES — "bir yerim ağrıyor" dendiğinde ne olacağı.
///
/// Kritik tasarım kararı: planı YAPAY ZEKÂ ÜRETMEZ. Yapay zekâ sadece
/// cümleyi okuyup hangi bölgeden bahsedildiğini anlamaya yardım eder;
/// hangi pozun güvenli, hangisinin sakıncalı olduğu burada, kodda,
/// sabit kurallarla yazılıdır. Nedeni basit:
///
///  1. Model internet yokken çalışmaz — ağrı, internet olmadığı gün de olur.
///  2. Model kütüphanede olmayan bir poz uydurabilir; kural motoru
///     yalnızca gerçekten var olan 24 klibi önerebilir.
///  3. Bir sağlık önerisinin tekrarlanabilir ve denetlenebilir olması
///     gerekir. Aynı girdi her seferinde aynı planı vermeli.
///
/// Bu bir teşhis aracı değildir. Kurallar "genel popülasyon için makul,
/// güvenli tarafta kalan" seçimlerdir; kırmızı bayrak durumlarında
/// (bkz. [PainTriage.hasRedFlag]) hiç plan üretilmez, kişi bir sağlık
/// profesyoneline yönlendirilir.
/// ─────────────────────────────────────────────────────────────────────

enum BodyRegion {
  lowerBack,
  neckShoulder,
  upperBack,
  hip,
  knee,
  hamstring,
  wrist,
  ankle,
  stress,
  sleep,
  menstrual,
  fatigue,
}

class PainRule {
  final BodyRegion region;

  /// Türkçe ve İngilizce tetikleyici kelimeler (küçük harfe indirilmiş,
  /// Türkçe ekler için kök halinde: "bel" → "belim", "belimde" yakalanır).
  final List<String> keywords;

  /// Bu bölgeye iyi gelen, güvenli klipler — sıralı bir mini seans.
  final List<String> safeClips;

  /// Bu bölge ağrılıyken bugün ÇIKMAMASI gereken klipler. Günlük seçim
  /// motoru da bunu okur: ağrı bildirildiği gün bu klipler filtrelenir.
  final List<String> avoidClips;

  /// Bu bölgeye en yakın hazır seans (varsa) — kullanıcı "tam bir seans
  /// istiyorum" derse buna yönlendirilir.
  final String? relatedSessionId;

  final String titleTr;
  final String adviceTr;
  final String titleEn;
  final String adviceEn;
  final String? titleFr;
  final String? adviceFr;
  final String? titleEs;
  final String? adviceEs;
  final String? titleZh;
  final String? adviceZh;

  const PainRule({
    required this.region,
    required this.keywords,
    required this.safeClips,
    required this.avoidClips,
    required this.titleTr,
    required this.adviceTr,
    required this.titleEn,
    required this.adviceEn,
    this.titleFr,
    this.adviceFr,
    this.titleEs,
    this.adviceEs,
    this.titleZh,
    this.adviceZh,
    this.relatedSessionId,
  });

  String localizedTitle(String langCode) {
    if (langCode.startsWith('tr')) return titleTr;
    if (langCode.startsWith('fr') && titleFr != null) return titleFr!;
    if (langCode.startsWith('es') && titleEs != null) return titleEs!;
    if (langCode.startsWith('zh') && titleZh != null) return titleZh!;
    return titleEn;
  }

  String localizedAdvice(String langCode) {
    if (langCode.startsWith('tr')) return adviceTr;
    if (langCode.startsWith('fr') && adviceFr != null) return adviceFr!;
    if (langCode.startsWith('es') && adviceEs != null) return adviceEs!;
    if (langCode.startsWith('zh') && adviceZh != null) return adviceZh!;
    return adviceEn;
  }
}

abstract class PainRules {
  PainRules._();

  static const List<PainRule> all = [
    PainRule(
      region: BodyRegion.lowerBack,
      keywords: [
        'bel', 'belim', 'bel ağrı', 'bel agri', 'lomber', 'kuyruk sokumu',
        'lower back', 'low back', 'lumbar', 'sciatica', 'siyatik',
        'dos', 'bas du dos', 'lombaire', 'lombaires',
        'espalda', 'lumbar', 'lumbares', 'cintura', 'ciatica', '腰', '后腰', '腰痛', '腰酸', '腰椎',
      ],
      safeClips: [
        Clip.catCow,
        Clip.supineTwist,
        Clip.gluteBridge,
        Clip.hipOpener,
        Clip.childsPose,
        Clip.boxBreathing,
      ],
      avoidClips: [
        Clip.cobra,
        Clip.advancedPlank,
        Clip.seatedForwardBend,
        Clip.squatCore,
        Clip.warriorIII,
      ],
      relatedSessionId: 'flex_full_body_stretch',
      titleTr: 'Bel için nazik gevşetme',
      adviceTr:
          'Bel ağrısında çözüm genelde beli daha çok germek değil, çevresini '
          'hareketlendirmek: omurgayı yumuşatan Cat-Cow, kalçayı açan ve kalça '
          'kaslarını çalıştıran hareketler. Bugün derin geriye eğilmeleri '
          '(Cobra) ve oturarak öne kapanmayı atlıyoruz. Ağrı keskinleşirse dur.',
      titleEn: 'Gentle release for the lower back',
      adviceEn:
          'Lower-back pain usually eases from mobilising around it, not '
          'stretching into it: spinal waves, hip opening, glute work. We skip '
          'deep backbends and seated forward folds today. Stop if pain sharpens.',
    titleFr: 'Soulagement doux pour le bas du dos',
      adviceFr:
          'Pour le bas du dos, la solution est de mobiliser autour plutôt que de trop étirer : mouvements doux de la colonne, ouverture des hanches et fessiers. Nous évitons les flexions arrière profondes et flexions avant assises aujourd\'hui. Arrêtez si la douleur devient vive.',
      titleEs: 'Alivio suave para la zona lumbar',
      adviceEs:
          'Para el dolor lumbar, la clave suele ser movilizar la zona circundante en lugar de estirar demasiado: olas espinales con Cat-Cow, apertura de caderas y activación de glúteos. Hoy evitamos flexiones profundas hacia atrás (Cobra) y hacia adelante sentado. Detente si el dolor se vuelve punzante.',
      titleZh: '腰部温和舒缓练习',
      adviceZh:
          '缓解腰部酸痛的关键通常是在周边进行活动，而不是过度拉伸：通过猫牛式活络脊柱，配合开髋和臀桥激活。今天我们跳过深度后弯（眼镜蛇式）和坐姿前屈。如果感到刺痛请立即停止。',
      ),
    PainRule(
      region: BodyRegion.neckShoulder,
      keywords: [
        'boyun', 'boynum', 'omuz', 'omzum', 'omuzlar', 'trapez', 'ense',
        'neck', 'shoulder', 'trap', 'stiff neck',
        'cou', 'nuque', 'epaule', 'epaules', 'trapeze', 'cervicale',
        'cuello', 'hombro', 'hombros', 'trapecio', 'torticolis', '脖子', '颈', '颈椎', '肩膀', '斜方肌', '落枕',
      ],
      safeClips: [
        Clip.neckShoulder,
        Clip.catCow,
        Clip.childsPose,
        Clip.supineTwist,
        Clip.boxBreathing,
      ],
      avoidClips: [
        Clip.plank,
        Clip.sidePlank,
        Clip.advancedPlank,
        Clip.downwardDog,
      ],
      relatedSessionId: 'flex_neck_shoulder',
      titleTr: 'Boyun & omuz için yük almayan seans',
      adviceTr:
          'Boyun ve omuz ağrısında en büyük hata, ağrıyan bölgeye ağırlık '
          'bindiren pozları sürdürmek. Bugün plank ve Downward Dog gibi omuz '
          'taşıyan hareketleri çıkardık; yerine boyun hattını açan ve omurgayı '
          'yumuşatan hareketler var. Baş dönmesi veya kola yayılan uyuşma '
          'varsa pratiği bırak ve bir hekime danış.',
      titleEn: 'A load-free session for neck & shoulders',
      adviceEn:
          'The common mistake with neck pain is staying in poses that load the '
          'shoulders. Planks and Downward Dog are out today; gentle opening and '
          'spinal mobility are in. Stop and see a clinician if you feel dizziness '
          'or numbness travelling down an arm.',
    titleFr: 'Séance sans charge pour le cou & les épaules',
      adviceFr:
          'L\'erreur fréquente avec les douleurs au cou est de maintenir des postures qui chargent les épaules. La planche et le Chien tête en bas sont retirés aujourd\'hui ; place à l\'ouverture douce et à la mobilité de la colonne. Consultez un médecin en cas de vertiges ou d\'engourdissements dans le bras.',
      titleEs: 'Sesión sin carga para cuello y hombros',
      adviceEs:
          'El error más común con el dolor de cuello es mantener posturas que cargan los hombros. Hoy eliminamos la plancha y el perro boca abajo; en su lugar abrimos el cuello y suavizamos la columna. Si sientes mareos o entumecimiento en el brazo, detén la práctica y consulta a un médico.',
      titleZh: '颈肩零负荷放松练习',
      adviceZh:
          '颈肩酸痛时最常见的错误是继续做给肩部施加体重的姿势。今天我们移除了平板支撑和下犬式；改为舒缓颈部线条和活动脊柱的温和体式。如果感到头晕或手臂发麻，请停止练习并咨询医生。',
      ),
    PainRule(
      region: BodyRegion.upperBack,
      keywords: [
        'sırt', 'sirt', 'sırtım', 'kürek', 'kurek kemigi', 'omurga',
        'upper back', 'mid back', 'spine', 'thoracic',
        'haut du dos', 'omoplate', 'dorsale', 'colonne',
        'espalda alta', 'omoplato', 'omoplatos', 'dorsal', 'columna', '上背', '背部', '背痛', '肩胛骨', '脊椎',
      ],
      safeClips: [
        Clip.catCow,
        Clip.neckShoulder,
        Clip.cobra,
        Clip.supineTwist,
        Clip.childsPose,
      ],
      avoidClips: [Clip.advancedPlank, Clip.sidePlank],
      relatedSessionId: 'flex_morning_mobility',
      titleTr: 'Sırt ve omurga mobilitesi',
      adviceTr:
          'Üst sırt sertliği çoğunlukla hareketsizlikten gelir; küçük ve sık '
          'hareket, uzun ve zorlayıcı esnemelerden daha iyi çalışır. Cat-Cow ve '
          'yatarak omurga burgusu bu bölgeyi güvenle açar.',
      titleEn: 'Upper-back and spine mobility',
      adviceEn:
          'Upper-back stiffness usually comes from stillness, and small frequent '
          'movement beats long forceful stretching. Cat-Cow and supine twists open '
          'this area safely.',
    titleFr: 'Mobilité du haut du dos et de la colonne',
      adviceFr:
          'La raideur du haut du dos vient souvent de l\'immobilité. Les mouvements doux et fréquents sont plus efficaces que les étirements intenses. Cat-Cow et les torsions allongées débloquent cette zone en douceur.',
      titleEs: 'Movilidad de la parte superior de la espalda y columna',
      adviceEs:
          'La rigidez en la parte superior suele deberse a la falta de movimiento. El movimiento frecuente y suave funciona mejor que los estiramientos intensos. Cat-Cow y torsiones en el suelo liberan esta zona con total seguridad.',
      titleZh: '上背部与脊柱灵活性练习',
      adviceZh:
          '上背部僵硬通常源于久坐不动，温和的小幅度活动比强力拉伸更有效。猫牛式和平躺脊柱扭转能安全地打开这片区域。',
      ),
    PainRule(
      region: BodyRegion.hip,
      keywords: [
        'kalça', 'kalca', 'kasık', 'kasik', 'leğen', 'legen', 'pelvis',
        'hip', 'groin', 'glute',
        'hanche', 'hanches', 'bassin', 'aine', 'fessier',
        'cadera', 'caderas', 'pelvis', 'ingle', 'gluteo', '胯', '髋', '髋关节', '盆骨', '腹股沟', '臀部',
      ],
      safeClips: [
        Clip.hipOpener,
        Clip.deepLunge,
        Clip.gluteBridge,
        Clip.supineTwist,
        Clip.childsPose,
      ],
      avoidClips: [Clip.squatCore, Clip.warriorIII, Clip.singleLegReach],
      relatedSessionId: 'flex_hip_opener',
      titleTr: 'Kalça açma ve gevşetme',
      adviceTr:
          'Kalça sıkışması genelde uzun oturmanın sonucudur. Bugün tek bacak '
          'üstünde stabilite isteyen hareketleri (Warrior III, Single Leg Reach) '
          've derin squat\'ı çıkardık; yerine destekli, uzun tutuşlu kalça '
          'açıcılar var.',
      titleEn: 'Hip opening and release',
      adviceEn:
          'Tight hips are usually a sitting problem. Single-leg stability work and '
          'deep squats are out today; supported, long-hold hip openers are in.',
    titleFr: 'Ouverture et relâchement des hanches',
      adviceFr:
          'La tension dans les hanches est souvent due à la position assise prolongée. Nous retirons aujourd\'hui les postures d\'équilibre sur une jambe et les squats profonds ; place aux ouvertures de hanches douces et soutenues.',
      titleEs: 'Apertura y liberación de caderas',
      adviceEs:
          'La tensión en las caderas suele ser consecuencia de pasar mucho tiempo sentado. Hoy eliminamos posturas de equilibrio a una pierna y sentadillas profundas; nos enfocamos en aperturas sostenidas y suaves.',
      titleZh: '髋部舒展与放松练习',
      adviceZh:
          '髋部紧绷大多是因为久坐。今天移除了单腿平衡和深蹲体式；换成温和、有支撑且持续停留的开髋体式。',
      ),
    PainRule(
      region: BodyRegion.knee,
      keywords: [
        'diz', 'dizim', 'dizler', 'menisküs', 'meniskus', 'patella',
        'knee', 'knees', 'meniscus',
        'genou', 'genoux', 'rotule', 'menisque',
        'rodilla', 'rodillas', 'rotula', 'menisco', '膝盖', '膝', '半月板', '膝盖痛',
      ],
      safeClips: [
        Clip.gluteBridge,
        Clip.supineTwist,
        Clip.hamstringCalf,
        Clip.standingCore,
        Clip.boxBreathing,
        Clip.savasana,
      ],
      avoidClips: [
        Clip.squatCore,
        Clip.deepLunge,
        Clip.warriorI,
        Clip.warriorII,
        Clip.treePose,
        Clip.childsPose, // derin diz bükülmesi
      ],
      relatedSessionId: 'str_standing_core',
      titleTr: 'Dize yük bindirmeyen seans',
      adviceTr:
          'Diz ağrısında diz bükülmesi ve tek bacak yükü olan her şeyi '
          'çıkarıyoruz — squat, derin lunge, Warrior I, hatta Child\'s Pose. '
          'Onun yerine dizi koruyan kalça ve arka bacak çalışması var: güçlü '
          'kalça, dizi rahatlatır. Şişlik, kilitlenme veya boşalma hissi varsa '
          'egzersiz değil, muayene gerekir.',
      titleEn: 'A knee-friendly session',
      adviceEn:
          'With knee pain we drop everything that loads a bent knee — squats, deep '
          'lunges, Warrior I, even Child\'s Pose. What stays is hip and hamstring '
          'work, because strong hips unload the knee. Swelling, locking or giving '
          'way needs a clinician, not exercise.',
    titleFr: 'Séance sans charge sur les genoux',
      adviceFr:
          'En cas de douleur au genou, nous éliminons tout ce qui plie ou charge le genou (squats, fentes profondes, Guerrier I). Nous renforçons les hanches et l\'arrière des cuisses pour soulager le genou sans douleur. En cas de gonflement ou blocage, consultez un médecin.',
      titleEs: 'Sesión sin impacto en las rodillas',
      adviceEs:
          'En caso de molestia en la rodilla, eliminamos todo lo que doble o cargue la articulación (sentadillas, zancadas profundas, Guerrero I). En su lugar trabajamos caderas e isquiotibiales para proteger y descargar la rodilla. Si hay inflamación o bloqueo, consulta a un médico.',
      titleZh: '膝盖零压力温和练习',
      adviceZh:
          '膝盖不适时，我们避开所有需要弯屈承重的动作（如深蹲、深度弓步、战士一式）。改用强化髋部和后腿肌群来卸除膝盖负担。如有红肿或锁死感，请及时就医。',
      ),
    PainRule(
      region: BodyRegion.hamstring,
      keywords: [
        'bacak', 'bacağım', 'bacagim', 'arka bacak', 'baldır', 'baldir',
        'hamstring', 'calf', 'leg', 'thigh', 'uyluk',
        'jambe', 'jambes', 'cuisse', 'cuisses', 'mollet', 'mollets', 'ischio',
        'pierna', 'piernas', 'isquiotibial', 'isquiotibiales', 'gemelo', 'gemelos', 'pantorrilla', '大腿', '腿部', '腿酸', '大腿后侧', '小腿',
      ],
      safeClips: [
        Clip.downwardDog,
        Clip.hamstringCalf,
        Clip.deepLunge,
        Clip.gluteBridge,
        Clip.childsPose,
      ],
      avoidClips: [Clip.squatCore, Clip.advancedPlank],
      relatedSessionId: 'flex_hamstring_calf',
      titleTr: 'Bacak arkası ve baldır',
      adviceTr:
          'Arka bacak gerginliğinde germe hissi keskin değil, geniş ve dayanılır '
          'olmalı. Nefes verirken biraz daha derine gir, çekiştirme.',
      titleEn: 'Hamstrings and calves',
      adviceEn:
          'A hamstring stretch should feel broad and tolerable, never sharp. Sink a '
          'little deeper on each exhale rather than pulling.',
    titleFr: 'Arrière des cuisses et mollets',
      adviceFr:
          'Pour les ischio-jambiers, l\'étirement doit être agréable et progressif, jamais vif. Descendez un peu plus à chaque expiration sans forcer.',
      titleEs: 'Isquiotibiales y pantorrillas',
      adviceEs:
          'El estiramiento de la parte posterior de la pierna debe sentirse amplio y tolerable, nunca agudo. Profundiza con cada exhalación sin tirones.',
      titleZh: '大腿后侧与小腿舒展练习',
      adviceZh:
          '大腿后侧的拉伸感应当宽泛且温和，切勿出现锐痛。伴随每次呼气自然加深，切忌用力生拉硬拽。',
      ),
    PainRule(
      region: BodyRegion.wrist,
      keywords: [
        'bilek', 'el bileği', 'el bilegi', 'bileğim', 'karpal',
        'wrist', 'carpal', 'hand',
        'poignet', 'poignets', 'main', 'mains', 'canal carpien',
        'munece', 'muneca', 'muñeca', 'muñecas', 'mano', 'manos', 'tunel carpiano', '手腕', '手痛', '手腕痛', '鼠标手',
      ],
      safeClips: [
        Clip.standingCore,
        Clip.gluteBridge,
        Clip.supineTwist,
        Clip.neckShoulder,
        Clip.boxBreathing,
      ],
      avoidClips: [
        Clip.plank,
        Clip.sidePlank,
        Clip.advancedPlank,
        Clip.downwardDog,
        Clip.cobra,
        Clip.catCow,
      ],
      relatedSessionId: 'str_standing_core',
      titleTr: 'Ellerin yerde olmadığı seans',
      adviceTr:
          'El bileği ağrısında elin üzerine basılan her poz dışarıda: plank, '
          'Downward Dog, Cat-Cow, Cobra. Bugünkü seansta hiç yere el basmıyorsun.',
      titleEn: 'A session with no weight on the hands',
      adviceEn:
          'With wrist pain every hands-on-the-floor pose is out: planks, Downward '
          'Dog, Cat-Cow, Cobra. Nothing in today\'s session loads the wrist.',
    titleFr: 'Séance sans appui sur les mains',
      adviceFr:
          'En cas de douleur aux poignets, toutes les postures en appui sur les mains sont exclues (planches, Chien tête en bas, Cat-Cow, Cobra). Rien dans cette séance ne charge les poignets.',
      titleEs: 'Sesión sin apoyo en las manos',
      adviceEs:
          'Si te duelen las muñecas, eliminamos cualquier postura en la que apoyes peso en las manos (planchas, perro boca abajo, Cat-Cow, Cobra). Nada en la sesión de hoy sobrecarga tus muñecas.',
      titleZh: '手腕零支撑舒缓练习',
      adviceZh:
          '手腕不适时，所有双手撑地的姿势（平板、下犬、猫牛、眼镜蛇）全部排除。今天的练习全程不给手腕任何负担。',
      ),
    PainRule(
      region: BodyRegion.ankle,
      keywords: [
        'ayak bileği', 'ayak bilegi', 'ayak', 'topuk', 'aşil', 'asil',
        'ankle', 'foot', 'heel', 'achilles',
        'cheville', 'chevilles', 'pied', 'pieds', 'talon', 'achille',
        'tobillo', 'tobillos', 'pie', 'pies', 'talon', 'aquiles', '脚踝', '踝关节', '脚后跟', '脚底', '足跟',
      ],
      safeClips: [
        Clip.gluteBridge,
        Clip.supineTwist,
        Clip.seatedForwardBend,
        Clip.hamstringCalf,
        Clip.boxBreathing,
      ],
      avoidClips: [
        Clip.treePose,
        Clip.warriorIII,
        Clip.standingBalance,
        Clip.singleLegReach,
        Clip.warriorI,
        Clip.warriorII,
        Clip.squatCore,
      ],
      relatedSessionId: 'brt_relaxation',
      titleTr: 'Ayakta durmayan seans',
      adviceTr:
          'Ayak bileği ağrısında bugün hiç ayakta durmuyoruz — denge pozları ve '
          'ayakta güç hareketleri çıkarıldı. Yerde, yük almadan çalışıyoruz.',
      titleEn: 'A session with no standing',
      adviceEn:
          'With ankle pain we stay off the feet entirely today — balance poses and '
          'standing strength work are removed. Everything happens on the floor.',
    titleFr: 'Séance sans appui sur les pieds',
      adviceFr:
          'Pour préserver vos chevilles, nous restons totalement au sol aujourd\'hui : pas de postures d\'équilibre ni de postures debout. Tout se pratique confortablement au sol.',
      titleEs: 'Sesión sin apoyo en los pies',
      adviceEs:
          'Para cuidar los tobillos, hoy no estaremos de pie: se eliminan los equilibrios y posturas de fuerza erguidas. Todo se realiza cómodamente en el suelo.',
      titleZh: '脚踝零负重地面练习',
      adviceZh:
          '脚踝不适时，今天全程避免站立体式——平衡与站姿力量均已移除。所有动作完全在垫上地面完成。',
      ),
    PainRule(
      region: BodyRegion.stress,
      keywords: [
        'stres', 'stresli', 'kaygı', 'kaygi', 'anksiyete', 'gergin',
        'panik', 'baş ağrısı', 'bas agrisi', 'migren', 'nefes darlığı',
        'stress', 'stressed', 'anxious', 'anxiety', 'tense', 'headache',
        'overwhelmed', 'panic',
        'stress', 'angoisse', 'anxiete', 'anxieux', 'panique', 'mal de tete', 'migraine',
        'estres', 'estrés', 'ansiedad', 'ansioso', 'panico', 'dolor de cabeza', 'jaqueca', '压力', '焦虑', '烦躁', '头痛', '紧绷', '神经紧张',
      ],
      safeClips: [
        Clip.boxBreathing,
        Clip.neckShoulder,
        Clip.childsPose,
        Clip.supineTwist,
        Clip.calmReset,
        Clip.savasana,
      ],
      avoidClips: [Clip.advancedPlank, Clip.squatCore, Clip.warriorIII],
      relatedSessionId: 'brt_stress_relief',
      titleTr: 'Sinir sistemini yatıştıran seans',
      adviceTr:
          'Stresliyken yoğun bir seans genelde ters teper. Önce nefesi '
          'uzatıyoruz, sonra stresin fiziksel olarak biriktiği yeri — boyun, '
          'çene, omuz — açıyoruz. Nefes verişini alışından uzun tutmayı unutma.',
      titleEn: 'A session that settles the nervous system',
      adviceEn:
          'An intense session tends to backfire when you\'re stressed. We lengthen '
          'the breath first, then open where stress physically sits: neck, jaw, '
          'shoulders. Keep the exhale longer than the inhale.',
    titleFr: 'Séance d\'apaisement du système nerveux',
      adviceFr:
          'En période de stress, une séance intense est contre-productive. Nous allongeons d\'abord le souffle, puis nous relâchons les zones où le stress s\'accumule : cou, mâchoire, épaules. Gardez l\'expiration plus longue que l\'inspiration.',
      titleEs: 'Sesión para calmar el sistema nervioso',
      adviceEs:
          'Cuando hay estrés, una sesión intensa puede ser contraproducente. Primero alargamos la respiración y luego liberamos donde se acumula la tensión física: cuello, mandíbula, hombros. Recuerda que la exhalación debe ser más larga que la inhalación.',
      titleZh: '舒缓神经系统减压练习',
      adviceZh:
          '压力过大时进行高强度练习往往适得其反。我们先拉长呼吸，再化解身体积聚紧张的部位：颈部、下颌、肩膀。请保持呼气比吸气更长。',
      ),
    PainRule(
      region: BodyRegion.sleep,
      keywords: [
        'uyku', 'uyuyamıyorum', 'uyuyamiyorum', 'uykusuz', 'insomnia',
        'sleep', 'cant sleep', "can't sleep", 'restless',
        'sommeil', 'insomnie', 'dors pas', 'dort pas', 'endormir', 'nuit',
        'sueno', 'sueño', 'insomnio', 'no puedo dormir', 'dormir', 'noche', '失眠', '睡不着', '助眠', '睡眠差', '入睡困难',
      ],
      safeClips: [
        Clip.hipOpener,
        Clip.supineTwist,
        Clip.childsPose,
        Clip.boxBreathing,
        Clip.calmReset,
        Clip.savasana,
      ],
      avoidClips: [
        Clip.advancedPlank,
        Clip.squatCore,
        Clip.warriorI,
        Clip.warriorII,
        Clip.warriorIII,
        Clip.plank,
      ],
      relatedSessionId: 'brt_deep_sleep',
      titleTr: 'Uykuya geçiş seansı',
      adviceTr:
          'Yatmadan önceki seans uyandırmamalı. Tamamen yerde, ışıklar kısık, '
          'hepsi uzun tutuşlarla. Savasana\'da uyuyakalmak sorun değil — amaç bu.',
      titleEn: 'A wind-down for sleep',
      adviceEn:
          'A pre-bed session shouldn\'t wake you up. All floor-based, lights low, '
          'long holds. Falling asleep in Savasana is not a failure — it\'s the point.',
    titleFr: 'Séance détente avant le sommeil',
      adviceFr:
          'Une pratique du soir doit apaiser le corps. Entièrement au sol, lumières tamisées, respirations lentes. S\'endormir pendant le Savasana n\'est pas un échec, c\'est le but.',
      titleEs: 'Sesión de relajación para dormir',
      adviceEs:
          'Una práctica antes de acostarse no debe activarte. Todo en el suelo, luces tenues y respiraciones lentas. Quedarse dormido en Savasana no es un fallo: es el objetivo.',
      titleZh: '睡前舒眠放松练习',
      adviceZh:
          '睡前的练习不应唤醒精力。全程地面练习、调暗灯光、深长保持。在仰卧挺尸式中安然入睡并非意外——这正是我们的目的。',
      ),
    PainRule(
      region: BodyRegion.menstrual,
      keywords: [
        'regl', 'adet', 'kramp', 'sancı', 'sanci', 'periyot',
        'period', 'cramps', 'menstrual', 'pms',
        'regles', 'regle', 'crampes', 'menstruel', 'bas-ventre',
        'regla', 'menstruacion', 'menstruación', 'colicos', 'cólicos', 'periodo', '经期', '大姨妈', '痛经', '生理期', '痛经缓解',
      ],
      safeClips: [
        Clip.childsPose,
        Clip.supineTwist,
        Clip.hipOpener,
        Clip.catCow,
        Clip.boxBreathing,
        Clip.savasana,
      ],
      avoidClips: [
        Clip.plank,
        Clip.sidePlank,
        Clip.advancedPlank,
        Clip.squatCore,
        Clip.warriorIII,
        Clip.standingCore,
      ],
      relatedSessionId: 'brt_relaxation',
      titleTr: 'Kramp günleri için yumuşak seans',
      adviceTr:
          'Bugün karın merkezini çalıştıran hiçbir hareket yok. Alt karnı ve '
          'kalçayı açan, sıcak ve destekli tutuşlar var. Yoğunluğu kendine göre '
          'ayarla; bugün "az" da yeterli.',
      titleEn: 'A soft session for cramp days',
      adviceEn:
          'Nothing that engages the abdominal core today. Warm, supported holds '
          'that open the low belly and hips instead. Less is genuinely enough today.',
    titleFr: 'Séance douce pour les crampes',
      adviceFr:
          'Aucun travail des abdominaux aujourd\'hui. Nous privilégions des postures chaudes et soutenues pour détendre le bas-ventre et le bassin. Écoutez votre corps : la douceur suffit amplement.',
      titleEs: 'Sesión suave para días de cólicos',
      adviceEs:
          'Hoy no hay movimientos que activen el abdomen. En su lugar, posturas cálidas y sostenidas que relajan el bajo vientre y la pelvis. La suavidad es más que suficiente hoy.',
      titleZh: '生理期舒缓温和练习',
      adviceZh:
          '今天不做任何强化腹部核心的动作。以温和舒展、有支撑的姿势放松小腹与骨盆。今天对自己多一点温柔。',
      ),
    PainRule(
      region: BodyRegion.fatigue,
      keywords: [
        'yorgun', 'yorgunum', 'bitkin', 'halsiz', 'enerjim yok', 'bitkinim',
        'tired', 'exhausted', 'fatigued', 'no energy', 'drained',
        'fatigue', 'fatiguee', 'fatigue', 'epuise', 'epuisee', 'epuise', 'pas d\'energie',
        'cansado', 'cansada', 'fatiga', 'agotado', 'agotada', 'sin energia', '累', '疲劳', '好累', '乏力', '无精打采', '精力透支',
      ],
      safeClips: [
        Clip.catCow,
        Clip.neckShoulder,
        Clip.childsPose,
        Clip.boxBreathing,
        Clip.savasana,
      ],
      avoidClips: [Clip.advancedPlank, Clip.squatCore, Clip.warriorIII],
      relatedSessionId: 'brt_calm_reset',
      titleTr: 'Yorgun günün kısa seansı',
      adviceTr:
          'Yorgunken hedef antrenman değil, seriyi kırmamak. Beş dakika ve '
          'birkaç nefes, atlanan bir günden her zaman iyidir.',
      titleEn: 'A short session for a tired day',
      adviceEn:
          'When you\'re tired the goal isn\'t training, it\'s not breaking the '
          'chain. Five minutes beats a skipped day, every time.',
    titleFr: 'Séance courte pour les jours de fatigue',
      adviceFr:
          'Quand vous êtes fatigué, le but n\'est pas la performance mais de maintenir votre habitude. Cinq minutes et quelques respirations valent toujours mieux qu\'un jour sauté.',
      titleEs: 'Sesión corta para días de cansancio',
      adviceEs:
          'Cuando estás cansado, el objetivo no es entrenar duro, sino mantener el hábito. Cinco minutos y unas cuantas respiraciones siempre superan a un día saltado.',
      titleZh: '疲劳日的五分钟轻松微练习',
      adviceZh:
          '疲惫不堪时，目标不是体能训练，而是不间断连续习惯。五分钟与几次深呼吸，永远胜过彻底放弃一天。',
      ),
  ];

  static PainRule? forRegion(BodyRegion region) {
    for (final r in all) {
      if (r.region == region) return r;
    }
    return null;
  }
}

/// Bir serbest metinden bölge çıkarımı ve güvenlik ön elemesi.
abstract class PainTriage {
  PainTriage._();

  /// Egzersiz önerisi ÜRETİLMEMESİ gereken durumlar. Bunlar yakalandığında
  /// uygulama plan sunmaz, kişiyi sağlık profesyoneline yönlendirir.
  static const List<String> _redFlags = [
    'kırık', 'kirik', 'çatlak', 'catlak', 'fıtık', 'fitik', 'ameliyat',
    'düştüm', 'dustum', 'uyuşma', 'uyusma', 'karıncalanma', 'karincalanma',
    'felç', 'felc', 'göğüs ağrısı', 'gogus agrisi', 'bayıl', 'bayil',
    'hamile', 'gebe', 'kanama', 'ateşim', 'atesim', 'şişlik', 'sislik',
    'fracture', 'herniated', 'herniation', 'surgery', 'numbness',
    'tingling', 'chest pain', 'fainting', 'pregnant', 'pregnancy',
    'bleeding', 'dislocated', 'torn',
    'operation', 'chirurgie', 'engourdissement', 'fourmillement', 'enceinte',
    'grossesse', 'douleur thoracique', 'evanouissement', 'saignement',
    'fractura', 'cirugia', 'adormecimiento', 'hormigueo', 'embarazada',
    'embarazo', 'desmayo', 'hemorragia', 'dolor en el pecho',
    '骨折', '手术', '麻木', '刺痛', '怀孕', '孕妇', '胸痛', '晕厥', '流血', '脱臼',
  ];

  static bool hasRedFlag(String text) {
    final t = _normalize(text);
    return _redFlags.any((f) => t.contains(_normalize(f)));
  }

  static const String redFlagAdviceTr =
      'Anlattığın belirti (uyuşma, yakın zamanlı yaralanma, ameliyat, gebelik '
      'ya da benzeri bir durum) yoga akışıyla çözülecek bir şey değil ve yanlış '
      'hareket işi kötüleştirebilir. Bugün sana bir seans önermeyeceğim — bunu '
      'bir hekim ya da fizyoterapistle değerlendirmen daha doğru olur. Onay '
      'aldıktan sonra buradan yumuşak bir başlangıç kurgulayabiliriz.';

  static const String redFlagAdviceEn =
      'What you\'re describing (numbness, a recent injury, surgery, pregnancy or '
      'similar) isn\'t something a yoga flow should be used to solve, and the '
      'wrong movement could make it worse. I won\'t suggest a session today — '
      'please have it looked at by a doctor or physiotherapist first. Once you\'re '
      'cleared, we can build a gentle way back in.';

  static const String redFlagAdviceFr =
      'Ce que vous décrivez (engourdissement, blessure récente, chirurgie, '
      'grossesse ou douleur aiguë) ne doit pas être traité par une séance de '
      'yoga et un mauvais mouvement pourrait aggraver la situation. Je ne '
      'vous proposerai pas de séance aujourd\'hui : consultez d\'abord un '
      'médecin ou un spécialiste. Une fois le feu vert obtenu, nous pourrons '
      'reprendre en douceur.';

  static const String redFlagAdviceEs =
      'Lo que describes (entumecimiento, lesión reciente, cirugía, embarazo '
      'o dolor agudo) no debe tratarse con una sesión de yoga y un movimiento '
      'inadecuado podría empeorarlo. Hoy no te recomendaré una sesión: por '
      'favor consulta primero con un médico o especialista. Una vez te den el '
      'visto bueno, podremos retomar en calma.';

  static const String redFlagAdviceZh =
      '您所描述的症状（麻木感、近期受伤、术后、妊娠或剧烈疼痛）不适合通过'
      '瑜伽体式来处理，不当活动可能会加重情况。今天不会为您推荐练习方案——'
      '请先咨询专业医生或物理治疗师。获得医疗许可后，我们再开始温和恢复。';

  static String localizedRedFlagAdvice(String langCode) {
    if (langCode.startsWith('tr')) return redFlagAdviceTr;
    if (langCode.startsWith('fr')) return redFlagAdviceFr;
    if (langCode.startsWith('es')) return redFlagAdviceEs;
    if (langCode.startsWith('zh')) return redFlagAdviceZh;
    return redFlagAdviceEn;
  }

  /// Metinde geçen ilk (en spesifik) bölgeyi bulur. Bulamazsa null.
  ///
  /// Kelimeler uzunluğa göre sıralanır ki "ayak bileği" → ankle olarak
  /// yakalansın, sadece "ayak" ile karışmasın.
  static BodyRegion? detectRegion(String text) {
    final t = _normalize(text);
    BodyRegion? best;
    int bestLength = 0;

    for (final rule in PainRules.all) {
      for (final kw in rule.keywords) {
        final k = _normalize(kw);
        if (k.isEmpty) continue;
        if (t.contains(k) && k.length > bestLength) {
          best = rule.region;
          bestLength = k.length;
        }
      }
    }
    return best;
  }

  /// Metnin bir ağrı/şikâyet bildirimi olup olmadığı — Coach sohbetinde
  /// "bugün ne yapsam?" ile "belim ağrıyor"u ayırmak için.
  static bool looksLikeComplaint(String text) {
    final t = _normalize(text);
    const markers = [
      'agri', 'aci', 'sizi', 'tutul', 'kasil', 'gergin', 'sert', 'rahatsiz',
      'yorgun', 'stres', 'uyuyam', 'kramp', 'incin', 'zorlan',
      'pain', 'hurt', 'ache', 'sore', 'stiff', 'tight', 'tense',
      'tired', 'stress', 'cramp', 'discomfort',
      'mal', 'douleur', 'raide', 'tendu', 'fatigue', 'blesse', 'bloque',
      'dolor', 'duele', 'molestia', 'rigido', 'tenso', 'cansado', 'lesion',
      '痛', '疼', '酸', '僵硬', '紧绷', '难受', '疲劳', '累', '伤', '抽筋',
    ];
    return markers.any(t.contains);
  }

  /// Türkçe karakterleri sadeleştirir ve küçük harfe indirir; "Belim
  /// ağrıyor", "belim agriyor" ve "BELİM AĞRIYOR" aynı sonucu verir.
  static String _normalize(String s) {
    var t = s.toLowerCase();
    const map = {
      'ı': 'i', 'İ': 'i', 'ş': 's', 'Ş': 's', 'ğ': 'g', 'Ğ': 'g',
      'ü': 'u', 'Ü': 'u', 'ö': 'o', 'Ö': 'o', 'ç': 'c', 'Ç': 'c',
      'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'à': 'a', 'â': 'a',
      'ù': 'u', 'û': 'u', 'ô': 'o', 'î': 'i', 'ï': 'i',
      'á': 'a', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ñ': 'n',
    };
    map.forEach((k, v) => t = t.replaceAll(k, v));
    return t;
  }
}
