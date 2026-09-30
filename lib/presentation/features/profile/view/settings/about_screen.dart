import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/widgets/hy_logo.dart';
import 'widgets/settings_kit.dart';

/// About Home Yoga — what it is, which build this is, and how to reach us.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.aboutScreenTitle,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: AppSpacing.lg,
            bottom: AppSpacing.xl,
          ),
          child: Column(
            children: [
              const HYLogo(fontSize: 24, showTagline: true),
              const SizedBox(height: AppSpacing.md),
              Text(
                '${l10n.aboutScreenVersion} 1.0.0 (${l10n.aboutScreenBuild} 2026)',
                style: AppTypography.caption1
                    .copyWith(color: AppColors.secondaryLabel),
              ),
            ],
          ),
        ),
        SettingsGroup(
          children: [
            SettingsProse(
              body: l10n.aboutScreenTagline,
            ),
          ],
        ),
        SettingsGroup(
          header: l10n.aboutScreenSupportHeader,
          children: [
            SettingsRow(
              icon: Icons.alternate_email_rounded,
              title: l10n.aboutScreenEmailSupport,
              subtitle: 'support@homeyoga.app',
            ),
            SettingsRow(
              icon: Icons.info_outline_rounded,
              title: l10n.aboutScreenVersion,
              value: '1.0.0',
            ),
            SettingsRow(
              icon: Icons.tag_rounded,
              title: l10n.aboutScreenBuild,
              value: '2026',
            ),
          ],
        ),
        SettingsGroup(
          header: l10n.aboutScreenCreditsHeader,
          children: [
            SettingsProse(
              body: l10n.aboutScreenCreditsBody,
            ),
          ],
        ),
      ],
    );
  }
}
