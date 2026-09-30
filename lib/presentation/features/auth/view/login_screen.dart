import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodel/auth_viewmodel.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/hy_button.dart';
import '../../../shared/widgets/hy_text_field.dart';
import '../../../shared/widgets/hy_logo.dart';
import '../../../shared/widgets/hy_breathing_lotus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/navigation/route_names.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    ));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final vm = ref.read(authViewModelProvider.notifier);
    final success = await vm.signIn(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (success && mounted) {
      final onboardingDone = ref.read(onboardingCompleteProvider);
      context.go(onboardingDone ? RouteNames.home : RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.systemGroupedBackground,
      body: Stack(
        children: [
          // Decorative 3D lotus mandala, breathing at 4-1-4-1.
          const Positioned.fill(
            child: IgnorePointer(
              child: HYBreathingLotus(
                center: Alignment(0, -0.62),
                opacity: 0.9,
              ),
            ),
          ),
          SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontal,
          ),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 56),

                // Logo
                const HYLogo(showTagline: true),
                const SizedBox(height: 56),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sign In', style: AppTypography.largeTitle),
                ),
                const SizedBox(height: AppSpacing.xs),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome back to your wellness journey.',
                    style: AppTypography.subheadline,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Fields — grouped card style
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
                    children: [
                      _FieldCell(
                        showDivider: true,
                        child: HYTextField(
                          placeholder: 'Email',
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          focusNode: _emailFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter your email';
                            }
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                      ),
                      _FieldCell(
                        showDivider: false,
                        child: HYPasswordField(
                          placeholder: 'Password',
                          controller: _passwordCtrl,
                          focusNode: _passwordFocus,
                          textInputAction: TextInputAction.done,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Enter your password';
                            }
                            if (v.length < 6) return 'Min 6 characters';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Error
                if (state.error != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ErrorBanner(message: state.error!),
                ],

                const SizedBox(height: AppSpacing.xl),

                // Sign In button
                HYButton(
                  label: 'Sign In',
                  onPressed: state.isLoading ? null : _onSignIn,
                  isLoading: state.isLoading,
                ),

                const SizedBox(height: AppSpacing.md),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTypography.subheadline,
                    ),
                    GestureDetector(
                      onTap: () => context.push(RouteNames.register),
                      child: Text(
                        'Sign Up',
                        style: AppTypography.subheadlineSemibold.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ),
          ),
        ),
          ),
        ],
      ),
    );
  }
}

/// Inset field within grouped card.
class _FieldCell extends StatelessWidget {
  final Widget child;
  final bool showDivider;

  const _FieldCell({required this.child, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
        if (showDivider)
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: AppColors.separator,
            indent: 16,
          ),
      ],
    );
  }
}

/// Inline error banner (iOS-style red tint).
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.systemRed.withAlpha(15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.systemRed,
            size: 16,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: AppTypography.footnote.copyWith(
                color: AppColors.systemRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
