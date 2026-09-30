import '../../core/utils/result.dart';
import '../entities/user_profile_entity.dart';

/// Abstract profile repository interface.
abstract interface class IProfileRepository {
  /// Loads the profile for [userId].
  Future<Result<UserProfileEntity?>> getProfile(String userId);

  /// Creates or updates the profile.
  Future<Result<UserProfileEntity>> saveProfile(UserProfileEntity profile);
}
