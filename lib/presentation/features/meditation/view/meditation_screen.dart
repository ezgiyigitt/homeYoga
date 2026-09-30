import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../shared/widgets/hy_button.dart';
import '../viewmodel/meditation_viewmodel.dart';

/// Sound meditation — ambient/frequency audio paired with a rotating text
/// mantra instead of voice narration (see ENDLESS_PLAN.md follow-up:
/// "mantra/meditation section"). Always reachable from Home via
/// CalmShortcutCard; not part of the daily-practice rotation.
///
/// Deliberately built with plain Flutter animations (AnimationController +
/// AnimatedContainer), not Flame — this is a simple looping scale/opacity
/// effect, exactly the kind of thing the Flutter side of the app should
/// own; Flame stays reserved for the real exercise/animation scenes.
class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breatheController;

  @override
  void initState() {
    super.initState();
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(meditationViewModelProvider);
    final vm = ref.read(meditationViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.systemGroupedBackground,
        elevation: 0,
        title: Text('Sound Meditation', style: AppTypography.headline),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.md),
                  _CategoryChips(
                    selected: state.selectedCategory,
                    onSelect: vm.selectCategory,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: _breatheController,
                        builder: (context, child) {
                          final scale = 0.85 + (_breatheController.value * 0.25);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.35),
                                AppColors.primary.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(alpha: 0.15),
                              ),
                              child: Icon(
                                state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 40,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: Text(
                        state.mantra,
                        key: ValueKey(state.mantra),
                        textAlign: TextAlign.center,
                        style: AppTypography.title3.copyWith(color: AppColors.label),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.currentTrack != null) _TrackInfo(state: state),
                  const SizedBox(height: AppSpacing.lg),
                  GestureDetector(
                    onTap: state.currentTrack == null ? null : vm.togglePlay,
                    child: AnimatedScale(
                      scale: state.isPlaying ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: Icon(
                          state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
                    child: HYButton(
                      label: state.isSaving ? 'Saving...' : 'Finish',
                      onPressed: state.isSaving
                          ? null
                          : () async {
                              await vm.finish();
                              if (context.mounted) context.pop();
                            },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        children: AppConstants.meditationCategories.map((category) {
          final isSelected = category == selected;
          final emoji = AppConstants.meditationCategoryEmojis[category] ?? '';
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelect(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.systemGray6,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  '$emoji $category',
                  style: AppTypography.footnoteSemibold.copyWith(
                    color: isSelected ? Colors.white : AppColors.secondaryLabel,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TrackInfo extends StatelessWidget {
  final MeditationState state;
  const _TrackInfo({required this.state});

  @override
  Widget build(BuildContext context) {
    final track = state.currentTrack!;
    return Column(
      children: [
        Text(track.title, style: AppTypography.headline),
        const SizedBox(height: 2),
        Text(
          [
            if (track.frequencyLabel != null) track.frequencyLabel!,
            track.durationLabel,
          ].join(' · '),
          style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
        ),
      ],
    );
  }
}
