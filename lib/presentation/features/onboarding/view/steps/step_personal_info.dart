import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodel/onboarding_viewmodel.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/hy_text_field.dart';

class StepPersonalInfo extends ConsumerStatefulWidget {
  const StepPersonalInfo({super.key});

  @override
  ConsumerState<StepPersonalInfo> createState() => _StepPersonalInfoState();
}

class _StepPersonalInfoState extends ConsumerState<StepPersonalInfo> {
  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;

  @override
  void initState() {
    super.initState();
    final s = ref.read(onboardingViewModelProvider);
    _firstNameCtrl = TextEditingController(text: s.firstName)..addListener(_sync);
    _lastNameCtrl = TextEditingController(text: s.lastName)..addListener(_sync);
    _ageCtrl = TextEditingController(text: s.age)..addListener(_sync);
    _heightCtrl = TextEditingController(text: s.heightCm)..addListener(_sync);
    _weightCtrl = TextEditingController(text: s.weightKg)..addListener(_sync);
  }

  void _sync() {
    ref.read(onboardingViewModelProvider.notifier).updatePersonalInfo(
          firstName: _firstNameCtrl.text,
          lastName: _lastNameCtrl.text,
          age: _ageCtrl.text,
          heightCm: _heightCtrl.text,
          weightKg: _weightCtrl.text,
        );
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
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
          Text('About You', style: AppTypography.largeTitle),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'This helps us tailor your experience.',
            style: AppTypography.subheadline,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Name row
          Container(
            decoration: _cardDecoration,
            child: Column(
              children: [
                _inputCell(
                  HYTextField(
                    placeholder: 'First Name',
                    controller: _firstNameCtrl,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                  divider: true,
                ),
                _inputCell(
                  HYTextField(
                    placeholder: 'Last Name',
                    controller: _lastNameCtrl,
                    textInputAction: TextInputAction.next,
                  ),
                  divider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Body measurements
          Container(
            decoration: _cardDecoration,
            child: Column(
              children: [
                _inputCell(
                  HYTextField(
                    placeholder: 'Age',
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.cake_outlined,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),
                  divider: true,
                ),
                _inputCell(
                  HYTextField(
                    placeholder: 'Height (cm)',
                    controller: _heightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.height_rounded,
                    textInputAction: TextInputAction.next,
                  ),
                  divider: true,
                ),
                _inputCell(
                  HYTextField(
                    placeholder: 'Weight (kg)',
                    controller: _weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    prefixIcon: Icons.monitor_weight_outlined,
                    textInputAction: TextInputAction.done,
                  ),
                  divider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Privacy note
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primaryDark),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Height and weight are optional and only used for workout personalisation.',
                    style: AppTypography.footnote.copyWith(
                      color: AppColors.primaryDark,
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

  Widget _inputCell(Widget field, {required bool divider}) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: field,
          ),
          if (divider)
            Divider(
              height: 0.5,
              thickness: 0.5,
              color: AppColors.separator,
              indent: 16,
            ),
        ],
      );

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: AppColors.secondaryGroupedBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      );
}
