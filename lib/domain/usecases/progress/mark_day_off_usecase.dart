import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_key.dart';
import '../../../core/utils/result.dart';
import '../../repositories/i_progress_repository.dart';

/// Explicitly records "today is an off day". The whole point of this
/// use case existing (instead of just silently skipping a day) is the
/// product requirement that the user must open the app and declare an
/// off day themselves — a day is never just left blank.
class MarkDayOffUseCase {
  final IProgressRepository _progressRepo;

  MarkDayOffUseCase(this._progressRepo);

  Future<Result<void>> execute(String userId, {DateTime? date}) {
    final key = dateKey(date ?? DateTime.now());
    return _progressRepo.setDayStatus(userId, key, AppConstants.dayStatusOff);
  }
}
