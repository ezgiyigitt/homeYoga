import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme/app_typography.dart';


/// Shortcuts for accessing theme, screen info, and styles via BuildContext.
extension ContextExtension on BuildContext {
  // ── Localization ───────────────────────────────────────
  /// Translated strings for the active locale: `context.l10n.settingsTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);

  // ── Theme ──────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;

  // ── Screen ─────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  EdgeInsets get viewPadding => MediaQuery.of(this).viewPadding;
  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
  bool get isKeyboardVisible => MediaQuery.of(this).viewInsets.bottom > 0;

  // ── iOS Typography shortcuts ───────────────────────────
  TextStyle get largeTitle => AppTypography.largeTitle;
  TextStyle get title1 => AppTypography.title1;
  TextStyle get title2 => AppTypography.title2;
  TextStyle get title3 => AppTypography.title3;
  TextStyle get headline => AppTypography.headline;
  TextStyle get body => AppTypography.body;
  TextStyle get callout => AppTypography.callout;
  TextStyle get subheadline => AppTypography.subheadline;
  TextStyle get footnote => AppTypography.footnote;
  TextStyle get caption1 => AppTypography.caption1;
  TextStyle get caption2 => AppTypography.caption2;
}

/// Spacing helpers: `16.h` = `SizedBox(height: 16)`
extension SizedBoxNum on num {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}
