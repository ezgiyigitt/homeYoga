import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/repositories/i_profile_repository.dart';
import '../../../../domain/repositories/i_progress_repository.dart';
import '../../../../domain/entities/user_profile_entity.dart';
import '../../../shared/providers/app_providers.dart';
import 'profile_state.dart';

final profileViewModelProvider = StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
  return ProfileViewModel(
    ref.watch(profileRepositoryProvider),
    ref.watch(progressRepositoryProvider),
    ref.watch(localStorageProvider).userId ?? 'local',
  );
});

class ProfileViewModel extends StateNotifier<ProfileState> {
  final IProfileRepository _profileRepo;
  final IProgressRepository _progressRepo;
  final String? _userId;

  ProfileViewModel(this._profileRepo, this._progressRepo, this._userId) : super(const ProfileState()) {
    if (_userId != null) {
      loadProfileAndStats();
    }
  }

  Future<void> loadProfileAndStats() async {
    if (_userId == null) return;
    
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profileRes = await _profileRepo.getProfile(_userId);
      final progressRes = await _progressRepo.getProgress(_userId);
      
      state = state.copyWith(
        isLoading: false,
        profile: profileRes.dataOrNull,
        progress: progressRes.dataOrNull,
        error: (!profileRes.isSuccess || !progressRes.isSuccess) ? 'Failed to load some profile data.' : null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(UserProfileEntity updatedProfile) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _profileRepo.saveProfile(updatedProfile);
      if (res.isSuccess) {
        state = state.copyWith(isLoading: false, profile: res.dataOrNull);
      } else {
        state = state.copyWith(isLoading: false, error: res.errorOrNull);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
