import 'package:supabase_flutter/supabase_flutter.dart' hide LocalStorage;
import '../../core/constants/supabase_config.dart';
import '../../core/utils/result.dart';
import '../../data/local/local_storage.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/entities/exercise_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';

/// Profile repository using Supabase.
class ProfileRepositoryImpl implements IProfileRepository {
  final LocalStorage _local;

  ProfileRepositoryImpl(this._local);

  @override
  Future<Result<UserProfileEntity?>> getProfile(String userId) async {
    // 1. Try Supabase if configured and user is signed in with remote ID
    if (SupabaseConfig.isConfigured && userId != 'local' && userId.length >= 32) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (data != null) {
          final profile = UserProfileEntity(
            id: data['id'] as String,
            userId: data['id'] as String,
            firstName: data['first_name'] as String? ?? '',
            lastName: data['last_name'] as String? ?? '',
            age: data['age'] as int?,
            heightCm: (data['height_cm'] as num?)?.toDouble(),
            weightKg: (data['weight_kg'] as num?)?.toDouble(),
            fitnessLevel: Difficulty.values.firstWhere(
              (e) =>
                  e.name.toLowerCase() ==
                  (data['fitness_level'] as String? ?? 'beginner').toLowerCase(),
              orElse: () => Difficulty.beginner,
            ),
            goals: List<String>.from(data['goals'] ?? []),
            workoutFrequencyPerWeek:
                data['workout_frequency_per_week'] as int? ?? 3,
            preferredDurationMinutes:
                data['preferred_duration_minutes'] as int? ?? 15,
            preferredTime: data['preferred_time'] as String? ?? 'Morning',
            availableEquipment:
                List<String>.from(data['available_equipment'] ?? []),
            physicalLimitations: data['physical_limitations'] as String?,
          );
          await _local.saveUserProfileData(profile.toJson());
          return Success(profile);
        }
      } catch (e) {
        // Fall through to local cache on error
      }
    }

    // 2. Try local cache
    final localData = _local.userProfileData;
    if (localData != null) {
      try {
        return Success(UserProfileEntity.fromJson(localData));
      } catch (_) {}
    }

    // 3. Fallback: if user completed onboarding with name, construct profile
    if (_local.firstName.isNotEmpty) {
      return Success(UserProfileEntity.initial(userId).copyWith(
        firstName: _local.firstName,
        lastName: _local.lastName,
      ));
    }

    return const Success(null);
  }

  @override
  Future<Result<UserProfileEntity>> saveProfile(
      UserProfileEntity profile) async {
    try {
      await _local.saveOnboardingComplete(
        firstName: profile.firstName,
        lastName: profile.lastName,
      );
      await _local.saveUserProfileData(profile.toJson());

      if (SupabaseConfig.isConfigured &&
          profile.userId != 'local' &&
          profile.userId.length >= 32) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': profile.userId,
          'first_name': profile.firstName,
          'last_name': profile.lastName,
          'age': profile.age,
          'height_cm': profile.heightCm,
          'weight_kg': profile.weightKg,
          'fitness_level': profile.fitnessLevel.name,
          'goals': profile.goals,
          'workout_frequency_per_week': profile.workoutFrequencyPerWeek,
          'preferred_duration_minutes': profile.preferredDurationMinutes,
          'preferred_time': profile.preferredTime,
          'available_equipment': profile.availableEquipment,
          'physical_limitations': profile.physicalLimitations,
        });
      }

      return Success(profile);
    } catch (e) {
      return Failure('Failed to save profile: $e');
    }
  }
}
