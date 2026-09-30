import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/hy_button.dart';
import '../../../shared/widgets/rewarded_ad_dialog.dart';

/// Paywall modal presented when a user views or purchases AI voiceover.
class ProVoiceoverSheet extends ConsumerWidget {
  const ProVoiceoverSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProVoiceoverSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(localStorageProvider).isPro;
    final l10n = context.l10n;
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: size.height * (isLandscape ? 0.94 : 0.88),
          maxWidth: 520,
        ),
        decoration: BoxDecoration(
          color: AppColors.systemBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppSpacing.sm),
              // Drag handle
              Container(
                width: 36,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.systemGray4,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.screenHorizontal,
                    isLandscape ? AppSpacing.xs : AppSpacing.md,
                    AppSpacing.screenHorizontal,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Badge Icon
                      Container(
                        width: isLandscape ? 48 : 64,
                        height: isLandscape ? 48 : 64,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPro
                                ? [
                                    AppColors.systemGreen.withValues(alpha: 0.2),
                                    AppColors.systemGreen.withValues(alpha: 0.08)
                                  ]
                                : [AppColors.primaryContainer, AppColors.primaryMuted],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            isPro ? Icons.verified_rounded : Icons.headphones_rounded,
                            size: isLandscape ? 24 : 32,
                            color: isPro ? AppColors.systemGreen : AppColors.primaryDark,
                          ),
                        ),
                      ),
                      SizedBox(height: isLandscape ? AppSpacing.xs : AppSpacing.md),

                      // Title & Subtitle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('HomeYoga', style: isLandscape ? AppTypography.title3 : AppTypography.title2),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.systemGreen,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.systemGreen.withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isPro) ...[
                                  const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  isPro ? l10n.playerProPurchased.toUpperCase() : 'PRO',
                                  style: AppTypography.caption2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.proSheetTitle,
                        style: AppTypography.subheadline.copyWith(
                          color: AppColors.secondaryLabel,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: isLandscape ? AppSpacing.md : AppSpacing.xl),

                      // Benefits list
                      _buildBenefit(
                        icon: Icons.record_voice_over_rounded,
                        title: l10n.proSheetBenefit1Title,
                        description: l10n.proSheetBenefit1Desc,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildBenefit(
                        icon: Icons.self_improvement_rounded,
                        title: l10n.proSheetBenefit2Title,
                        description: l10n.proSheetBenefit2Desc,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildBenefit(
                        icon: Icons.all_inclusive_rounded,
                        title: l10n.proSheetBenefit3Title,
                        description: l10n.proSheetBenefit3Desc,
                      ),
                      SizedBox(height: isLandscape ? AppSpacing.md : AppSpacing.xl),

                      // Pricing or Active Subscription Card
                      if (!isPro)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primaryMuted,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n.proSheetMonthly, style: AppTypography.subheadlineSemibold),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.proSheetCancelAnytime,
                                      style: AppTypography.caption2.copyWith(color: AppColors.secondaryLabel),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '300 ₺',
                                    style: AppTypography.title2.copyWith(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '/ ay',
                                    style: AppTypography.caption2.copyWith(color: AppColors.secondaryLabel),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.systemGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.systemGreen.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.systemGreen.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified_rounded,
                                  size: 26,
                                  color: AppColors.systemGreen,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.proSheetActiveTitle,
                                      style: AppTypography.subheadlineSemibold.copyWith(
                                        color: AppColors.label,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      l10n.proSheetActiveDesc,
                                      style: AppTypography.caption2.copyWith(
                                        color: AppColors.secondaryLabel,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: isLandscape ? AppSpacing.md : AppSpacing.lg),

                      // Action Buttons
                      if (!isPro) ...[
                        if (!ref.watch(localStorageProvider).hasUsedVoiceoverTrial) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                await RewardedAdDialog.show(
                                  context,
                                  rewardTitle: 'Pro Sesli Rehber (1 Seans Deneme)',
                                  onRewardEarned: () async {
                                    final local = ref.read(localStorageProvider);
                                    await local.setUsedVoiceoverTrial();
                                    if (context.mounted) {
                                      Navigator.of(context).pop(true);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  l10n.playerVoiceoverTrialUnlockedSnackbar,
                                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: AppColors.systemGreen,
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                              icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 20),
                              label: Text(
                                l10n.playerVoiceoverAdTrialButton,
                                style: AppTypography.subheadlineSemibold.copyWith(
                                  color: AppColors.primaryDark,
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                side: const BorderSide(color: AppColors.primary, width: 1.5),
                                backgroundColor: AppColors.primaryMuted,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ] else ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.systemGray6,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.separator),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 16, color: AppColors.secondaryLabel),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n.playerVoiceoverTrialUsedNote,
                                    style: AppTypography.caption2.copyWith(color: AppColors.secondaryLabel),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        HYButton(
                          label: l10n.proSheetStartSubscription,
                          onPressed: () async {
                            final local = ref.read(localStorageProvider);
                            await local.setPro(true);
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            l10n.proSheetContinueWithout,
                            style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                          ),
                        ),
                      ] else ...[
                        HYButton(
                          label: l10n.proSheetDismissActive,
                          onPressed: () => Navigator.of(context).pop(true),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        TextButton(
                          onPressed: () async {
                            final local = ref.read(localStorageProvider);
                            await local.setPro(false);
                            if (context.mounted) {
                              Navigator.of(context).pop(false);
                            }
                          },
                          child: Text(
                            'Aboneliği Sıfırla (Test)',
                            style: AppTypography.caption2.copyWith(
                              color: AppColors.secondaryLabel.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryMuted,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.subheadlineSemibold),
              const SizedBox(height: 2),
              Text(
                description,
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
