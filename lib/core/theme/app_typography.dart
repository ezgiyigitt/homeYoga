import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Apple Human Interface Guidelines typography system.
///
/// On iOS and macOS every style resolves to the real Apple system font — San
/// Francisco — by leaving [TextStyle.fontFamily] null, which is how Flutter
/// asks the platform for its own font. Nothing is bundled, so this costs zero
/// bytes and stays within Apple's font licence (SF may be used on Apple
/// platforms, but not redistributed inside an Android or web build).
///
/// Flutter also switches automatically between SF Pro Text and SF Pro Display
/// around 20pt when the system font is used, so large titles pick up the
/// tighter display tracking exactly as they do in native iOS apps.
///
/// Everywhere else — Android, web, desktop — the app falls back to Inter,
/// the closest openly licensed match to San Francisco.
///
/// Reference: https://developer.apple.com/design/human-interface-guidelines/typography
abstract class AppTypography {
  AppTypography._();

  /// True where the platform's own font *is* San Francisco.
  static bool get usesAppleSystemFont =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  static TextStyle _sf({
    required double fontSize,
    required FontWeight fontWeight,
    double? letterSpacing,
    Color? color,
    double? height,
  }) {
    final base = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.label,
      height: height,
    );

    // fontFamily stays null → the engine hands back the platform font.
    if (usesAppleSystemFont) return base;

    return GoogleFonts.inter(textStyle: base).copyWith(
      fontFamilyFallback: const [
        'Helvetica Neue',
        'Segoe UI',
        'Roboto',
      ],
    );
  }

  // ── Display / Navigation ───────────────────────────────

  /// 34pt Bold — iOS Large Title (scrolling navigation bar)
  static TextStyle get largeTitle => _sf(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.37,
        color: AppColors.label,
        height: 1.21,
      );

  /// 28pt Bold — iOS Title 1
  static TextStyle get title1 => _sf(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.36,
        color: AppColors.label,
        height: 1.21,
      );

  /// 22pt Bold — iOS Title 2
  static TextStyle get title2 => _sf(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
        color: AppColors.label,
        height: 1.27,
      );

  /// 20pt Semibold — iOS Title 3
  static TextStyle get title3 => _sf(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.38,
        color: AppColors.label,
        height: 1.30,
      );

  // ── Body / Content ─────────────────────────────────────

  /// 17pt Semibold — iOS Headline (used in table section headers, alert titles)
  static TextStyle get headline => _sf(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: AppColors.label,
        height: 1.29,
      );

  /// 17pt Regular — iOS Body
  static TextStyle get body => _sf(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.41,
        color: AppColors.label,
        height: 1.53,
      );

  /// 16pt Regular — iOS Callout
  static TextStyle get callout => _sf(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.32,
        color: AppColors.label,
        height: 1.50,
      );

  /// 16pt Medium — Callout medium weight variant
  static TextStyle get calloutMedium => _sf(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.32,
        color: AppColors.label,
        height: 1.50,
      );

  /// 15pt Regular — iOS Subheadline
  static TextStyle get subheadline => _sf(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.24,
        color: AppColors.secondaryLabel,
        height: 1.47,
      );

  /// 15pt Semibold — Subheadline semibold
  static TextStyle get subheadlineSemibold => _sf(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.24,
        color: AppColors.label,
        height: 1.47,
      );

  // ── Small ──────────────────────────────────────────────

  /// 13pt Regular — iOS Footnote
  static TextStyle get footnote => _sf(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.08,
        color: AppColors.secondaryLabel,
        height: 1.54,
      );

  /// 13pt Semibold — Footnote semibold
  static TextStyle get footnoteSemibold => _sf(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.08,
        color: AppColors.label,
        height: 1.54,
      );

  /// 12pt Regular — iOS Caption 1
  static TextStyle get caption1 => _sf(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        color: AppColors.secondaryLabel,
        height: 1.33,
      );

  /// 12pt Medium — Caption 1 medium
  static TextStyle get caption1Medium => _sf(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0,
        color: AppColors.secondaryLabel,
        height: 1.33,
      );

  /// 11pt Regular — iOS Caption 2
  static TextStyle get caption2 => _sf(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.07,
        color: AppColors.tertiaryLabel,
        height: 1.36,
      );

  // ── Special / UI ───────────────────────────────────────

  /// Button label — 17pt Semibold (iOS action button style)
  static TextStyle get buttonLabel => _sf(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: Colors.white,
        height: 1.29,
      );

  /// Tab bar label — 10pt Medium
  static TextStyle get tabLabel => _sf(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.12,
        color: AppColors.secondaryLabel,
        height: 1.4,
      );

  /// HOME YOGA wordmark — 28pt Bold, Apple product-name tracking.
  ///
  /// Above 20pt the Apple system font switches to SF Pro Display, so on iOS
  /// and macOS this is the same face Apple sets its own product names in.
  /// Tracking is kept near zero (0.4, matching the HIG Large Title value)
  /// because Apple sets wordmarks tight — SF Pro Display is already drawn
  /// with the spacing it wants, and letter-spacing it out fights the design.
  static TextStyle get wordmark => _sf(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: AppColors.label,
        height: 1.15,
      );

  /// Wordmark tagline — 11pt, tracked just enough to read as an eyebrow
  /// label under the wordmark without drifting back into wide letter-spacing.
  static TextStyle get wordmarkTagline => _sf(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.1,
        color: AppColors.tertiaryLabel,
        height: 1.36,
      );

  /// Navigation bar title — 17pt Semibold
  static TextStyle get navTitle => _sf(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.41,
        color: AppColors.label,
        height: 1.29,
      );
}
