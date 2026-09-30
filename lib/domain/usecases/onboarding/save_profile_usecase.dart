import '../../repositories/i_profile_repository.dart';
import '../../entities/user_profile_entity.dart';
import '../../../core/utils/result.dart';

/// Saves the user's onboarding profile to local + remote storage.
class SaveProfileUseCase {
  final IProfileRepository _repository;

  const SaveProfileUseCase(this._repository);

  Future<Result<UserProfileEntity>> execute(UserProfileEntity profile) {
    return _repository.saveProfile(profile);
  }
}
