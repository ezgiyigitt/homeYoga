import 'package:flutter/material.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/hy_card.dart';

/// Always-accessible entry point to sound meditation (mantra + frequency
/// audio) — deliberately NOT part of the daily-practice rotation, so it's
/// available any time the user wants to calm down, not just on the day
/// the algorithm happens to pick a Breathing clip.
class CalmShortcutCard extends StatelessWidget {
  final VoidCallback onTap;

  const CalmShortcutCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // onTap goes straight to HYCard now so it gets the shared card
    // press-scale animation instead of a plain, unanimated GestureDetector.
    return HYCard(
      onTap: onTap,
      color: AppColors.primaryMuted,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.waves_rounded,
              size: 22,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.calmCardTitle,
                    style: AppTypography.subheadlineSemibold),
                const SizedBox(height: 2),
                Text(
                  context.l10n.calmCardSubtitle,
                  style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}
