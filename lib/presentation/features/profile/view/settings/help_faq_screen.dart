import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extension.dart';
import 'widgets/settings_kit.dart';

/// Help & FAQ — answers to the questions the app's own flow raises.
class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.faqScreenTitle,
      children: [
        SettingsGroup(
          header: l10n.faqSectionPractice,
          children: [
            SettingsFaqRow(
              question: l10n.faqQ1,
              answer: l10n.faqA1,
            ),
            SettingsFaqRow(
              question: l10n.faqQ2,
              answer: l10n.faqA2,
            ),
            SettingsFaqRow(
              question: l10n.faqQ3,
              answer: l10n.faqA3,
            ),
          ],
        ),
        SettingsGroup(
          header: l10n.faqSectionProgress,
          children: [
            SettingsFaqRow(
              question: l10n.faqQ4,
              answer: l10n.faqA4,
            ),
            SettingsFaqRow(
              question: l10n.faqQ5,
              answer: l10n.faqA5,
            ),
          ],
        ),
        SettingsGroup(
          header: l10n.faqSectionPro,
          children: [
            SettingsFaqRow(
              question: l10n.faqQ6,
              answer: l10n.faqA6,
            ),
            SettingsFaqRow(
              question: l10n.faqQ7,
              answer: l10n.faqA7,
            ),
          ],
        ),
      ],
    );
  }
}
