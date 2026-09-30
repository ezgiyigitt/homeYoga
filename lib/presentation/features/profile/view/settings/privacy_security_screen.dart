import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/extensions/context_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/result.dart';
import '../../../../shared/providers/app_providers.dart';
import 'widgets/settings_kit.dart';

/// What the app stores, where it lives, data deletion and account termination.
class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final email = ref.watch(localStorageProvider).email ?? '—';

    return SettingsScaffold(
      title: l10n.privacyScreenTitle,
      children: [
        SettingsGroup(
          header: l10n.privacySectionAccount,
          children: [
            SettingsRow(
              icon: Icons.mail_outline_rounded,
              title: l10n.privacySignedInAs,
              subtitle: email,
            ),
            SettingsRow(
              icon: Icons.lock_outline_rounded,
              title: l10n.privacyPasswordTitle,
              subtitle: l10n.privacyPasswordSubtitle,
            ),
          ],
        ),
        SettingsGroup(
          header: l10n.privacySectionStorage,
          children: [
            SettingsProse(
              heading: l10n.privacyDeviceHeading,
              body: l10n.privacyDeviceBody,
            ),
            SettingsProse(
              heading: l10n.privacyServerHeading,
              body: l10n.privacyServerBody,
            ),
            SettingsProse(
              heading: l10n.privacyAiHeading,
              body: l10n.privacyAiBody,
            ),
          ],
        ),
        SettingsGroup(
          header: l10n.privacySectionActions,
          children: [
            SettingsRow(
              icon: Icons.cleaning_services_outlined,
              title: l10n.settingsClearDataTitle,
              isDestructive: true,
              onTap: () => _confirmClear(context, ref),
            ),
            SettingsRow(
              icon: Icons.person_remove_rounded,
              title: l10n.settingsDeleteAccountTitle,
              subtitle: l10n.settingsDeleteAccountSubtitle,
              isDestructive: true,
              onTap: () => _confirmDeleteAccount(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.settingsClearDataDialogTitle),
        content: Text(l10n.settingsClearDataDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.settingsClearDataConfirmButton,
              style: const TextStyle(
                color: AppColors.systemRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(localStorageProvider).clearProgressData();
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.settingsClearDataSuccessSnackbar)),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.settingsDeleteAccountDialogTitle),
        content: Text(l10n.settingsDeleteAccountDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: AppColors.secondaryLabel),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.settingsDeleteAccountConfirmButton,
              style: const TextStyle(
                color: AppColors.systemRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    final deleteUseCase = ref.read(deleteAccountUseCaseProvider);
    final result = await deleteUseCase();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // dismiss loading

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.settingsDeleteAccountSuccessSnackbar),
            backgroundColor: AppColors.systemGreen,
          ),
        );
        context.go('/login');
      case Failure(message: final msg):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: AppColors.systemRed,
          ),
        );
    }
  }
}
