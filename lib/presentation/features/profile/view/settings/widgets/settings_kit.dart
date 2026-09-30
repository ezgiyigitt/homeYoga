import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/theme/app_typography.dart';

/// Shared building blocks for the Settings sub-screens.
///
/// Every settings screen in the app is the same shape: a grouped background,
/// one or more rounded cards, rows inside them, and a small explanatory
/// footer. Keeping that shape here means a new settings screen is a list of
/// rows rather than a fresh layout, and all of them stay consistent — and
/// all of them follow the appearance automatically, since every colour comes
/// from [AppColors].

/// Standard page frame for a settings screen.
class SettingsScaffold extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsScaffold({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTypography.navTitle,
        ),
        backgroundColor: AppColors.systemGroupedBackground,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.primary,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.md,
            AppSpacing.screenHorizontal,
            AppSpacing.xxxl,
          ),
          children: children,
        ),
      ),
    );
  }
}

/// A grouped card with an optional uppercase header and explanatory footer.
class SettingsGroup extends StatelessWidget {
  final String? header;
  final String? footer;
  final List<Widget> children;

  const SettingsGroup({
    super.key,
    this.header,
    this.footer,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                6,
              ),
              child: Text(
                header!.toUpperCase(),
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      indent: AppSpacing.md,
                      color: AppColors.separator,
                    ),
                  children[i],
                ],
              ],
            ),
          ),
          if (footer != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                8,
                AppSpacing.md,
                0,
              ),
              child: Text(
                footer!,
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tappable row: icon, title, optional subtitle, optional trailing widget.
class SettingsRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final String? value;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.value,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final tint = isDestructive ? AppColors.destructive : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 13,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 21, color: tint),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.body.copyWith(
                        color: isDestructive
                            ? AppColors.destructive
                            : AppColors.label,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.caption1.copyWith(
                          color: AppColors.secondaryLabel,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Text(
                  value!,
                  style: AppTypography.body
                      .copyWith(color: AppColors.secondaryLabel),
                ),
              ],
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
              ] else if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.tertiaryLabel,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A row whose trailing control is a switch.
class SettingsSwitchRow extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingsSwitchRow({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsRow(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

/// A block of body copy inside a settings card — used by the legal and help
/// screens, where the content is prose rather than controls.
class SettingsProse extends StatelessWidget {
  final String? heading;
  final String body;

  const SettingsProse({super.key, this.heading, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading != null) ...[
            Text(heading!, style: AppTypography.subheadlineSemibold),
            const SizedBox(height: 6),
          ],
          Text(
            body,
            style: AppTypography.subheadline.copyWith(
              color: AppColors.secondaryLabel,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

/// An expandable question used on the Help & FAQ screen.
class SettingsFaqRow extends StatefulWidget {
  final String question;
  final String answer;

  const SettingsFaqRow({
    super.key,
    required this.question,
    required this.answer,
  });

  @override
  State<SettingsFaqRow> createState() => _SettingsFaqRowState();
}

class _SettingsFaqRowState extends State<SettingsFaqRow> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 13,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTypography.body,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.tertiaryLabel,
                    ),
                  ),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, right: 24),
                        child: Text(
                          widget.answer,
                          style: AppTypography.subheadline.copyWith(
                            color: AppColors.secondaryLabel,
                            height: 1.45,
                          ),
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
