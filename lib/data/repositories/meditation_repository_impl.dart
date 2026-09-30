import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/supabase_config.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/meditation_track_entity.dart';
import '../../domain/repositories/i_meditation_repository.dart';

class MeditationRepositoryImpl implements IMeditationRepository {
  // Placeholder tracks so the feature works before any real audio is
  // uploaded — swap video_url-style entries for real files in Supabase's
  // 'meditation_tracks' table (see GEMINI_BRIEFING.md for the format to
  // hand off when adding content). Uses the same public sample asset the
  // rest of the app falls back to before real media exists.
  static const _placeholderAudioUrl =
      'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

  final List<MeditationTrackEntity> _mockTracks = const [
    MeditationTrackEntity(
      id: 'med-calm-1',
      title: '5-Minute Calm Reset',
      category: 'Calm',
      durationSeconds: 300,
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/5_minute_calm_reset.mp3',
      frequencyLabel: '432Hz',
    ),
    MeditationTrackEntity(
      id: 'med-focus-1',
      title: 'Clear Mind',
      category: 'Focus',
      durationSeconds: 420,
      audioUrl:
          'https://tuvgfpugfdeondeaxzmi.supabase.co/storage/v1/object/public/yoga_audios/40Hz.mp3',
      frequencyLabel: '40Hz Gamma',
    ),
    MeditationTrackEntity(
      id: 'med-sleep-1',
      title: 'Deep Rest',
      category: 'Sleep',
      durationSeconds: 600,
      audioUrl: _placeholderAudioUrl,
      frequencyLabel: 'Delta Waves',
    ),
    MeditationTrackEntity(
      id: 'med-energy-1',
      title: 'Morning Rise',
      category: 'Energy',
      durationSeconds: 240,
      audioUrl: _placeholderAudioUrl,
      frequencyLabel: '528Hz',
    ),
  ];

  @override
  Future<Result<List<MeditationTrackEntity>>> getTracks() async {
    if (SupabaseConfig.isConfigured) {
      try {
        final data = await Supabase.instance.client.from('meditation_tracks').select();
        final list = data.map((e) => _mapTrack(e)).toList();
        if (list.isNotEmpty) return Success(list);
      } catch (_) {
        // Fall through to placeholders below — table may not exist yet.
      }
    }
    await Future.delayed(const Duration(milliseconds: 200));
    return Success(_mockTracks);
  }

  MeditationTrackEntity _mapTrack(Map<String, dynamic> data) {
    return MeditationTrackEntity(
      id: data['id'] as String,
      title: data['title'] as String,
      category: data['category'] as String? ?? 'Calm',
      durationSeconds: data['duration_seconds'] as int? ?? 300,
      audioUrl: data['audio_url'] as String,
      frequencyLabel: data['frequency_label'] as String?,
    );
  }
}
