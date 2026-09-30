import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/settings_provider.dart';
import 'widgets/settings_kit.dart';

/// Audio and playback preferences for the workout player.
class SoundScreen extends ConsumerWidget {
  const SoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return SettingsScaffold(
      title: 'Sound & Effects',
      children: [
        SettingsGroup(
          header: 'Voice coaching',
          footer: 'The voice guide talks you through each pose so you can '
              'stay on the mat instead of watching the screen.',
          children: [
            SettingsSwitchRow(
              icon: Icons.record_voice_over_outlined,
              title: 'Voice guide',
              value: settings.voiceGuideEnabled,
              onChanged: notifier.setVoiceGuideEnabled,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                4,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Volume', style: AppTypography.body),
                      const Spacer(),
                      Text(
                        '${(settings.voiceVolume * 100).round()}%',
                        style: AppTypography.body
                            .copyWith(color: AppColors.secondaryLabel),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.voiceVolume,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.systemGray5,
                    onChanged: settings.voiceGuideEnabled
                        ? notifier.setVoiceVolume
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
        SettingsGroup(
          header: 'Playback',
          footer: 'Turn autoplay off if you would rather start each pose '
              'video yourself.',
          children: [
            SettingsSwitchRow(
              icon: Icons.graphic_eq_rounded,
              title: 'Sound effects',
              subtitle: 'Timer chimes and completion sounds',
              value: settings.soundEffectsEnabled,
              onChanged: notifier.setSoundEffectsEnabled,
            ),
            SettingsSwitchRow(
              icon: Icons.play_circle_outline_rounded,
              title: 'Autoplay pose videos',
              value: settings.autoplayVideo,
              onChanged: notifier.setAutoplayVideo,
            ),
          ],
        ),
      ],
    );
  }
}
