import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/onboarding_viewmodel.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';

class StepEquipment extends ConsumerWidget {
  const StepEquipment({super.key});

  static const Map<String, String> _equipmentEmojis = {
    'No Equipment': '🙌',
    'Yoga Mat': '🟪',
    'Resistance Band': '🔁',
    'Pilates Ball': '🔵',
    'Dumbbell': '🏋️',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingViewModelProvider).equipment;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Equipment', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'What do you have available? Select all that apply.',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: AppConstants.equipment.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final isSelected = selected.contains(item);
                final isLast = i == AppConstants.equipment.length - 1;
                return _EquipmentCell(
                  label: item,
                  emoji: _equipmentEmojis[item] ?? '✅',
                  isSelected: isSelected,
                  showDivider: !isLast,
                  onTap: () => vm.toggleEquipment(item),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _EquipmentCell extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onTap;

  const _EquipmentCell({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            color: isSelected ? AppColors.primaryMuted : Colors.transparent,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 14,
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.calloutMedium.copyWith(
                      color: isSelected ? AppColors.primaryDark : AppColors.label,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: isSelected
                      ? const Icon(
                          Icons.check_box_rounded,
                          color: AppColors.primary,
                          size: 22,
                          key: ValueKey('c'),
                        )
                      : Icon(
                          Icons.check_box_outline_blank_rounded,
                          color: AppColors.systemGray4,
                          size: 22,
                          key: const ValueKey('u'),
                        ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.separator,
            indent: 56,
          ),
      ],
    );
  }
}

// ── Step 7 — Preferred Time ─────────────────────────────────────

class StepPreferredTime extends ConsumerWidget {
  const StepPreferredTime({super.key});

  static const _times = [
    _TimeOption('Morning', '☀️', 'Start the day energised'),
    _TimeOption('Afternoon', '🌤', 'Midday movement break'),
    _TimeOption('Evening', '🌙', 'Wind down and recover'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(onboardingViewModelProvider).preferredTime;
    final vm = ref.read(onboardingViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Preferred\nTime', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'When do you prefer to exercise?',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: _times.asMap().entries.map((e) {
                final i = e.key;
                final t = e.value;
                final isSelected = selected == t.label;
                final isLast = i == _times.length - 1;
                return Column(
                  children: [
                    InkWell(
                      onTap: () => vm.setPreferredTime(t.label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        color: isSelected
                            ? AppColors.primaryMuted
                            : Colors.transparent,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Text(t.emoji,
                                style: const TextStyle(fontSize: 28)),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.label,
                                    style: AppTypography.calloutMedium.copyWith(
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.label,
                                    ),
                                  ),
                                  Text(t.subtitle,
                                      style: AppTypography.caption1),
                                ],
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: AppColors.primary,
                                      size: 22,
                                      key: ValueKey('c'),
                                    )
                                  : Icon(
                                      Icons.radio_button_unchecked_rounded,
                                      color: AppColors.systemGray4,
                                      size: 22,
                                      key: const ValueKey('u'),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        color: AppColors.separator,
                        indent: 60,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _TimeOption {
  final String label;
  final String emoji;
  final String subtitle;

  const _TimeOption(this.label, this.emoji, this.subtitle);
}

// ── Step 8 — Limitations ────────────────────────────────────────

class StepLimitations extends ConsumerStatefulWidget {
  const StepLimitations({super.key});

  @override
  ConsumerState<StepLimitations> createState() => _StepLimitationsState();
}

class _StepLimitationsState extends ConsumerState<StepLimitations> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: ref.read(onboardingViewModelProvider).limitations,
    )..addListener(() {
        ref
            .read(onboardingViewModelProvider.notifier)
            .setLimitations(_ctrl.text.isEmpty ? null : _ctrl.text);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Any\nLimitations?', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Optional — share any physical limitations so we can suggest appropriate exercises.',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryGroupedBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: TextField(
                controller: _ctrl,
                maxLines: 5,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText:
                      'e.g. lower back pain, knee injury, avoid high impact...',
                  hintStyle: AppTypography.body.copyWith(
                    color: AppColors.tertiaryLabel,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.systemYellow.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.systemYellow),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Home Yoga is not a medical service. Consult a healthcare professional for medical advice.',
                    style: AppTypography.caption1.copyWith(
                      color: AppColors.systemGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
