import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/locale_provider.dart';

/// Language picker, laid out to match [AppearanceScreen] so the two
/// preference screens read as a pair.
///
/// The view is a thin shell: it renders whatever [appLanguageProvider]
/// currently holds and reports taps back to the notifier, which owns both
/// the state and its persistence.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(appLanguageProvider);

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: AppBar(
        title: Text(
          l10n.settingsLanguageTitle,
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
              l10n.settingsLanguageTitle.toUpperCase(),
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
                _LanguageTile(
                  title: 'Türkçe',
                  subtitle: 'Turkish',
                  icon: Icons.translate_rounded,
                  iconColor: AppColors.primary,
                  isSelected: selected == AppLanguage.turkish,
                  onTap: () => ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.turkish),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _LanguageTile(
                  title: 'English',
                  subtitle: 'İngilizce',
                  icon: Icons.translate_rounded,
                  iconColor: Colors.indigo.shade300,
                  isSelected: selected == AppLanguage.english,
                  onTap: () => ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.english),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _LanguageTile(
                  title: 'Français',
                  subtitle: 'French / Fransızca',
                  icon: Icons.translate_rounded,
                  iconColor: Colors.teal.shade300,
                  isSelected: selected == AppLanguage.french,
                  onTap: () => ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.french),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _LanguageTile(
                  title: 'Español',
                  subtitle: 'Spanish / İspanyolca',
                  icon: Icons.translate_rounded,
                  iconColor: Colors.amber.shade700,
                  isSelected: selected == AppLanguage.spanish,
                  onTap: () => ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.spanish),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _LanguageTile(
                  title: '中文 (简体)',
                  subtitle: 'Chinese / Çince',
                  icon: Icons.translate_rounded,
                  iconColor: Colors.deepOrange.shade300,
                  isSelected: selected == AppLanguage.chinese,
                  onTap: () => ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.chinese),
                ),
                Divider(height: 1, indent: 52, color: AppColors.separator),
                _LanguageTile(
                  title: l10n.languageNameSystem,
                  subtitle: l10n.languageSystemSubtitle,
                  icon: Icons.phone_iphone_rounded,
                  iconColor: AppColors.secondaryLabel,
                  isSelected: selected == AppLanguage.system,
                  onTap: () => ref
                      .read(appLanguageProvider.notifier)
                      .setLanguage(AppLanguage.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                    style: AppTypography.caption1
                        .copyWith(color: AppColors.secondaryLabel),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 22)
            else
              Icon(Icons.circle_outlined,
                  color: AppColors.separator, size: 22),
          ],
        ),
      ),
    );
  }
}
