/// 8-point spacing grid — consistent with iOS HIG.
abstract class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;
  static const double huge = 48.0;
  static const double massive = 64.0;

  /// Standard screen horizontal padding (iOS style)
  static const double screenHorizontal = 20.0;

  /// Section header top padding
  static const double sectionTop = 28.0;

  // ── Corner Radii ──────────────────────────────────────
  /// iOS text field / cell corner radius
  static const double radiusInput = 10.0;

  /// iOS card / grouped list corner radius
  static const double radiusCard = 13.0;

  /// iOS large sheet / modal corner radius
  static const double radiusSheet = 20.0;

  /// Pill / chip (fully rounded)
  static const double radiusPill = 100.0;

  /// Small element (badge, dot)
  static const double radiusSmall = 6.0;

  // ── Tab Bar ───────────────────────────────────────────
  static const double tabBarHeight = 83.0;

  // ── Navigation Bar ────────────────────────────────────
  static const double navBarHeight = 44.0;
  static const double largeTitleHeight = 96.0;
}
