/// Named route constants — single source of truth for all routes.
abstract class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String planReady = '/plan-ready';

  // Main shell tabs
  static const String home = '/home';
  static const String coach = '/coach';
  static const String progress = '/progress';
  static const String profile = '/profile';
  static const String garden = '/garden';
  static const String workout = '/workout';
  static const String meditation = '/meditation';

  // Nested routes (Phase 2+)
  static const String exercise = '/exercise/:id';
  static const String workoutDetails = '/workout/:id';
  
  // Profile nested routes
  static const String profilePersonalInfo = 'personal-info';
  static const String profileFitnessGoals = 'fitness-goals';
  static const String profileAppearance = 'appearance';
  static const String profileLanguage = 'language';
  static const String profileNotifications = 'notifications';
  static const String profileSound = 'sound';
  static const String profilePrivacy = 'privacy';
  static const String profileHelp = 'help';
  static const String profileLegal = 'legal';
  static const String profileAbout = 'about';
}
