import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/theme_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: AppBar(
        title: Text(
          l10n.settingsAppearanceTitle,
          style: TextStyle(
            color: AppColors.label,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.label),
          onPressed: () => context.pop(),
        ),
        backgroundColor: AppColors.systemGroupedBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.xs),
            child: Text(
              l10n.appearanceSectionTheme,
              style: AppTypography.caption1.copyWith(
                color: AppColors.secondaryLabel,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.separator, width: 0.6),
            ),
            child: Column(
              children: [
                _buildThemeTile(
                  context: context,
                  title: l10n.appearanceLightTitle,
                  subtitle: l10n.appearanceLightSubtitle,
                  icon: Icons.light_mode_rounded,
                  iconColor: Colors.amber.shade700,
                  isSelected: themeMode == ThemeMode.light,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _buildThemeTile(
                  context: context,
                  title: l10n.appearanceDarkTitle,
                  subtitle: l10n.appearanceDarkSubtitle,
                  icon: Icons.dark_mode_rounded,
                  iconColor: Colors.indigo.shade300,
                  isSelected: themeMode == ThemeMode.dark,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _buildThemeTile(
                  context: context,
                  title: l10n.appearanceSystemTitle,
                  subtitle: l10n.appearanceSystemSubtitle,
                  icon: Icons.brightness_auto_rounded,
                  iconColor: AppColors.primary,
                  isSelected: themeMode == ThemeMode.system,
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.subheadlineSemibold),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
            else
              Icon(Icons.circle_outlined, color: AppColors.separator, size: 22),
          ],
        ),
      ),
    );
  }
}
