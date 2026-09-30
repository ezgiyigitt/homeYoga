import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../../domain/entities/exercise_entity.dart';
import '../../../../domain/entities/user_profile_entity.dart';

// ── Onboarding State ─────────────────────────────────────────────
class OnboardingState {
  // Step 1
  final String firstName;
  final String lastName;
  final String age;
  final String heightCm;
  final String weightKg;

  // Step 2
  final Difficulty? fitnessLevel;

  // Step 3
  final List<String> goals;

  // Step 4
  final int? frequency;

  // Step 5
  final int? duration;

  // Step 6
  final List<String> equipment;

  // Step 7
  final String? preferredTime;

  // Step 8 (optional)
  final String? limitations;

  const OnboardingState({
    this.firstName = '',
    this.lastName = '',
    this.age = '',
    this.heightCm = '',
    this.weightKg = '',
    this.fitnessLevel,
    this.goals = const [],
    this.frequency,
    this.duration,
    this.equipment = const [],
    this.preferredTime,
    this.limitations,
  });

  bool get step1Valid => firstName.trim().isNotEmpty && lastName.trim().isNotEmpty;
  bool get step2Valid => fitnessLevel != null;
  bool get step3Valid => goals.isNotEmpty;
  bool get step4Valid => frequency != null;
  bool get step5Valid => duration != null;
  bool get step6Valid => equipment.isNotEmpty;
  bool get step7Valid => preferredTime != null;
  bool get step8Valid => true; // optional

  OnboardingState copyWith({
    String? firstName,
    String? lastName,
    String? age,
    String? heightCm,
    String? weightKg,
    Difficulty? fitnessLevel,
    List<String>? goals,
    int? frequency,
    int? duration,
    List<String>? equipment,
    String? preferredTime,
    String? limitations,
  }) {
    return OnboardingState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goals: goals ?? this.goals,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      equipment: equipment ?? this.equipment,
      preferredTime: preferredTime ?? this.preferredTime,
      limitations: limitations ?? this.limitations,
    );
  }
}

// ── Onboarding ViewModel ─────────────────────────────────────────
class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingViewModel(this._ref) : super(const OnboardingState());

  void updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? age,
    String? heightCm,
    String? weightKg,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
    );
  }

  void setFitnessLevel(Difficulty level) =>
      state = state.copyWith(fitnessLevel: level);

  void toggleGoal(String goal) {
    final list = List<String>.from(state.goals);
    list.contains(goal) ? list.remove(goal) : list.add(goal);
    state = state.copyWith(goals: list);
  }

  void setFrequency(int days) => state = state.copyWith(frequency: days);

  void setDuration(int minutes) => state = state.copyWith(duration: minutes);

  void toggleEquipment(String item) {
    final list = List<String>.from(state.equipment);
    if (item == 'No Equipment') {
      state = state.copyWith(equipment: ['No Equipment']);
      return;
    }
    list.remove('No Equipment');
    list.contains(item) ? list.remove(item) : list.add(item);
    state = state.copyWith(equipment: list);
  }

  void setPreferredTime(String time) =>
      state = state.copyWith(preferredTime: time);

  void setLimitations(String? text) =>
      state = state.copyWith(limitations: text);

  Future<String?> complete(String userId) async {
    final profile = UserProfileEntity(
      id: const Uuid().v4(),
      userId: userId,
      firstName: state.firstName.trim(),
      lastName: state.lastName.trim(),
      age: int.tryParse(state.age),
      heightCm: double.tryParse(state.heightCm),
      weightKg: double.tryParse(state.weightKg),
      fitnessLevel: state.fitnessLevel ?? Difficulty.beginner,
      goals: state.goals,
      workoutFrequencyPerWeek: state.frequency ?? 3,
      preferredDurationMinutes: state.duration ?? 15,
      preferredTime: state.preferredTime ?? 'Morning',
      availableEquipment: state.equipment,
      physicalLimitations: state.limitations,
    );

    final result = await _ref
        .read(saveProfileUseCaseProvider)
        .execute(profile);

    return result.when(
      onSuccess: (_) => null,
      onFailure: (msg) => msg,
    );
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>(
  (ref) => OnboardingViewModel(ref),
);
