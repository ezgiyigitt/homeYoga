/// Difficulty level — used in exercises, workouts, and user profiles.
enum Difficulty {
  beginner,
  intermediate,
  advanced;

  String get label => switch (this) {
        Difficulty.beginner => 'Beginner',
        Difficulty.intermediate => 'Intermediate',
        Difficulty.advanced => 'Advanced',
      };

  static Difficulty fromString(String v) => switch (v.toLowerCase()) {
        'intermediate' => Difficulty.intermediate,
        'advanced' => Difficulty.advanced,
        _ => Difficulty.beginner,
      };
}

/// Core exercise entity — framework-free pure Dart.
class ExerciseEntity {
  final String id;
  final String name;
  final String category;
  final Difficulty difficulty;
  final int durationSeconds;
  final int? reps;
  final int? sets;
  final int restSeconds;
  final String equipment;
  final List<String> targetAreas;
  final List<String> tags;
  final String instructions;
  final String commonMistakes;
  final String? videoUrl;
  final String? audioUrl;
  final String? thumbnailUrl;
  final bool isActive;

  /// How much this exercise contributes to each skill axis
  /// (AppConstants.skillAxes), 0.0–1.0. Comes from Supabase's
  /// `skill_weights` column when set; when it's empty (e.g. older rows,
  /// or videos you haven't tagged yet) [effectiveSkillWeights] infers a
  /// reasonable default from [category] so the endless-practice engine
  /// still works without every video being manually tagged.
  final Map<String, double> skillWeights;

  const ExerciseEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.durationSeconds,
    this.reps,
    this.sets,
    required this.restSeconds,
    required this.equipment,
    required this.targetAreas,
    required this.tags,
    required this.instructions,
    required this.commonMistakes,
    this.videoUrl,
    this.audioUrl,
    this.thumbnailUrl,
    this.isActive = true,
    this.skillWeights = const {},
  });

  // Fallback skill weighting by category, used only when a video hasn't
  // been explicitly tagged in Supabase yet (skill_weights column empty).
  static const Map<String, Map<String, double>> _categoryDefaultWeights = {
    'Yoga': {'flexibility': 0.5, 'balance': 0.3, 'breath': 0.2},
    'Pilates': {'strength': 0.7, 'flexibility': 0.3},
    'Stretching': {'flexibility': 1.0},
    'Breathing': {'breath': 1.0},
  };

  List<String> get videoUrls {
    if (videoUrl == null || videoUrl!.trim().isEmpty) return const [];
    if (videoUrl!.contains(',')) {
      return videoUrl!
          .split(',')
          .map((u) => u.trim())
          .where((u) => u.isNotEmpty)
          .toList();
    }
    final url = videoUrl!.trim();
    if (url.contains('_left.mp4')) {
      final rightUrl = url.replaceAll('_left.mp4', '_right.mp4');
      return [url, rightUrl];
    }
    return [url];
  }

  Map<String, double> get effectiveSkillWeights {
    if (skillWeights.isNotEmpty) return skillWeights;
    return _categoryDefaultWeights[category] ??
        const {'flexibility': 0.5, 'strength': 0.5};
  }

  String get durationLabel {
    if (durationSeconds >= 60) {
      return '${durationSeconds ~/ 60} min';
    }
    return '$durationSeconds sec';
  }

  @override
  bool operator ==(Object other) =>
      other is ExerciseEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
