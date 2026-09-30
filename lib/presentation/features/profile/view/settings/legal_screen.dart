import 'package:flutter/material.dart';

import '../../../../../core/extensions/context_extension.dart';
import 'widgets/settings_kit.dart';

/// Terms of Use and Privacy Policy.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsScaffold(
      title: l10n.legalScreenTitle,
      children: [
        SettingsGroup(
          children: [
            SettingsProse(
              heading: l10n.legalTermsHeading,
              body: l10n.legalTermsBody,
            ),
            SettingsProse(
              heading: l10n.legalHealthHeading,
              body: l10n.legalHealthBody,
            ),
            SettingsProse(
              heading: l10n.legalSubHeading,
              body: l10n.legalSubBody,
            ),
          ],
        ),
        SettingsGroup(
          children: [
            SettingsProse(
              heading: l10n.legalPrivacyHeading,
              body: l10n.legalPrivacyBody,
            ),
            SettingsProse(
              heading: l10n.legalRightsHeading,
              body: l10n.legalRightsBody,
            ),
          ],
        ),
      ],
    );
  }
}
