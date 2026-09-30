import '../entities/meditation_track_entity.dart';
import '../../core/utils/result.dart';

abstract class IMeditationRepository {
  Future<Result<List<MeditationTrackEntity>>> getTracks();
}
