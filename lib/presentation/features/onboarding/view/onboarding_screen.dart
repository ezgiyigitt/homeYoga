import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/onboarding_viewmodel.dart';
import '../../../shared/providers/app_providers.dart';
import 'steps/step_personal_info.dart';
import 'steps/step_fitness_level.dart';
import 'steps/step_goals.dart';
import 'steps/step_frequency_duration.dart';
import 'steps/step_equipment_time_limitations.dart';
import '../../../shared/widgets/hy_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/navigation/route_names.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  static const int _totalSteps = 8;

  List<Widget> get _steps => const [
        StepPersonalInfo(),
        StepFitnessLevel(),
        StepGoals(),
        StepFrequency(),
        StepDuration(),
        StepEquipment(),
        StepPreferredTime(),
        StepLimitations(),
      ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool _isCurrentStepValid() {
    final s = ref.read(onboardingViewModelProvider);
    return switch (_currentPage) {
      0 => s.step1Valid,
      1 => s.step2Valid,
      2 => s.step3Valid,
      3 => s.step4Valid,
      4 => s.step5Valid,
      5 => s.step6Valid,
      6 => s.step7Valid,
      7 => s.step8Valid,
      _ => false,
    };
  }

  Future<void> _onNext() async {
    if (!_isCurrentStepValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _stepError(),
            style: AppTypography.subheadline.copyWith(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          ),
        ),
      );
      return;
    }

    if (_currentPage < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      await _complete();
    }
  }

  Future<void> _complete() async {
    setState(() => _isSaving = true);
    final userId = ref.read(localStorageProvider).userId ?? 'local';
    final error =
        await ref.read(onboardingViewModelProvider.notifier).complete(userId);
    
    if (error == null && mounted) {
      context.go(RouteNames.planReady);
    } else if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Something went wrong.',
            style: AppTypography.subheadline.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.systemRed,
        ),
      );
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _stepError() => switch (_currentPage) {
        0 => 'Please enter your first and last name.',
        1 => 'Select your fitness level to continue.',
        2 => 'Select at least one goal.',
        3 => 'Choose how many days per week.',
        4 => 'Choose your preferred duration.',
        5 => 'Select at least one equipment option.',
        6 => 'Choose your preferred time.',
        _ => 'Complete this step to continue.',
      };

  String _nextLabel() => _currentPage == _totalSteps - 1 ? 'Finish' : 'Continue';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      appBar: AppBar(
        backgroundColor: AppColors.systemGroupedBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _currentPage > 0
            ? IconButton(
                onPressed: _onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              )
            : null,
        title: _ProgressIndicator(
          current: _currentPage + 1,
          total: _totalSteps,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Center(
              child: Text(
                '${_currentPage + 1} of $_totalSteps',
                style: AppTypography.footnote,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (p) => setState(() => _currentPage = p),
              children: _steps,
            ),
          ),

          // Bottom action area
          Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              AppSpacing.md,
              AppSpacing.screenHorizontal,
              MediaQuery.of(context).padding.bottom + AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.systemGroupedBackground,
              border: Border(
                top: BorderSide(color: AppColors.separator, width: 0.5),
              ),
            ),
            child: HYButton(
              label: _nextLabel(),
              onPressed: _isSaving ? null : _onNext,
              isLoading: _isSaving,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _ProgressIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: current / total,
          backgroundColor: AppColors.systemGray5,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}
