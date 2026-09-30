import 'package:flutter/material.dart';

/// Apple Human Interface Guidelines — semantic color system.
///
/// Colors come in two families:
///
/// * **Semantic** — backgrounds, labels, separators, fills, shadows and the
///   green containers. These change with the active appearance, so they are
///   exposed as getters that resolve against [brightness]. Because they are
///   not compile-time constants, widgets using them cannot be `const`.
/// * **Brand and status** — the sage green identity and the iOS status
///   palette (red, green, orange…). These stay identical in both
///   appearances and remain `const`, so they can still be used in const
///   expressions and default parameter values.
///
/// [brightness] is set once per frame by the app shell (see `HomeYogaApp`)
/// from the resolved theme, so every screen paints in the appearance the
/// user picked in Settings → Appearance & Theme.
///
/// Reference: https://developer.apple.com/design/human-interface-guidelines/color
abstract class AppColors {
  AppColors._();

  // ── Active appearance ──────────────────────────────────

  static Brightness _brightness = Brightness.light;

  /// The appearance every semantic getter below resolves against.
  static Brightness get brightness => _brightness;

  /// True when the app is currently painting in dark mode.
  static bool get isDark => _brightness == Brightness.dark;

  /// Called by the app shell whenever the resolved theme changes. Widgets
  /// should never call this — read [isDark] instead.
  static void setBrightness(Brightness value) => _brightness = value;

  /// Picks between a light and a dark value for the active appearance.
  static Color resolve(Color light, Color dark) => isDark ? dark : light;

  // ── System Backgrounds ─────────────────────────────────

  /// Primary content background.
  static Color get systemBackground =>
      resolve(const Color(0xFFFFFFFF), const Color(0xFF000000));

  /// Screen background behind grouped content.
  static Color get systemGroupedBackground =>
      resolve(const Color(0xFFF2F2F7), const Color(0xFF000000));

  /// Elevated surfaces (cards, rows) within grouped content.
  static Color get secondaryGroupedBackground =>
      resolve(const Color(0xFFFFFFFF), const Color(0xFF1C1C1E));

  // ── Labels ─────────────────────────────────────────────

  /// Primary text.
  static Color get label =>
      resolve(const Color(0xFF000000), const Color(0xFFFFFFFF));

  /// Secondary text — 60% (Apple spec).
  static Color get secondaryLabel =>
      resolve(const Color(0x993C3C43), const Color(0x99EBEBF5));

  /// Tertiary text — 30%.
  static Color get tertiaryLabel =>
      resolve(const Color(0x4D3C3C43), const Color(0x4DEBEBF5));

  /// Quaternary — 18% (very faint).
  static Color get quaternaryLabel =>
      resolve(const Color(0x2E3C3C43), const Color(0x2EEBEBF5));

  // ── Separators ─────────────────────────────────────────

  /// Thin separator (29% opacity).
  static Color get separator =>
      resolve(const Color(0x493C3C43), const Color(0x99545458));

  /// Opaque separator.
  static Color get opaqueSeparator =>
      resolve(const Color(0xFFC6C6C8), const Color(0xFF38383A));

  // ── Fills ──────────────────────────────────────────────

  /// Input field fill.
  static Color get systemFill =>
      resolve(const Color(0x33787880), const Color(0x5C787880));

  /// Secondary fill (lighter).
  static Color get secondarySystemFill =>
      resolve(const Color(0x28787880), const Color(0x51787880));

  // ── Brand / Wellness Primary ───────────────────────────

  /// Sage green — Home Yoga brand. Identical in both appearances so it can
  /// stay `const` and keep the identity stable.
  static const Color primary = Color(0xFF4A7C59);
  static const Color primaryLight = Color(0xFF6A9C79);

  /// Deep sage used for the brand mark and for text sitting on
  /// [primaryContainer] / [primaryMuted]. In dark mode those containers go
  /// dark, so this lightens to stay readable on them.
  static Color get primaryDark =>
      resolve(const Color(0xFF2F5C3A), const Color(0xFF9CCBAC));

  /// Constant deep sage, for const contexts such as the logo mark, where a
  /// fixed brand value is wanted rather than a readable-on-container tone.
  static const Color primaryDarkFixed = Color(0xFF2F5C3A);

  /// Filled green chip / badge background.
  static Color get primaryContainer =>
      resolve(const Color(0xFFD1E8DA), const Color(0xFF1E3A28));

  /// Faintest green wash.
  static Color get primaryMuted =>
      resolve(const Color(0xFFEAF4EE), const Color(0xFF16251B));

  // ── System Colors (iOS palette) ────────────────────────
  // Status colors read the same against black and white, so they stay const.

  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemMint = Color(0xFF00C7BE);
  static const Color systemTeal = Color(0xFF30B0C7);
  static const Color systemCyan = Color(0xFF32ADE6);
  static const Color systemBlue = Color(0xFF007AFF);
  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemBrown = Color(0xFFA2845E);

  // ── System Grays ───────────────────────────────────────
  // The gray ramp inverts: gray6 is the lightest surface in light mode and
  // the darkest in dark mode, so a divider stays a divider either way.

  static Color get systemGray =>
      resolve(const Color(0xFF8E8E93), const Color(0xFF8E8E93));
  static Color get systemGray2 =>
      resolve(const Color(0xFFAEAEB2), const Color(0xFF636366));
  static Color get systemGray3 =>
      resolve(const Color(0xFFC7C7CC), const Color(0xFF48484A));
  static Color get systemGray4 =>
      resolve(const Color(0xFFD1D1D6), const Color(0xFF3A3A3C));
  static Color get systemGray5 =>
      resolve(const Color(0xFFE5E5EA), const Color(0xFF2C2C2E));
  static Color get systemGray6 =>
      resolve(const Color(0xFFF2F2F7), const Color(0xFF1C1C1E));

  // ── Semantic Aliases ───────────────────────────────────

  static const Color destructive = systemRed;
  static const Color success = systemGreen;
  static const Color warning = systemOrange;
  static const Color tint = primary; // iOS tint color

  // ── Shadow ─────────────────────────────────────────────
  // Dark mode has no diffuse light, so shadows deepen instead of tinting.

  static Color get shadowLight =>
      resolve(const Color(0x0A000000), const Color(0x40000000));
  static Color get shadowMedium =>
      resolve(const Color(0x14000000), const Color(0x59000000));
}
