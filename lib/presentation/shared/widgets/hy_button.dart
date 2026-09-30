import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

/// Button style variants matching Apple HIG.
enum HYButtonStyle {
  /// Filled background — primary action
  filled,

  /// Tinted background — secondary action
  tinted,

  /// Plain text — tertiary / destructive
  plain,
}

/// iOS-style button with Cupertino press animation.
class HYButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final HYButtonStyle style;
  final bool isLoading;
  final bool isDestructive;
  final bool isFullWidth;
  final IconData? icon;
  final double? height;

  const HYButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = HYButtonStyle.filled,
    this.isLoading = false,
    this.isDestructive = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  });

  const HYButton.tinted({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isFullWidth = true,
    this.icon,
    this.height,
  }) : style = HYButtonStyle.tinted;

  const HYButton.plain({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDestructive = false,
    this.isFullWidth = false,
    this.icon,
    this.height,
  }) : style = HYButtonStyle.plain;

  @override
  State<HYButton> createState() => _HYButtonState();
}

class _HYButtonState extends State<HYButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();
  void _onTapUp(TapUpDetails _) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final color = widget.isDestructive ? AppColors.destructive : AppColors.primary;

    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: isDisabled ? null : _onTapDown,
        onTapUp: isDisabled ? null : _onTapUp,
        onTapCancel: isDisabled ? null : _onTapCancel,
        onTap: isDisabled ? null : widget.onPressed,
        child: _buildContainer(color, isDisabled),
      ),
    );
  }

  Widget _buildContainer(Color color, bool isDisabled) {
    final h = widget.height ?? 50.0;

    Color bgColor;
    Color fgColor;
    switch (widget.style) {
      case HYButtonStyle.filled:
        bgColor = isDisabled ? AppColors.systemGray5 : color;
        fgColor = isDisabled ? AppColors.systemGray3 : Colors.white;
        break;
      case HYButtonStyle.tinted:
        bgColor = isDisabled
            ? AppColors.systemGray6
            : color.withAlpha(30);
        fgColor = isDisabled ? AppColors.systemGray3 : color;
        break;
      case HYButtonStyle.plain:
        bgColor = Colors.transparent;
        fgColor = isDisabled ? AppColors.systemGray3 : color;
        break;
    }

    return Container(
      width: widget.isFullWidth ? double.infinity : null,
      height: widget.style == HYButtonStyle.plain ? null : h,
      padding: widget.style == HYButtonStyle.plain
          ? const EdgeInsets.symmetric(vertical: 4)
          : null,
      decoration: widget.style == HYButtonStyle.plain
          ? null
          : BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            ),
      child: Center(
        child: widget.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: fgColor, size: 18),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Text(
                    widget.label,
                    style: AppTypography.buttonLabel.copyWith(color: fgColor),
                  ),
                ],
              ),
      ),
    );
  }
}
