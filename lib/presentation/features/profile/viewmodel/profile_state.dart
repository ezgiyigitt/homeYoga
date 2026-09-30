import '../../../../domain/entities/user_profile_entity.dart';
import '../../../../domain/entities/user_progress_entity.dart';

class ProfileState {
  final UserProfileEntity? profile;
  final UserProgressEntity? progress;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.profile,
    this.progress,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfileEntity? profile,
    UserProgressEntity? progress,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      progress: progress ?? this.progress,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
