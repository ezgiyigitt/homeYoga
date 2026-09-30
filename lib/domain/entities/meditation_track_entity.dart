/// A sound-meditation track — ambient/frequency audio (no voice needed),
/// paired on screen with a rotating text mantra instead of spoken
/// narration. See AppConstants.meditationCategories for the category set
/// and AppConstants.mantras for the text side.
class MeditationTrackEntity {
  final String id;
  final String title;
  final String category; // one of AppConstants.meditationCategories
  final int durationSeconds;
  final String audioUrl;

  /// Optional human label for what the track is tuned to, e.g. "432Hz"
  /// or "Delta Waves" — shown in the UI, not used for any logic.
  final String? frequencyLabel;

  const MeditationTrackEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.durationSeconds,
    required this.audioUrl,
    this.frequencyLabel,
  });

  String get durationLabel {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '$minutes min';
    return '${minutes}m ${seconds}s';
  }

  @override
  bool operator ==(Object other) => other is MeditationTrackEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
