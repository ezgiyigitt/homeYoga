import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/hy_button.dart';
import '../../../../shared/widgets/hy_text_field.dart';
import '../../viewmodel/profile_viewmodel.dart';
import 'widgets/settings_kit.dart';

/// Edit the personal details collected during onboarding.
///
/// Age, height and weight were always part of [UserProfileEntity] and are
/// used to personalise sessions, but there was no way to change them after
/// onboarding — this screen closes that gap. Blank height/weight is a valid
/// answer and clears the stored value.
class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _age;
  late final TextEditingController _height;
  late final TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileViewModelProvider).profile;
    _firstName = TextEditingController(text: p?.firstName ?? '');
    _lastName = TextEditingController(text: p?.lastName ?? '');
    _age = TextEditingController(text: p?.age?.toString() ?? '');
    _height = TextEditingController(text: _trim(p?.heightCm));
    _weight = TextEditingController(text: _trim(p?.weightKg));
  }

  /// 172.0 → "172", 62.5 → "62.5". Avoids showing a pointless decimal.
  static String _trim(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toString();
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  String? _validateOptionalNumber(String? raw, {required double min, required double max, required String unit}) {
    final text = (raw ?? '').trim();
    if (text.isEmpty) return null; // optional
    final value = double.tryParse(text.replaceAll(',', '.'));
    if (value == null) return 'Enter a number';
    if (value < min || value > max) return 'Enter a value between ${min.round()} and ${max.round()} $unit';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = ref.read(profileViewModelProvider).profile;
    if (profile == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    double? parse(TextEditingController c) {
      final text = c.text.trim();
      if (text.isEmpty) return null;
      return double.tryParse(text.replaceAll(',', '.'));
    }

    await ref.read(profileViewModelProvider.notifier).updateProfile(
          profile.copyWith(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            age: int.tryParse(_age.text.trim()),
            heightCm: parse(_height),
            weightKg: parse(_weight),
          ),
        );

    if (!mounted) return;
    messenger.showSnackBar(
      const SnackBar(content: Text('Personal info updated.')),
    );
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(profileViewModelProvider).isLoading;

    return Form(
      key: _formKey,
      child: SettingsScaffold(
        title: 'Personal Info',
        children: [
          SettingsGroup(
            header: 'Name',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    HYTextField(
                      placeholder: 'First Name',
                      label: 'First name',
                      controller: _firstName,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your first name'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    HYTextField(
                      placeholder: 'Last Name',
                      label: 'Last name',
                      controller: _lastName,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Enter your last name'
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SettingsGroup(
            header: 'Body',
            footer: 'All three are optional. They are only used to tailor '
                'session intensity — leave them blank if you would rather '
                'not share them.',
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    HYTextField(
                      placeholder: 'Age',
                      label: 'Age',
                      controller: _age,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateOptionalNumber(
                        v,
                        min: 10,
                        max: 100,
                        unit: 'years',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    HYTextField(
                      placeholder: 'Height (cm)',
                      label: 'Height',
                      controller: _height,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validateOptionalNumber(
                        v,
                        min: 100,
                        max: 250,
                        unit: 'cm',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    HYTextField(
                      placeholder: 'Weight (kg)',
                      label: 'Weight',
                      controller: _weight,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      validator: (v) => _validateOptionalNumber(
                        v,
                        min: 30,
                        max: 250,
                        unit: 'kg',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: HYButton(
              label: 'Save Changes',
              onPressed: isSaving ? null : _save,
              isLoading: isSaving,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.secondaryLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
