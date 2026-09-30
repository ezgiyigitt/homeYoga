import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/features/splash/view/splash_screen.dart';
import '../../presentation/features/auth/view/login_screen.dart';
import '../../presentation/features/auth/view/register_screen.dart';
import '../../presentation/features/onboarding/view/onboarding_screen.dart';
import '../../presentation/features/onboarding/view/plan_ready_screen.dart';
import '../../presentation/features/main_shell/view/main_shell.dart';
import '../../presentation/features/home/view/home_screen.dart';
import '../../presentation/features/workout/view/workout_player_screen.dart';
import '../../presentation/features/meditation/view/meditation_screen.dart';
import '../../presentation/features/coach/view/coach_screen.dart';
import '../../presentation/features/progress/view/progress_screen.dart';
import '../../presentation/features/progress/view/garden_screen.dart';
import '../../presentation/features/profile/view/profile_screen.dart';
import '../../presentation/features/profile/view/settings/personal_info_screen.dart';
import '../../presentation/features/profile/view/settings/fitness_goals_screen.dart';
import '../../presentation/features/profile/view/settings/appearance_screen.dart';
import '../../presentation/features/profile/view/settings/language_screen.dart';
import '../../presentation/features/profile/view/settings/notifications_screen.dart';
import '../../presentation/features/profile/view/settings/sound_screen.dart';
import '../../presentation/features/profile/view/settings/privacy_security_screen.dart';
import '../../presentation/features/profile/view/settings/help_faq_screen.dart';
import '../../presentation/features/profile/view/settings/legal_screen.dart';
import '../../presentation/features/profile/view/settings/about_screen.dart';
import '../../domain/entities/workout_entity.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shared "fade + slight scale" push used for the screens that should
/// feel like a deliberate step forward rather than a hard platform push
/// (the workout player, meditation). Kept as one
/// helper so all of them move in sync instead of drifting apart.
CustomTransitionPage<void> _fadeScalePage(Widget child) {
  return CustomTransitionPage<void>(
    child: child,
    transitionsBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: false,
    routes: [
      // ── Splash ──────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (_, __) => const NoTransitionPage(child: SplashScreen()),
      ),

      // ── Auth ────────────────────────────────────────────
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (_, __) => const CupertinoPage(child: LoginScreen()),
      ),
      GoRoute(
        path: RouteNames.register,
        pageBuilder: (_, __) => const CupertinoPage(child: RegisterScreen()),
      ),

      // ── Onboarding ──────────────────────────────────────
      GoRoute(
        path: RouteNames.onboarding,
        pageBuilder: (_, __) => const CupertinoPage(child: OnboardingScreen()),
      ),
      GoRoute(
        path: RouteNames.planReady,
        pageBuilder: (_, __) => const CupertinoPage(child: PlanReadyScreen()),
      ),

      // ── Main Shell with Tab Navigation ──────────────────
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.coach,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: CoachScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.progress,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ProgressScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: ProfileScreen()),
                routes: [
                  GoRoute(
                    path: RouteNames.profilePersonalInfo,
                    pageBuilder: (_, __) => const CupertinoPage(child: PersonalInfoScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileFitnessGoals,
                    pageBuilder: (_, __) => const CupertinoPage(child: FitnessGoalsScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileAppearance,
                    pageBuilder: (_, __) => const CupertinoPage(child: AppearanceScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileLanguage,
                    pageBuilder: (_, __) => const CupertinoPage(child: LanguageScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileNotifications,
                    pageBuilder: (_, __) =>
                        const CupertinoPage(child: NotificationsScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileSound,
                    pageBuilder: (_, __) =>
                        const CupertinoPage(child: SoundScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profilePrivacy,
                    pageBuilder: (_, __) =>
                        const CupertinoPage(child: PrivacySecurityScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileHelp,
                    pageBuilder: (_, __) =>
                        const CupertinoPage(child: HelpFaqScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileLegal,
                    pageBuilder: (_, __) =>
                        const CupertinoPage(child: LegalScreen()),
                  ),
                  GoRoute(
                    path: RouteNames.profileAbout,
                    pageBuilder: (_, __) =>
                        const CupertinoPage(child: AboutScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.garden,
                pageBuilder: (_, __) =>
                    const NoTransitionPage(child: GardenScreen()),
              ),
            ],
          ),
        ],
      ),

      // ── Full Screen Routes (over Tab Bar) ───────────────
      GoRoute(
        path: RouteNames.workout,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final customWorkout = state.extra as WorkoutEntity?;
          return _fadeScalePage(WorkoutPlayerScreen(customWorkout: customWorkout));
        },
      ),
      GoRoute(
        path: RouteNames.workoutDetails,
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final workoutId = state.pathParameters['id'];
          return _fadeScalePage(WorkoutPlayerScreen(workoutId: workoutId));
        },
      ),
      GoRoute(
        path: RouteNames.meditation,
        parentNavigatorKey: _rootNavigatorKey,
        // Same fade + slight scale — this screen especially should feel
        // like a calm, deliberate step away from the rest of the app,
        // not just "another page".
        pageBuilder: (_, __) => _fadeScalePage(const MeditationScreen()),
      ),
    ],
  );
});
