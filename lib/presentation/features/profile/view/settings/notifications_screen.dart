import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../shared/providers/settings_provider.dart';
import 'widgets/settings_kit.dart';

/// Reminder preferences: when the user wants to be nudged onto the mat.
///
/// The choices are stored locally and read back on launch. Delivering the
/// reminder itself needs a notification plugin plus per-platform permission
/// setup, which is not wired up yet — the footer says so rather than letting
/// the screen imply an alert that will never arrive.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return SettingsScaffold(
      title: 'Notifications',
      children: [
        SettingsGroup(
          header: 'Daily reminder',
          footer: 'A gentle nudge at the time you normally practise. '
              'You can always mark a day as a rest day instead.',
          children: [
            SettingsSwitchRow(
              icon: Icons.notifications_active_outlined,
              title: 'Practice reminder',
              value: settings.remindersEnabled,
              onChanged: notifier.setRemindersEnabled,
            ),
            SettingsRow(
              icon: Icons.schedule_rounded,
              title: 'Time',
              value: settings.reminderTimeLabel,
              onTap: settings.remindersEnabled
                  ? () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: settings.reminderTime,
                      );
                      if (picked != null) notifier.setReminderTime(picked);
                    }
                  : null,
            ),
          ],
        ),
        if (settings.remindersEnabled)
          SettingsGroup(
            header: 'Repeat on',
            footer: settings.reminderDaysLabel,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    for (var i = 0; i < 7; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Expanded(
                        child: _DayToggle(
                          label: kWeekdayInitials[i],
                          selected: settings.reminderDays[i],
                          onTap: () => notifier.toggleReminderDay(i),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        SettingsGroup(
          header: 'Other nudges',
          footer: 'Scheduled delivery is not switched on in this build, so '
              'nothing is sent to your lock screen yet. Your choices here are '
              'saved and will be used as soon as it is.',
          children: [
            SettingsSwitchRow(
              icon: Icons.event_busy_outlined,
              title: 'Missed day nudge',
              subtitle: 'Remind me when a day goes by unmarked',
              value: settings.missedDayNudge,
              onChanged: notifier.setMissedDayNudge,
            ),
          ],
        ),
      ],
    );
  }
}

class _DayToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.systemGray5,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTypography.footnoteSemibold.copyWith(
              color: selected ? Colors.white : AppColors.secondaryLabel,
            ),
          ),
        ),
      ),
    );
  }
}
