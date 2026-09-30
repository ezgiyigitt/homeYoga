import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import 'hy_lotus_mark.dart';

/// HOME YOGA logo — lotus + text mark.
///
/// The bloom and the wordmark are coloured separately, the way most
/// marks are built: the lotus carries the brand's deep sage so it sits
/// in the same family as the rest of the app, while the wordmark stays
/// neutral and quiet underneath it.
class HYLogo extends StatelessWidget {
  final double fontSize;

  /// Colour of the HOME YOGA wordmark. Null follows the appearance, so the
  /// wordmark is black in light mode and white in dark mode.
  final Color? color;

  /// Colour of the lotus bloom. Null uses the brand's deep sage.
  final Color? markColor;

  final bool showTagline;

  const HYLogo({
    super.key,
    this.fontSize = 28,
    this.color,
    this.markColor,
    this.showTagline = false,
  });

  const HYLogo.white({
    super.key,
    this.fontSize = 28,
    this.showTagline = false,
  })  : color = Colors.white,
        markColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    final wordmarkColor = color ?? AppColors.label;
    final bloomColor = markColor ?? AppColors.primaryDarkFixed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Lotus mark — drawn as vector paths, not an emoji, so it scales
        // cleanly and renders identically on every platform.
        HYLotusMark(
          size: fontSize * 1.7,
          color: bloomColor,
        ),
        const SizedBox(height: 10),
        Text(
          'HOME YOGA',
          style: AppTypography.wordmark.copyWith(
            color: wordmarkColor,
            fontSize: fontSize,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 4),
          Text(
            'WELLNESS · MOVEMENT',
            style: AppTypography.wordmarkTagline.copyWith(
              color: wordmarkColor.withAlpha(160),
            ),
          ),
        ],
      ],
    );
  }
}
