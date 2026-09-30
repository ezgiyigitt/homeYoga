import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/local/local_storage.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../data/repositories/profile_repository_impl.dart';
import '../../../domain/repositories/i_auth_repository.dart';
import '../../../domain/repositories/i_profile_repository.dart';
import '../../../domain/usecases/auth/sign_in_usecase.dart';
import '../../../domain/usecases/auth/sign_up_usecase.dart';
import '../../../domain/usecases/auth/delete_account_usecase.dart';
import '../../../domain/usecases/onboarding/save_profile_usecase.dart';
import '../../../domain/usecases/workout/daily_practice_usecase.dart';
import '../../../domain/usecases/workout/pain_relief_usecase.dart';
import '../../../domain/usecases/workout/complete_workout_usecase.dart';
import '../../../domain/repositories/i_exercise_repository.dart';
import '../../../domain/repositories/i_progress_repository.dart';
import '../../../data/repositories/exercise_repository_impl.dart';
import '../../../data/repositories/progress_repository_impl.dart';
import '../../../domain/usecases/workout/get_workout_by_id_usecase.dart';
import '../../../domain/repositories/i_meditation_repository.dart';
import '../../../data/repositories/meditation_repository_impl.dart';
import '../../../domain/usecases/meditation/get_meditation_tracks_usecase.dart';
import '../../../domain/usecases/meditation/complete_meditation_usecase.dart';
import '../../../domain/usecases/progress/mark_day_off_usecase.dart';
import '../../../domain/repositories/i_plan_repository.dart';
import '../../../data/repositories/plan_repository_impl.dart';
import '../../../domain/usecases/generate_plan_usecase.dart';

// ── SharedPreferences ────────────────────────────────────────────
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('Initialize before ProviderScope'),
);

// ── LocalStorage ────────────────────────────────────────────────
final localStorageProvider = Provider<LocalStorage>(
  (ref) => LocalStorage(ref.watch(sharedPreferencesProvider)),
);

// ── Repositories ────────────────────────────────────────────────
final authRepositoryProvider = Provider<IAuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(localStorageProvider)),
);

final profileRepositoryProvider = Provider<IProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(localStorageProvider)),
);

final exerciseRepositoryProvider = Provider<IExerciseRepository>(
  (ref) => ExerciseRepositoryImpl(),
);

final progressRepositoryProvider = Provider<IProgressRepository>(
  (ref) => ProgressRepositoryImpl(ref.watch(localStorageProvider)),
);

final meditationRepositoryProvider = Provider<IMeditationRepository>(
  (ref) => MeditationRepositoryImpl(),
);

final planRepositoryProvider = Provider<IPlanRepository>(
  (ref) => PlanRepositoryImpl(ref.watch(localStorageProvider)),
);

final generatePlanUseCaseProvider = Provider<GeneratePlanUseCase>(
  (ref) => GeneratePlanUseCase(
    ref.watch(exerciseRepositoryProvider),
    ref.watch(planRepositoryProvider),
  ),
);

// ── Use Cases ───────────────────────────────────────────────────
final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>(
  (ref) => DeleteAccountUseCase(ref.watch(authRepositoryProvider)),
);

final saveProfileUseCaseProvider = Provider<SaveProfileUseCase>(
  (ref) => SaveProfileUseCase(ref.watch(profileRepositoryProvider)),
);

// Endless-flow model (ENDLESS_PLAN.md, Faz 2): "today's workout" is no
// longer a fixed curriculum lookup — DailyPracticeUseCase picks a fresh
// combo from the exercise library each day. The provider name stays the
// same on purpose so HomeViewModel / WorkoutViewModel / WorkoutPlayerScreen
// didn't need to change to start using it.
final getTodayWorkoutUseCaseProvider = Provider<DailyPracticeUseCase>(
  (ref) => DailyPracticeUseCase(
    ref.watch(exerciseRepositoryProvider),
    ref.watch(profileRepositoryProvider),
    ref.watch(progressRepositoryProvider),
  ),
);

// "Bir yerim ağrıyor" akışı. Planı kural motoru üretir (pain_rules.dart),
// yapay zekâ yalnızca sunar — bkz. PainReliefUseCase başlığındaki not.
final painReliefUseCaseProvider = Provider<PainReliefUseCase>(
  (ref) => PainReliefUseCase(
    ref.watch(exerciseRepositoryProvider),
    ref.watch(profileRepositoryProvider),
  ),
);

final getWorkoutByIdUseCaseProvider = Provider<GetWorkoutByIdUseCase>(
  (ref) => GetWorkoutByIdUseCase(ref.watch(exerciseRepositoryProvider)),
);

final completeWorkoutUseCaseProvider = Provider<CompleteWorkoutUseCase>(
  (ref) => CompleteWorkoutUseCase(ref.watch(progressRepositoryProvider)),
);

final getMeditationTracksUseCaseProvider = Provider<GetMeditationTracksUseCase>(
  (ref) => GetMeditationTracksUseCase(ref.watch(meditationRepositoryProvider)),
);

final completeMeditationUseCaseProvider = Provider<CompleteMeditationUseCase>(
  (ref) => CompleteMeditationUseCase(ref.watch(progressRepositoryProvider)),
);

final markDayOffUseCaseProvider = Provider<MarkDayOffUseCase>(
  (ref) => MarkDayOffUseCase(ref.watch(progressRepositoryProvider)),
);

// ── Session state ────────────────────────────────────────────────
final isLoggedInProvider = Provider<bool>(
  (ref) => ref.watch(localStorageProvider).isLoggedIn,
);

final onboardingCompleteProvider = Provider<bool>(
  (ref) => ref.watch(localStorageProvider).onboardingComplete,
);
