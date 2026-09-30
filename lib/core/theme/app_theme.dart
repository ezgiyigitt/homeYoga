import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Material 3 theme configured to match Apple Human Interface Guidelines.
///
/// Visual language: iOS system appearance with the wellness sage-green brand.
///
/// Light and dark are produced by the *same* builder. Every colour in here
/// comes from [AppColors], whose semantic values resolve against the active
/// appearance, so the two themes can never drift apart — a colour added for
/// light mode automatically has a dark counterpart.
abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);

  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    // [AppColors] resolves against a global appearance, so pin it while this
    // theme is assembled and hand it back afterwards. The app shell sets the
    // appearance for the frame itself.
    final previous = AppColors.brightness;
    AppColors.setBrightness(brightness);
    final isDark = brightness == Brightness.dark;

    final theme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.systemGroupedBackground,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        },
      ),

      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primaryLight,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.primaryMuted,
        onSecondaryContainer: AppColors.primaryDark,
        tertiary: AppColors.systemTeal,
        onTertiary: Colors.white,
        tertiaryContainer: AppColors.resolve(
          const Color(0xFFCCF5F3),
          const Color(0xFF10403E),
        ),
        onTertiaryContainer: AppColors.resolve(
          const Color(0xFF004D4A),
          const Color(0xFFA6E9E6),
        ),
        error: AppColors.systemRed,
        onError: Colors.white,
        errorContainer: AppColors.resolve(
          const Color(0xFFFFEDE9),
          const Color(0xFF441512),
        ),
        onErrorContainer: AppColors.systemRed,
        surface: AppColors.systemBackground,
        onSurface: AppColors.label,
        surfaceContainerHighest: AppColors.systemGroupedBackground,
        onSurfaceVariant: AppColors.secondaryLabel,
        outline: AppColors.separator,
        outlineVariant: AppColors.opaqueSeparator,
        shadow: AppColors.shadowMedium,
        scrim: const Color(0x66000000),
        inverseSurface: AppColors.label,
        onInverseSurface: AppColors.systemBackground,
        inversePrimary: AppColors.primaryLight,
      ),

      // ── AppBar ─────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0.5,
        backgroundColor: AppColors.systemGroupedBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadowLight,
        titleTextStyle: AppTypography.navTitle,
        toolbarHeight: AppSpacing.navBarHeight,
        // Dark surfaces need light status-bar icons, and vice versa.
        systemOverlayStyle:
            (isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                .copyWith(statusBarColor: Colors.transparent),
        iconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 22,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 22,
        ),
      ),

      // ── Card ───────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.secondaryGroupedBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        margin: EdgeInsets.zero,
        shadowColor: AppColors.shadowLight,
      ),

      // ── Input ──────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // On black, a "grouped background" fill would be invisible against
        // the scaffold, so inputs sit on the elevated surface instead.
        fillColor: isDark
            ? AppColors.secondaryGroupedBackground
            : AppColors.systemGroupedBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: const BorderSide(color: AppColors.systemRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          borderSide: const BorderSide(color: AppColors.systemRed, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.body.copyWith(color: AppColors.tertiaryLabel),
        labelStyle:
            AppTypography.callout.copyWith(color: AppColors.secondaryLabel),
        floatingLabelStyle: AppTypography.footnote.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: AppTypography.caption1.copyWith(color: AppColors.systemRed),
      ),

      // ── ElevatedButton ─────────────────────────────────
      // iOS-style: filled, rounded, no elevation
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.systemGray5,
          disabledForegroundColor: AppColors.systemGray3,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          textStyle: AppTypography.buttonLabel,
        ),
      ),

      // ── TextButton ─────────────────────────────────────
      // iOS-style: tint color, no background
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          textStyle: AppTypography.callout.copyWith(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          ),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
          textStyle:
              AppTypography.buttonLabel.copyWith(color: AppColors.primary),
        ),
      ),

      // ── BottomNavigationBar ────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.secondaryGroupedBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.systemGray2,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        elevation: 0,
        selectedLabelStyle: AppTypography.tabLabel.copyWith(
          color: AppColors.primary,
        ),
        unselectedLabelStyle: AppTypography.tabLabel,
        selectedIconTheme: const IconThemeData(
          color: AppColors.primary,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: AppColors.systemGray2,
          size: 24,
        ),
      ),

      // ── NavigationBar ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.secondaryGroupedBackground,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: AppColors.primaryMuted,
        elevation: 0,
        height: AppSpacing.tabBarHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return IconThemeData(color: AppColors.systemGray2, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.tabLabel.copyWith(color: AppColors.primary);
          }
          return AppTypography.tabLabel;
        }),
      ),

      // ── Chip ───────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.systemGroupedBackground,
        selectedColor: AppColors.primaryContainer,
        disabledColor: AppColors.systemGray6,
        labelStyle: AppTypography.subheadline,
        secondaryLabelStyle:
            AppTypography.subheadline.copyWith(color: AppColors.primaryDark),
        side: BorderSide(color: AppColors.opaqueSeparator, width: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),

      // ── Dialog ─────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.secondaryGroupedBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headline,
        contentTextStyle: AppTypography.subheadline,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSheet),
        ),
      ),

      // ── Bottom sheet ───────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.secondaryGroupedBackground,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.secondaryGroupedBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusSheet),
          ),
        ),
      ),

      // ── Divider ────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: AppColors.separator,
        thickness: 0.5,
        space: 0,
      ),

      // ── ListTile ───────────────────────────────────────
      listTileTheme: ListTileThemeData(
        titleTextStyle: AppTypography.body,
        subtitleTextStyle: AppTypography.subheadline,
        iconColor: AppColors.secondaryLabel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // ── Switch ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.systemGray4;
        }),
        trackOutlineColor:
            WidgetStateProperty.resolveWith((states) => Colors.transparent),
      ),

      // ── Radio ──────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return AppColors.systemGray2;
        }),
      ),

      // ── SnackBar ───────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.label,
        contentTextStyle: AppTypography.subheadline
            .copyWith(color: AppColors.systemBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // ── Progress ───────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.systemGray5,
        linearMinHeight: 4,
        circularTrackColor: Colors.transparent,
      ),

      // ── Text ───────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTypography.largeTitle.copyWith(fontSize: 57),
        displayMedium: AppTypography.largeTitle.copyWith(fontSize: 45),
        displaySmall: AppTypography.largeTitle.copyWith(fontSize: 36),
        headlineLarge: AppTypography.largeTitle,
        headlineMedium: AppTypography.title1,
        headlineSmall: AppTypography.title2,
        titleLarge: AppTypography.title3,
        titleMedium: AppTypography.headline,
        titleSmall: AppTypography.subheadlineSemibold,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.callout,
        bodySmall: AppTypography.subheadline,
        labelLarge: AppTypography.footnoteSemibold,
        labelMedium: AppTypography.footnote,
        labelSmall: AppTypography.caption1,
      ),
    );

    AppColors.setBrightness(previous);
    return theme;
  }
}
