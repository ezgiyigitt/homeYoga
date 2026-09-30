import '../../../core/utils/result.dart';
import '../../entities/meditation_track_entity.dart';
import '../../repositories/i_meditation_repository.dart';

class GetMeditationTracksUseCase {
  final IMeditationRepository _repo;

  GetMeditationTracksUseCase(this._repo);

  Future<Result<List<MeditationTrackEntity>>> execute() => _repo.getTracks();
}
