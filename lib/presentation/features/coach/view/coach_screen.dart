import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/navigation/route_names.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../domain/entities/workout_entity.dart';
import '../../../../core/constants/pain_rules.dart';
import '../../home/viewmodel/home_viewmodel.dart';
import '../../workout/widgets/pro_voiceover_sheet.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/rewarded_ad_dialog.dart';
import '../viewmodel/coach_viewmodel.dart';

class CoachScreen extends ConsumerStatefulWidget {
  const CoachScreen({super.key});

  @override
  ConsumerState<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends ConsumerState<CoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(coachViewModelProvider.notifier).syncCredits();
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final state = ref.read(coachViewModelProvider);
    // Directly intercept if free user has no questions left
    if (!state.isPro && state.remainingQuestions <= 0) {
      _showQuotaExhaustedSheet(context);
      return;
    }

    ref.read(coachViewModelProvider.notifier).sendMessage(text);
    _textController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coachViewModelProvider);
    
    // Auto scroll down when new messages arrive
    ref.listen(coachViewModelProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
      if (next.hasExhaustedCredits && !(previous?.hasExhaustedCredits ?? false)) {
        _showQuotaExhaustedSheet(context);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.systemBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.label, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          context.l10n.aiCoachCardTitle,
          style: AppTypography.title2.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(child: _buildCreditBadge(context, state)),
          ),
        ],
        backgroundColor: AppColors.systemBackground,
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          _buildMessageInput(state),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    if (!isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8, top: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryContainer),
              ),
              child: Center(
                child: Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryDark),
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGroupedBackground,
                      borderRadius: BorderRadius.circular(18).copyWith(
                        topLeft: const Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: AppTypography.body.copyWith(color: AppColors.label),
                    ),
                  ),
                  if (message.suggestedWorkout != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _SuggestedWorkoutCard(workout: message.suggestedWorkout!),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomRight: const Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 5,
              offset: Offset(0, 2),
            )
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message.text,
          style: AppTypography.body.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput(CoachState state) {
    final isQuotaExhausted = !state.isPro && state.remainingQuestions <= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        border: Border(top: BorderSide(color: AppColors.separator)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isQuotaExhausted) ...[
              GestureDetector(
                onTap: () => _showQuotaExhaustedSheet(context),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.systemOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.systemOrange.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_clock_rounded, color: AppColors.systemOrange, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Bugünkü 5 koç hakkınız doldu. 1 reklam izle +2 soru kazan!',
                          style: AppTypography.caption1.copyWith(
                            color: AppColors.systemOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.systemOrange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+2 Hak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: isQuotaExhausted
                          ? "Soru hakkınız bitti (Reklam izle veya PRO'ya geç)"
                          : context.l10n.coachInputHint,
                      hintStyle: AppTypography.body.copyWith(
                        color: isQuotaExhausted ? AppColors.systemOrange : AppColors.secondaryLabel,
                        fontSize: isQuotaExhausted ? 13 : 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: isQuotaExhausted
                            ? const BorderSide(color: AppColors.systemOrange, width: 1)
                            : BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isQuotaExhausted
                          ? AppColors.systemOrange.withValues(alpha: 0.05)
                          : AppColors.systemBackground,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    style: AppTypography.body,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                CircleAvatar(
                  backgroundColor: isQuotaExhausted ? AppColors.systemOrange : AppColors.primary,
                  radius: 24,
                  child: IconButton(
                    icon: Icon(
                      isQuotaExhausted ? Icons.lock_rounded : Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditBadge(BuildContext context, CoachState state) {
    if (state.isPro) {
      return GestureDetector(
        onTap: () async {
          final reset = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.secondaryGroupedBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('PRO Üyelik Durumu'),
              content: const Text(
                'Şu an PRO üye olarak görünüyorsunuz ve koç ile sınırsız soru hakkınız var.\n\nÜcretsiz kullanıcı günlük 5 soru kotasını ve reklam izleme ekranını test etmek için ücretsiz hesaba geçmek ister misiniz?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('PRO Kalsın'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Ücretsiz Hesaba Geç (5 Hak)'),
                ),
              ],
            ),
          );
          if (reset == true) {
            final storage = ref.read(localStorageProvider);
            await storage.setPro(false);
            await storage.resetCoachQuestionsForTesting(count: 5);
            ref.read(coachViewModelProvider.notifier).syncCredits();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Ücretsiz hesaba geçildi: 5 günlük soru hakkı tanımlandı.'),
                  backgroundColor: AppColors.primaryDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.systemGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.systemGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.all_inclusive_rounded, size: 13, color: AppColors.systemGreen),
              const SizedBox(width: 4),
              Text(
                context.l10n.coachCreditBadgeUnlimited,
                style: AppTypography.caption2.copyWith(
                  color: AppColors.systemGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isZero = state.remainingQuestions <= 0;
    return GestureDetector(
      onTap: () {
        if (isZero) {
          _showQuotaExhaustedSheet(context);
        } else {
          _showCreditOptionsDialog(context, state.remainingQuestions);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isZero
              ? AppColors.systemOrange.withValues(alpha: 0.15)
              : AppColors.primaryMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isZero
                ? AppColors.systemOrange.withValues(alpha: 0.45)
                : AppColors.primaryContainer,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isZero ? Icons.lock_clock_rounded : Icons.bolt_rounded,
              size: 13,
              color: isZero ? AppColors.systemOrange : AppColors.primaryDark,
            ),
            const SizedBox(width: 4),
            Text(
              context.l10n.coachCreditBadge(state.remainingQuestions),
              style: AppTypography.caption2.copyWith(
                color: isZero ? AppColors.systemOrange : AppColors.primaryDark,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreditOptionsDialog(BuildContext context, int remaining) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondaryGroupedBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Günlük Soru Kotası'),
        content: Text(
          'Bugün kalan soru hakkınız: $remaining / 5.\n\nReklam izleme ekranını hemen test etmek için kotanızı 0 yapmak ister misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.systemOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(coachViewModelProvider.notifier).resetQuestionsForTesting(0);
              if (context.mounted) {
                _showQuotaExhaustedSheet(context);
              }
            },
            child: const Text('Kotayı 0 Yap (Test)'),
          ),
        ],
      ),
    );
  }

  Future<void> _showQuotaExhaustedSheet(BuildContext context) async {
    final l10n = context.l10n;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            decoration: BoxDecoration(
              color: AppColors.systemBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.systemGray4,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sparkle circle icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryContainer, width: 1.5),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    l10n.coachQuotaExhaustedTitle,
                    style: AppTypography.title2.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),

                  // Subtitle / Prompt
                  Text(
                    l10n.coachQuotaExhaustedBody,
                    style: AppTypography.body.copyWith(
                      color: AppColors.secondaryLabel,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Option 1: Watch Rewarded Ad
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await RewardedAdDialog.show(
                          context,
                          rewardTitle: '+2 AI Koç Soru Hakkı',
                          onRewardEarned: () async {
                            await ref.read(coachViewModelProvider.notifier).watchRewardedAd();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          context.l10n.coachRewardSuccessSnackbar,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: AppColors.primaryDark,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                          },
                        );
                      },
                      icon: const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 22),
                      label: Text(
                        l10n.coachWatchAdOption,
                        style: AppTypography.subheadlineSemibold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Option 2: Go PRO
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        final upgraded = await ProVoiceoverSheet.show(context);
                        if (upgraded == true) {
                          ref.read(coachViewModelProvider.notifier).syncCredits();
                        }
                      },
                      icon: const Icon(Icons.workspace_premium_rounded, color: AppColors.systemGreen, size: 20),
                      label: Text(
                        l10n.coachUpgradeProOption,
                        style: AppTypography.subheadlineSemibold.copyWith(
                          color: AppColors.systemGreen,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.systemGreen.withValues(alpha: 0.5),
                          width: 1.2,
                        ),
                        backgroundColor: AppColors.systemGreen.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: Text(
                      context.l10n.commonCancel,
                      style: AppTypography.caption1.copyWith(color: AppColors.secondaryLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (mounted) {
      ref.read(coachViewModelProvider.notifier).resetExhaustedFlag();
    }
  }
}

/// Apple-styled interactive card presenting a tailored relief/practice session
/// recommended by the coach or rule engine.
class _SuggestedWorkoutCard extends ConsumerWidget {
  final WorkoutEntity workout;

  const _SuggestedWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final homeState = ref.watch(homeViewModelProvider);
    final isAlreadyTodayPlan = homeState.todayWorkout?.id == workout.id;
    final activeLocale = Localizations.localeOf(context).languageCode;
    final displayTitle = workout.id.startsWith('relief:')
        ? (PainRules.forRegion(
                BodyRegion.values.firstWhere(
                  (r) => 'relief:${r.name}' == workout.id,
                  orElse: () => BodyRegion.neckShoulder,
                ),
              )?.localizedTitle(activeLocale) ??
              workout.name)
        : workout.name;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top pill: Recommended Practice & Today Plan status ────
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.spa_rounded,
                      size: 13,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.coachSuggestedWorkoutBadge,
                      style: AppTypography.caption2.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAlreadyTodayPlan)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.systemGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: AppColors.systemGreen,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.coachPlanAlreadySetBadge,
                        style: AppTypography.caption2.copyWith(
                          color: AppColors.systemGreen,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Title & Meta ──────────────────────────────────────────
          Text(
            displayTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.label,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 13,
                color: AppColors.secondaryLabel,
              ),
              const SizedBox(width: 4),
              Text(
                l10n.coachSessionMeta(workout.estimatedMinutes, workout.exercises.length),
                style: AppTypography.caption1.copyWith(
                  color: AppColors.secondaryLabel,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Exercises preview ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.systemGroupedBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (var i = 0; i < workout.exercises.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.5),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryContainer,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            workout.exercises[i].exercise?.name ?? 'Exercise ${i + 1}',
                            style: AppTypography.subheadline.copyWith(
                              color: AppColors.label,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Primary Action: Start Practice ────────────────────────
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push(RouteNames.workout, extra: workout);
              },
              icon: const Icon(Icons.play_arrow_rounded, size: 20, color: Colors.white),
              label: Text(
                l10n.coachStartPracticeButton,
                style: AppTypography.subheadline.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // ── Secondary Action: Set as Today's Plan ─────────────────
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: isAlreadyTodayPlan
                  ? null
                  : () {
                      ref.read(homeViewModelProvider.notifier).setTodayWorkout(workout);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  l10n.coachPlanSetSuccessSnackbar,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
              icon: Icon(
                isAlreadyTodayPlan ? Icons.check_rounded : Icons.bookmark_add_outlined,
                size: 16,
                color: isAlreadyTodayPlan ? AppColors.systemGreen : AppColors.primaryDark,
              ),
              label: Text(
                isAlreadyTodayPlan
                    ? l10n.coachPlanAlreadySetBadge
                    : l10n.coachSetAsTodayPlanButton,
                style: AppTypography.subheadline.copyWith(
                  color: isAlreadyTodayPlan ? AppColors.systemGreen : AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isAlreadyTodayPlan
                      ? AppColors.systemGreen.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: isAlreadyTodayPlan
                    ? AppColors.systemGreen.withValues(alpha: 0.08)
                    : AppColors.primaryMuted.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

