import 'exercise_entity.dart';

/// User profile entity — collects all onboarding preferences.
class UserProfileEntity {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final Difficulty fitnessLevel;
  final List<String> goals;
  final int workoutFrequencyPerWeek;
  final int preferredDurationMinutes;
  final String preferredTime;
  final List<String> availableEquipment;
  final String? physicalLimitations;

  const UserProfileEntity({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.age,
    this.heightCm,
    this.weightKg,
    required this.fitnessLevel,
    required this.goals,
    required this.workoutFrequencyPerWeek,
    required this.preferredDurationMinutes,
    required this.preferredTime,
    required this.availableEquipment,
    this.physicalLimitations,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get firstGoal => goals.isNotEmpty ? goals.first : 'Wellness';

  UserProfileEntity copyWith({
    String? firstName,
    String? lastName,
    int? age,
    double? heightCm,
    double? weightKg,
    Difficulty? fitnessLevel,
    List<String>? goals,
    int? workoutFrequencyPerWeek,
    int? preferredDurationMinutes,
    String? preferredTime,
    List<String>? availableEquipment,
    String? physicalLimitations,
  }) {
    return UserProfileEntity(
      id: id,
      userId: userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      goals: goals ?? this.goals,
      workoutFrequencyPerWeek:
          workoutFrequencyPerWeek ?? this.workoutFrequencyPerWeek,
      preferredDurationMinutes:
          preferredDurationMinutes ?? this.preferredDurationMinutes,
      preferredTime: preferredTime ?? this.preferredTime,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      physicalLimitations: physicalLimitations ?? this.physicalLimitations,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'age': age,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'fitness_level': fitnessLevel.name,
        'goals': goals,
        'workout_frequency_per_week': workoutFrequencyPerWeek,
        'preferred_duration_minutes': preferredDurationMinutes,
        'preferred_time': preferredTime,
        'available_equipment': availableEquipment,
        'physical_limitations': physicalLimitations,
      };

  factory UserProfileEntity.fromJson(Map<String, dynamic> json) =>
      UserProfileEntity(
        id: json['id'] as String? ?? json['user_id'] as String? ?? 'local',
        userId: json['user_id'] as String? ?? json['id'] as String? ?? 'local',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        age: json['age'] as int?,
        heightCm: (json['height_cm'] as num?)?.toDouble(),
        weightKg: (json['weight_kg'] as num?)?.toDouble(),
        fitnessLevel: Difficulty.values.firstWhere(
          (e) =>
              e.name.toLowerCase() ==
              (json['fitness_level'] as String? ?? 'beginner').toLowerCase(),
          orElse: () => Difficulty.beginner,
        ),
        goals: List<String>.from(json['goals'] ?? []),
        workoutFrequencyPerWeek: json['workout_frequency_per_week'] as int? ?? 3,
        preferredDurationMinutes:
            json['preferred_duration_minutes'] as int? ?? 15,
        preferredTime: json['preferred_time'] as String? ?? 'Morning',
        availableEquipment:
            List<String>.from(json['available_equipment'] ?? []),
        physicalLimitations: json['physical_limitations'] as String?,
      );

  factory UserProfileEntity.initial(String userId) => UserProfileEntity(
        id: userId,
        userId: userId,
        firstName: 'Yogi',
        lastName: '',
        fitnessLevel: Difficulty.beginner,
        goals: const ['Flexibility', 'Mindfulness'],
        workoutFrequencyPerWeek: 3,
        preferredDurationMinutes: 15,
        preferredTime: 'Morning',
        availableEquipment: const ['Yoga Mat'],
      );
}
