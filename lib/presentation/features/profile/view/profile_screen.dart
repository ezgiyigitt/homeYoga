import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../viewmodel/profile_viewmodel.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../shared/providers/app_providers.dart';
import '../../workout/widgets/pro_voiceover_sheet.dart';

/// Instagram-style "Settings and activity" screen.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(profileViewModelProvider);
    final profile = state.profile;
    final isPro = ref.watch(localStorageProvider).isPro;

    final firstName = profile?.firstName ?? '';
    final lastName = profile?.lastName ?? '';
    final fullName = (firstName.isEmpty && lastName.isEmpty)
        ? l10n.settingsMemberFallbackName
        : '$firstName $lastName'.trim();
    final email = ref.watch(localStorageProvider).email ?? '';

    return Scaffold(
      backgroundColor: AppColors.systemBackground,
      appBar: AppBar(
        title: Text(
          l10n.settingsTitle,
          style: TextStyle(
            color: AppColors.label,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.systemBackground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        children: [
          const SizedBox(height: AppSpacing.xs),

          // ── Instagram Search Bar ──────────────────────────────────────────
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.systemGray6,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AppColors.secondaryLabel, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim().toLowerCase();
                      });
                    },
                    style: AppTypography.subheadline,
                    decoration: InputDecoration(
                      hintText: l10n.settingsSearchHint,
                      hintStyle: TextStyle(
                          color: AppColors.tertiaryLabel, fontSize: 15),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Icon(Icons.cancel_rounded,
                        color: AppColors.secondaryLabel, size: 18),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── User Profile Card ─────────────────────────────────────────────
          if (_searchQuery.isEmpty) ...[
            _buildUserProfileCard(
              context: context,
              fullName: fullName,
              email: email,
              isPro: isPro,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // ── Settings Sections ─────────────────────────────────────────────
          ..._buildFilteredSections(context, isPro),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard({
    required BuildContext context,
    required String fullName,
    required String email,
    required bool isPro,
  }) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.separator, width: 0.6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: InkWell(
        onTap: () => context.push('/profile/${RouteNames.profilePersonalInfo}'),
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                fullName.isNotEmpty ? fullName[0].toUpperCase() : 'Y',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          fullName,
                          style: AppTypography.title3.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isPro) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.settingsBadgePro,
                            style: AppTypography.caption2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    email.isNotEmpty ? email : l10n.settingsEditProfileHint,
                    style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, color: AppColors.secondaryLabel, size: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilteredSections(BuildContext context, bool isPro) {
    final l10n = context.l10n;
    final sections = [
      _SettingsGroup(
        header: l10n.settingsGroupTraining,
        items: [
          _SettingsItem(
            icon: Icons.star_border_rounded,
            title: l10n.settingsProTitle,
            subtitle: isPro
                ? l10n.settingsProSubtitleActive
                : l10n.settingsProSubtitleInactive,
            badgeText: isPro ? l10n.settingsBadgeActive : '₺300',
            badgeColor: isPro ? AppColors.systemGreen : AppColors.primary,
            onTap: () => ProVoiceoverSheet.show(context),
          ),
          _SettingsItem(
            icon: Icons.track_changes_rounded,
            title: l10n.settingsGoalsTitle,
            subtitle: l10n.settingsGoalsSubtitle,
            onTap: () =>
                context.push('/profile/${RouteNames.profileFitnessGoals}'),
          ),
          _SettingsItem(
            icon: Icons.notifications_none_rounded,
            title: l10n.settingsNotificationsTitle,
            subtitle: l10n.settingsNotificationsSubtitle,
            onTap: () =>
                context.push('/profile/${RouteNames.profileNotifications}'),
          ),
        ],
      ),
      _SettingsGroup(
        header: l10n.settingsGroupPreferences,
        items: [
          _SettingsItem(
            icon: Icons.dark_mode_outlined,
            title: l10n.settingsAppearanceTitle,
            subtitle: l10n.settingsAppearanceSubtitle,
            onTap: () =>
                context.push('/profile/${RouteNames.profileAppearance}'),
          ),
          _SettingsItem(
            icon: Icons.language_rounded,
            title: l10n.settingsLanguageTitle,
            subtitle: l10n.settingsLanguageSubtitle,
            onTap: () =>
                context.push('/profile/${RouteNames.profileLanguage}'),
          ),
          _SettingsItem(
            icon: Icons.volume_up_outlined,
            title: l10n.settingsSoundTitle,
            subtitle: l10n.settingsSoundSubtitle,
            onTap: () => context.push('/profile/${RouteNames.profileSound}'),
          ),
        ],
      ),
      _SettingsGroup(
        header: l10n.settingsGroupAccount,
        items: [
          _SettingsItem(
            icon: Icons.person_outline_rounded,
            title: l10n.settingsPersonalInfoTitle,
            subtitle: l10n.settingsPersonalInfoSubtitle,
            onTap: () =>
                context.push('/profile/${RouteNames.profilePersonalInfo}'),
          ),
          _SettingsItem(
            icon: Icons.lock_outline_rounded,
            title: l10n.settingsPrivacyTitle,
            subtitle: l10n.settingsPrivacySubtitle,
            onTap: () =>
                context.push('/profile/${RouteNames.profilePrivacy}'),
          ),
        ],
      ),
      _SettingsGroup(
        header: l10n.settingsGroupSupport,
        items: [
          _SettingsItem(
            icon: Icons.help_outline_rounded,
            title: l10n.settingsHelpTitle,
            subtitle: l10n.settingsHelpSubtitle,
            onTap: () => context.push('/profile/${RouteNames.profileHelp}'),
          ),
          _SettingsItem(
            icon: Icons.description_outlined,
            title: l10n.settingsLegalTitle,
            subtitle: l10n.settingsLegalSubtitle,
            onTap: () => context.push('/profile/${RouteNames.profileLegal}'),
          ),
          _SettingsItem(
            icon: Icons.info_outline_rounded,
            title: l10n.settingsAboutTitle,
            subtitle: l10n.settingsAboutSubtitle('1.0.0', '2026'),
            onTap: () => context.push('/profile/${RouteNames.profileAbout}'),
          ),
        ],
      ),
      _SettingsGroup(
        header: l10n.settingsGroupSession,
        items: [
          _SettingsItem(
            icon: Icons.logout_rounded,
            title: l10n.settingsSignOut,
            isDestructive: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    ];

    final widgets = <Widget>[];

    for (final group in sections) {
      final matchingItems = _searchQuery.isEmpty
          ? group.items
          : group.items.where((it) {
              return it.title.toLowerCase().contains(_searchQuery) ||
                  (it.subtitle?.toLowerCase().contains(_searchQuery) ?? false);
            }).toList();

      if (matchingItems.isNotEmpty) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(
                left: 4, top: AppSpacing.md, bottom: AppSpacing.xs),
            child: Text(
              group.header,
              style: AppTypography.caption1.copyWith(
                color: AppColors.secondaryLabel,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                fontSize: 12,
              ),
            ),
          ),
        );

        widgets.add(
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.separator, width: 0.6),
            ),
            child: Column(
              children: [
                for (int i = 0; i < matchingItems.length; i++) ...[
                  _buildInstagramTile(matchingItems[i]),
                  if (i < matchingItems.length - 1)
                    Divider(
                        height: 1, indent: 48, color: AppColors.separator),
                ],
              ],
            ),
          ),
        );

        widgets.add(const SizedBox(height: AppSpacing.md));
      }
    }

    if (widgets.isEmpty && _searchQuery.isNotEmpty) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Center(
            child: Text(
              l10n.settingsNoResults(_searchQuery),
              style: AppTypography.subheadline
                  .copyWith(color: AppColors.secondaryLabel),
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildInstagramTile(_SettingsItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 22,
              color: item.isDestructive ? AppColors.systemRed : AppColors.label,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.subheadline.copyWith(
                      color: item.isDestructive
                          ? AppColors.systemRed
                          : AppColors.label,
                      fontWeight: item.isDestructive
                          ? FontWeight.bold
                          : FontWeight.w500,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle!,
                      style: AppTypography.caption1
                          .copyWith(color: AppColors.secondaryLabel),
                    ),
                  ],
                ],
              ),
            ),
            if (item.badgeText != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: item.badgeColor ?? AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.badgeText!,
                  style: AppTypography.caption2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (!item.isDestructive)
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.tertiaryLabel, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.settingsSignOutDialogTitle),
        content: Text(l10n.settingsSignOutDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonCancel,
                style: TextStyle(color: AppColors.secondaryLabel)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authViewModelProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              l10n.settingsSignOut,
              style: const TextStyle(
                  color: AppColors.systemRed, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup {
  final String header;
  final List<_SettingsItem> items;

  const _SettingsGroup({required this.header, required this.items});
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final Color? badgeColor;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.badgeColor,
    this.isDestructive = false,
    required this.onTap,
  });
}
