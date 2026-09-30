import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/practice_catalog.dart';
import '../../core/constants/supabase_config.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/entities/workout_entity.dart';
import '../../domain/repositories/i_exercise_repository.dart';
import '../../domain/usecases/workout/session_resolver.dart';

class ExerciseRepositoryImpl implements IExerciseRepository {
  // Mock data
  final List<ExerciseEntity> _mockExercises = const [
    ExerciseEntity(
      id: 'ex-cobra',
      name: 'Cobra Pose',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 45,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Back', 'Chest'],
      tags: ['Flexibility', 'Warmup'],
      instructions:
          'Lie on your stomach, place hands under shoulders, and gently lift your chest off the floor.',
      commonMistakes:
          'Pushing up with your arms instead of using your back muscles.',
      videoUrl: 'assets/videos/cobra_pose.mp4',
    ),
    ExerciseEntity(
      id: 'ex-hamstring',
      name: 'Hamstring & Calf Stretch',
      category: 'Stretching',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Hamstrings', 'Calves', 'Legs'],
      tags: ['Flexibility', 'Stretching'],
      instructions:
          'Extend one leg and gently fold forward to stretch the hamstring and calf. Switch sides halfway.',
      commonMistakes: 'Rounding your lower back aggressively.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/hamstring_calf_stretch_left.mp4,https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/hamstring_calf_stretch_right.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/stretch_hamstrings_audio.mp3',
    ),
    ExerciseEntity(
      id: 'ex-deep-lunge',
      name: 'Deep Lunge Stretch',
      category: 'Stretching',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Hips', 'Quads', 'Groin', 'Hamstrings'],
      tags: ['Flexibility', 'Mobility', 'Stretching'],
      instructions:
          'Step one foot forward into a deep lunge, sink your hips low while keeping your chest lifted.',
      commonMistakes: 'Collapsing your chest forward or letting the front knee pass beyond your toes.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/deep_lunge_stretch.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/deep_lunge_stretch.mp3',
    ),
    ExerciseEntity(
      id: 'ex-standing-core',
      name: 'Standing Core Activation',
      category: 'Pilates',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'No Equipment',
      targetAreas: ['Core', 'Abs', 'Posture', 'Lower Back'],
      tags: ['Core', 'Strength', 'Posture'],
      instructions:
          'Stand tall with feet hip-width apart. Engage your core by drawing your navel inward and upward while maintaining steady breath.',
      commonMistakes: 'Holding your breath or arching your lower back.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/standing_core_activation.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/standing_core_activation.mp3',
    ),
    ExerciseEntity(
      id: 'ex-squat-core',
      name: 'Squat & Core Combo',
      category: 'Pilates',
      difficulty: Difficulty.intermediate,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'No Equipment',
      targetAreas: ['Quads', 'Glutes', 'Core', 'Hamstrings'],
      tags: ['Strength', 'Core', 'Lower Body'],
      instructions:
          'Stand with feet shoulder-width apart. Lower into a squat keeping your chest lifted and core braced, then rise back up with your breath.',
      commonMistakes: 'Letting knees cave inward or rounding the lower back.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/squat_core_combo.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/squat_core_combo.mp3',
    ),
    ExerciseEntity(
      id: 'ex-side-plank',
      name: 'Side Plank Series',
      category: 'Pilates',
      difficulty: Difficulty.intermediate,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Obliques', 'Core', 'Shoulders', 'Glutes'],
      tags: ['Core', 'Strength', 'Balance'],
      instructions:
          'Lie on your side, prop up on your forearm, and lift hips into a straight line. Repeat on the other side.',
      commonMistakes: 'Sagging the hips or collapsing into the supporting shoulder.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/plank_side_final.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/plank_side.mp3',
    ),
    ExerciseEntity(
      id: 'ex-1',
      name: 'Cat-Cow Stretch',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 10,
      equipment: 'Yoga Mat',
      targetAreas: ['Back', 'Core'],
      tags: ['Warmup', 'Mobility'],
      instructions:
          'Start on all fours. Arch your back up (Cat), then dip it down (Cow).',
      commonMistakes: 'Rushing the movement.',
    ),
    ExerciseEntity(
      id: 'ex-2',
      name: 'Downward Facing Dog',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 45,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Hamstrings', 'Shoulders'],
      tags: ['Flexibility'],
      instructions: 'Push hips up and back, pressing heels toward the floor.',
      commonMistakes: 'Rounding the upper back.',
    ),
    ExerciseEntity(
      id: 'ex-3',
      name: 'Child\'s Pose',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 10,
      equipment: 'Yoga Mat',
      targetAreas: ['Back', 'Hips'],
      tags: ['Cooldown', 'Relaxation'],
      instructions: 'Sit back on your heels and stretch arms forward.',
      commonMistakes: 'Holding tension in the neck.',
    ),
    ExerciseEntity(
      id: 'ex-4',
      name: 'Plank',
      category: 'Pilates',
      difficulty: Difficulty.intermediate,
      durationSeconds: 45,
      restSeconds: 15,
      equipment: 'No Equipment',
      targetAreas: ['Core', 'Shoulders'],
      tags: ['Strength'],
      instructions: 'Hold your body in a straight line from head to heels.',
      commonMistakes: 'Dropping the hips.',
    ),
    ExerciseEntity(
      id: 'ex-5',
      name: 'Glute Bridge Series',
      category: 'Pilates',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'No Equipment',
      targetAreas: ['Glutes', 'Core', 'Hamstrings'],
      tags: ['Strength', 'Activation'],
      instructions: 'Lie on back, bend knees, lift hips towards the ceiling while squeezing glutes.',
      commonMistakes: 'Arching the lower back instead of squeezing glutes.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/glute_bridge.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/glute_bridge_series.mp3',
    ),
    ExerciseEntity(
      id: 'ex-warrior-3',
      name: 'Warrior III Hold',
      category: 'Yoga',
      difficulty: Difficulty.intermediate,
      durationSeconds: 45,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Glutes', 'Hamstrings', 'Core', 'Ankles'],
      tags: ['Balance', 'Strength'],
      instructions:
          'Stand on one leg, hinge forward at your hips, extend the opposite leg back parallel to the floor, and reach your arms forward while maintaining balance.',
      commonMistakes: 'Opening the hips to the side or hyperextending the standing knee.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/warrior_III_hold.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/warrior_III.mp3',
      skillWeights: {'balance': 0.7, 'strength': 0.3},
    ),
    ExerciseEntity(
      id: 'ex-tree-pose',
      name: 'Tree Pose Progression',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 10,
      equipment: 'Yoga Mat',
      targetAreas: ['Hips', 'Ankles', 'Core', 'Calves'],
      tags: ['Balance', 'Focus'],
      instructions:
          'Shift your weight onto one leg. Place the sole of the opposite foot on your inner calf or inner thigh (never on the knee). Bring your hands to heart center or reach overhead.',
      commonMistakes: 'Pressing the foot against the knee joint.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/tree_pose_progression.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/tree_pose.mp3',
      skillWeights: {'balance': 0.8, 'flexibility': 0.2},
    ),
    ExerciseEntity(
      id: 'ex-standing-balance',
      name: 'Standing Balance Basics',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 10,
      equipment: 'Yoga Mat',
      targetAreas: ['Ankles', 'Feet', 'Core', 'Posture'],
      tags: ['Balance', 'Foundation'],
      instructions:
          'Root firmly through all four corners of your feet. Engage your core, fix your gaze on an unmoving point, and practice weight distribution and steady breathing.',
      commonMistakes: 'Looking around or holding your breath.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/standing_balance_basics.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/standing_balance_basics.mp3',
      skillWeights: {'balance': 0.7, 'strength': 0.3},
    ),
    ExerciseEntity(
      id: 'ex-single-leg-reach',
      name: 'Single Leg Reach',
      category: 'Yoga',
      difficulty: Difficulty.intermediate,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Hamstrings', 'Glutes', 'Core', 'Ankles'],
      tags: ['Balance', 'Mobility', 'Strength'],
      instructions:
          'Stand on one leg with a soft knee. Hinge at your hips to reach your hands forward while reaching your opposite leg straight back. Engage your core and return to standing with control.',
      commonMistakes: 'Arching the lower back or locking the supporting knee.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/single_leg_reach.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/single_leg_reach.mp3',
      skillWeights: {'balance': 0.6, 'strength': 0.4},
    ),
    ExerciseEntity(
      id: 'ex-box-breathing',
      name: 'Box Breathing',
      category: 'Breathing',
      difficulty: Difficulty.beginner,
      durationSeconds: 90,
      restSeconds: 5,
      equipment: 'No Equipment',
      targetAreas: ['Diaphragm', 'Lungs', 'Mind'],
      tags: ['Breathing', 'Calm', 'Focus'],
      instructions:
          'Inhale slowly through the nose for 4 counts, hold your breath for 4 counts, exhale smoothly through the mouth for 4 counts, and hold empty for 4 counts. Repeat with mindful rhythm.',
      commonMistakes: 'Gasping for air or tensing the shoulders during the breath hold.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/box_breathing.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/box_breathing.mp3',
      skillWeights: {'breath': 1.0},
    ),
    ExerciseEntity(
      id: 'ex-calm-reset',
      name: '5-Minute Calm Reset',
      category: 'Breathing',
      difficulty: Difficulty.beginner,
      durationSeconds: 300,
      restSeconds: 0,
      equipment: 'No Equipment',
      targetAreas: ['Mind', 'Diaphragm', 'Nervous System'],
      tags: ['Meditation', 'Calm', 'Relaxation'],
      instructions:
          'Find a comfortable seated or lying position. Close your eyes, listen closely to the guidance, and let your body release accumulated tension over five minutes of gentle reset.',
      commonMistakes: 'Trying to force relaxation or breathing too rapidly.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/5_minute_calm_reset.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/5_minute_calm_reset.mp3',
      skillWeights: {'breath': 1.0},
    ),
    ExerciseEntity(
      id: 'ex-adv-plank',
      name: 'Advanced Plank Challenge',
      category: 'Pilates',
      difficulty: Difficulty.advanced,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'No Equipment',
      targetAreas: ['Core', 'Shoulders', 'Abs', 'Glutes'],
      tags: ['Strength', 'Core', 'Challenge'],
      instructions:
          'Set up in a strong high or forearm plank. Keep your shoulders aligned, drive through your heels, brace your core firmly, and sustain the hold with steady breath through the challenge.',
      commonMistakes: 'Sagging the lower back, raising hips excessively, or holding your breath.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/advanced_plank_challange.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/advanced_plank_challange.mp3',
      skillWeights: {'strength': 0.8, 'balance': 0.2},
    ),
    ExerciseEntity(
      id: 'ex-hip-opener',
      name: 'Hip Opener Basics',
      category: 'Stretching',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Hips', 'Glutes', 'Pelvis', 'Hamstrings'],
      tags: ['Flexibility', 'Mobility', 'Hips'],
      instructions:
          'Position yourself comfortably and sink gently into the hip opening stretch. Maintain deep, relaxed breaths. Switch sides halfway through to balance both hips.',
      commonMistakes: 'Forcing the knee down or arching the lower back.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/hip_opener_basics_left.mp4,https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/hip_opener_basics_right.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/hip_opener_basics.mp3',
      skillWeights: {'flexibility': 0.9, 'balance': 0.1},
    ),
    ExerciseEntity(
      id: 'ex-warrior-2',
      name: 'Warrior II',
      category: 'Yoga',
      difficulty: Difficulty.beginner,
      durationSeconds: 60,
      restSeconds: 15,
      equipment: 'Yoga Mat',
      targetAreas: ['Legs', 'Hips', 'Core', 'Shoulders'],
      tags: ['Strength', 'Focus', 'Standing'],
      instructions:
          'Step your feet wide apart. Turn right foot out 90 degrees, bend the right knee over the ankle, and extend your arms parallel to the floor with gaze forward. Switch to the left side halfway.',
      commonMistakes: 'Leaning forward past the hips or letting the front knee collapse inward.',
      videoUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/wariior_2_right.mp4,https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/warrior_2_left.mp4',
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/warrior_2.mp3',
      skillWeights: {'strength': 0.6, 'balance': 0.4},
    ),
  ];

  @override
  Future<Result<List<ExerciseEntity>>> getAllExercises() async {
    if (SupabaseConfig.isConfigured) {
      try {
        final data = await Supabase.instance.client.from('exercises').select();
        final list = data.map((e) => _mapExercise(e)).toList();
        if (list.isNotEmpty) {
          return Success(list);
        }
      } catch (e) {
        debugPrint('getAllExercises Supabase error, falling back to mock: $e');
      }
    }
    return Success(_mockExercises);
  }

  ExerciseEntity _mapExercise(Map<String, dynamic> data) {
    return ExerciseEntity(
      id: data['id'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'Yoga',
      difficulty: Difficulty.values.firstWhere(
        (e) =>
            e.name.toLowerCase() ==
            (data['difficulty'] as String? ?? 'beginner').toLowerCase(),
        orElse: () => Difficulty.beginner,
      ),
      durationSeconds: data['duration_seconds'] as int? ?? 60,
      restSeconds: data['rest_seconds'] as int? ?? 10,
      equipment: 'No Equipment',
      targetAreas: List<String>.from(data['muscle_groups'] ?? []),
      tags: [],
      instructions: data['instructions'] as String? ?? '',
      commonMistakes: '',
      videoUrl: data['video_url'] as String?,
      audioUrl: data['audio_url'] as String?,
      // Optional Supabase column — safe to leave unset on existing rows;
      // ExerciseEntity.effectiveSkillWeights falls back to a
      // category-based default when this is empty.
      skillWeights: (data['skill_weights'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          const {},
    );
  }

  @override
  Future<Result<ExerciseEntity>> getExerciseById(String id) async {
    if (SupabaseConfig.isConfigured) {
      try {
        final data = await Supabase.instance.client
            .from('exercises')
            .select()
            .eq('id', id)
            .maybeSingle();
        if (data != null) {
          return Success(_mapExercise(data));
        }
      } catch (e) {
        debugPrint('getExerciseById Supabase error, falling back to mock: $e');
      }
    }
    try {
      final ex = _mockExercises.firstWhere((e) => e.id == id);
      return Success(ex);
    } catch (_) {
      return const Failure('Exercise not found');
    }
  }

  @override
  Future<Result<List<ExerciseEntity>>> getExercisesByDifficulty(
      Difficulty difficulty) async {
    if (SupabaseConfig.isConfigured) {
      try {
        final data = await Supabase.instance.client
            .from('exercises')
            .select()
            .ilike('difficulty', difficulty.name);
        final list = data.map((e) => _mapExercise(e)).toList();
        if (list.isNotEmpty) {
          return Success(list);
        }
      } catch (e) {
        debugPrint('getExercisesByDifficulty Supabase error, falling back to mock: $e');
      }
    }
    final list =
        _mockExercises.where((e) => e.difficulty == difficulty).toList();
    return Success(list.isNotEmpty ? list : _mockExercises);
  }

  @override
  Future<Result<WorkoutEntity>> getTodayWorkout({
    required Difficulty difficulty,
    required int durationMinutes,
    required List<String> goals,
  }) async {
    if (SupabaseConfig.isConfigured) {
      try {
        // Just fetch random exercises for today's workout matching the difficulty
        final data = await Supabase.instance.client
            .from('exercises')
            .select()
            .ilike('difficulty', difficulty.name)
            .limit(4);
        final exs = data.map((e) => _mapExercise(e)).toList();

        if (exs.isNotEmpty) {
          final workoutExs = exs.asMap().entries.map((e) {
            return WorkoutExerciseEntity(
              id: 'we_${e.key}',
              exerciseId: e.value.id,
              orderIndex: e.key,
              exercise: e.value,
            );
          }).toList();

          final workout = WorkoutEntity(
            id: 'w_today',
            name: 'Daily Flow',
            description: 'A customized session based on your goals.',
            estimatedMinutes: durationMinutes,
            difficulty: difficulty,
            category: 'Hybrid',
            exercises: workoutExs,
          );
          return Success(workout);
        }
      } catch (e) {
        debugPrint('getTodayWorkout Supabase error, falling back to mock: $e');
      }
    }

    // Create a mock workout based on the duration
    // For simplicity, we just take 3-5 exercises
    final workoutExs = _mockExercises.take(4).toList().asMap().entries.map((e) {
      return WorkoutExerciseEntity(
        id: 'mock_${e.key}',
        exerciseId: e.value.id,
        orderIndex: e.key,
        exercise: e.value,
      );
    }).toList();

    final workout = WorkoutEntity(
      id: 'w_today',
      name: 'Daily Flow & Core',
      description:
          'A customized session balancing flexibility and core strength based on your goals.',
      estimatedMinutes: durationMinutes,
      difficulty: difficulty,
      category: 'Hybrid',
      exercises: workoutExs,
    );

    return Success(workout);
  }

  @override
  Future<Result<WorkoutEntity>> getWorkoutById(String id) async {
    final decodedId = Uri.decodeComponent(id);

    // ── Katalog seansları ────────────────────────────────────────
    // "session:<id>" biçimindeki kimlikler PracticeCatalog'daki isimli
    // seanslara karşılık gelir (Morning Mobility Wake-Up, Core Strength
    // Flow, ...). Bu, ana ekrandaki "Bugünün Pratiği" kartından, seans
    // listelerinden ve derin bağlantılardan gelen tek yoldur — böylece
    // aşağıdaki eski isim-eşleştirme switch'ine hiç düşülmez.
    if (decodedId.startsWith('session:')) {
      final session =
          PracticeCatalog.byId(decodedId.substring('session:'.length));
      if (session != null) {
        final poolRes = await getAllExercises();
        final pool = (poolRes.isSuccess && (poolRes.dataOrNull?.isNotEmpty ?? false))
            ? poolRes.dataOrNull!
            : _mockExercises;
        final workout = SessionResolver.build(session: session, pool: pool);
        if (workout != null) return Success(workout);
      }
    }

    if (id == 'w_morning_stretch') {
      final targetExerciseNames = [
        'Child\'s Pose',
        'Cat-Cow Stretch',
        'Cobra Pose',
        'Seated Forward Bend',
        'Supine Spinal Twist',
        'Savasana'
      ];

      List<ExerciseEntity> dbExercises = [];
      if (SupabaseConfig.isConfigured) {
        try {
          final data =
              await Supabase.instance.client.from('exercises').select();
          dbExercises = data.map((e) => _mapExercise(e)).toList();
        } catch (_) {}
      }

      final exercises = targetExerciseNames.map((name) {
        // 1. Try to find in DB (to get video URL if exists). Match by first word to be safe.
        final searchWord = name.split(' ').first.toLowerCase();
        try {
          return dbExercises
              .firstWhere((e) => e.name.toLowerCase().contains(searchWord));
        } catch (_) {}

        // 2. Try to find in mock data
        try {
          return _mockExercises
              .firstWhere((e) => e.name.toLowerCase().contains(searchWord));
        } catch (_) {}

        // 3. Create dummy if not found anywhere
        return ExerciseEntity(
          id: "dummy_${name.replaceAll(' ', '_')}",
          name: name,
          category: 'Stretching',
          difficulty: Difficulty.beginner,
          durationSeconds: 120, // 2 mins as per UI
          restSeconds: 10,
          equipment: 'Yoga Mat',
          targetAreas: [],
          tags: [],
          instructions: 'Follow the pose instructions carefully.',
          commonMistakes: '',
        );
      }).toList();

      final workoutExs = exercises.asMap().entries.map((e) {
        return WorkoutExerciseEntity(
          id: 'we_${e.key}',
          exerciseId: e.value.id,
          orderIndex: e.key,
          exercise: e.value,
        );
      }).toList();

      return Success(WorkoutEntity(
        id: id,
        name: 'Morning Stretch',
        description: 'Start your day right with this relaxing stretch routine.',
        estimatedMinutes: 12,
        difficulty: Difficulty.beginner,
        category: 'Stretching',
        exercises: workoutExs,
      ));
    }

    // We will build a specific sequence of exercises based on the workout title or exercise list
    List<String> targetExerciseNames = [];
    String workoutTitle = decodedId;

    if (decodedId.contains('|')) {
      final parts = decodedId.split('|');
      if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
        workoutTitle = parts[0].trim();
      }
      if (parts.length > 1 && parts[1].contains(',')) {
        targetExerciseNames = parts[1]
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else if (parts.length > 1 && parts[1].trim().isNotEmpty) {
        targetExerciseNames = [parts[1].trim()];
      }
    }

    if (targetExerciseNames.isEmpty) {
      switch (workoutTitle) {
        case "Child's Pose & Cat-Cow":
          targetExerciseNames = ["Child's Pose", "Cat-Cow Stretch"];
          break;
        case "Hamstring & Calf Stretch":
        case "Hamstring Stretch":
        case "hamstring_calf_stretch":
          targetExerciseNames = ["Hamstring & Calf Stretch", "Child's Pose"];
          break;
        case "Seated Forward Bend":
          targetExerciseNames = ["Seated Forward Bend", "Savasana"];
          break;
        case "Basic Plank":
          targetExerciseNames = ["Plank", "Child's Pose"];
          break;
        case "Warrior I Flow":
          targetExerciseNames = ["Warrior I", "Downward Facing Dog", "Cobra Pose"];
          break;
        case "Warrior II Flow":
        case "Warrior II":
          targetExerciseNames = ["Warrior II", "Warrior I", "Child's Pose"];
          break;
        case "Supine Spinal Twist":
          targetExerciseNames = ["Supine Spinal Twist", "Savasana"];
          break;
        case "Downward Dog Series":
          targetExerciseNames = ["Downward Facing Dog", "Plank", "Cobra Pose"];
          break;
        case "Deep Lunge Stretch":
        case "deep_lunge_stretch":
          targetExerciseNames = ["Deep Lunge Stretch", "Child's Pose"];
          break;
        case "Standing Core Activation":
        case "standing_core_activation":
          targetExerciseNames = ["Standing Core Activation", "Plank"];
          break;
        case "Glute Bridge Series":
        case "Glute Bridge":
        case "glute_bridge_series":
          targetExerciseNames = ["Glute Bridge Series", "Plank"];
          break;
        case "Squat & Core Combo":
        case "squat_core_combo":
          targetExerciseNames = ["Squat & Core Combo", "Standing Core Activation"];
          break;
        case "Side Plank Series":
        case "side_plank_series":
        case "Side Plank":
          targetExerciseNames = ["Side Plank Series", "Plank"];
          break;
        default:
          if (decodedId.contains(',')) {
            targetExerciseNames = decodedId
                .split(',')
                .map((s) => s.trim())
                .where((s) => s.isNotEmpty)
                .toList();
            workoutTitle = "Daily Practice";
          } else {
            // Fallback to searching the first word
            targetExerciseNames = [decodedId.split(' ').first];
          }
          break;
      }
    }

    try {
      List<ExerciseEntity> availableExs = [];
      if (SupabaseConfig.isConfigured) {
        try {
          final data = await Supabase.instance.client.from('exercises').select();
          availableExs = data.map((e) => _mapExercise(e)).toList();
        } catch (_) {}
      }
      if (availableExs.isEmpty) {
        availableExs = _mockExercises;
      }

      final sequence = <WorkoutExerciseEntity>[];
      for (int i = 0; i < targetExerciseNames.length; i++) {
        final targetName = targetExerciseNames[i].toLowerCase();
        ExerciseEntity? ex;
        
        try {
          ex = availableExs.firstWhere((e) =>
              e.name.toLowerCase() == targetName ||
              e.name.toLowerCase().contains(targetName) ||
              targetName.contains(e.name.toLowerCase()));
        } catch (_) {}

        if (ex == null) {
          // Dummy fallback
          ex = ExerciseEntity(
            id: "dummy_${targetName.replaceAll(' ', '_')}",
            name: targetExerciseNames[i],
            category: 'Yoga',
            difficulty: Difficulty.intermediate,
            durationSeconds: 60,
            restSeconds: 10,
            equipment: 'Yoga Mat',
            targetAreas: [],
            tags: [],
            instructions: 'Follow the pose instructions carefully.',
            commonMistakes: '',
            videoUrl: 'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/savasana.mp4',
          );
        } else if (ex.videoUrl == null) {
          ex = ExerciseEntity(
            id: ex.id,
            name: ex.name,
            category: ex.category,
            difficulty: ex.difficulty,
            durationSeconds: ex.durationSeconds,
            reps: ex.reps,
            sets: ex.sets,
            restSeconds: ex.restSeconds,
            equipment: ex.equipment,
            targetAreas: ex.targetAreas,
            tags: ex.tags,
            instructions: ex.instructions,
            commonMistakes: ex.commonMistakes,
            thumbnailUrl: ex.thumbnailUrl,
            isActive: ex.isActive,
            videoUrl: 'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_videos/savasana.mp4',
          );
        }

        sequence.add(WorkoutExerciseEntity(
          id: 'we_dynamic_$i',
          exerciseId: ex.id,
          orderIndex: i,
          exercise: ex,
        ));
      }

      // If it's a fallback with only 1 exercise, add Savasana at the end
      if (sequence.length == 1 && decodedId != "Savasana") {
         try {
            final savasana = availableExs.firstWhere((e) => e.name.toLowerCase().contains("savasana"));
            sequence.add(WorkoutExerciseEntity(
              id: 'we_dynamic_fallback',
              exerciseId: savasana.id,
              orderIndex: 1,
              exercise: savasana,
            ));
         } catch (_) {}
      }

      return Success(WorkoutEntity(
        id: id,
        name: workoutTitle,
        description: 'A customized session for $workoutTitle.',
        estimatedMinutes: sequence.length * 2,
        difficulty: Difficulty.beginner,
        category: 'Yoga',
        exercises: sequence,
      ));
    } catch (_) {}

    return getTodayWorkout(
        difficulty: Difficulty.beginner, durationMinutes: 15, goals: []);
  }
}

