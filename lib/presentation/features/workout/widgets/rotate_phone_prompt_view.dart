import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../shared/providers/locale_provider.dart';

/// Cinematic, serene "Rotate your phone" prompt overlay shown when starting
/// a workout in portrait orientation. Shows a peaceful Home Yoga botanical
/// background and bidirectional rotation (left or right) for a tranquil experience.
class RotatePhonePromptView extends ConsumerStatefulWidget {
  final VoidCallback onContinuePortrait;
  final VoidCallback? onSwitchToLandscape;
  final VoidCallback onClose;

  const RotatePhonePromptView({
    super.key,
    required this.onContinuePortrait,
    this.onSwitchToLandscape,
    required this.onClose,
  });

  @override
  ConsumerState<RotatePhonePromptView> createState() => _RotatePhonePromptViewState();
}

class _RotatePhonePromptViewState extends ConsumerState<RotatePhonePromptView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();

    // Bidirectional rotation: 0° -> Right (+90°) -> 0° -> Left (-90°) -> 0°
    _rotationAnimation = TweenSequence<double>([
      // 1. Center to Right (+90°)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: math.pi / 2)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
      // Pause at Right
      TweenSequenceItem(
        tween: ConstantTween<double>(math.pi / 2),
        weight: 10,
      ),
      // 2. Right to Center (0°)
      TweenSequenceItem(
        tween: Tween<double>(begin: math.pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
      // 3. Center to Left (-90°)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -math.pi / 2)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
      // Pause at Left
      TweenSequenceItem(
        tween: ConstantTween<double>(-math.pi / 2),
        weight: 10,
      ),
      // 4. Left to Center (0°)
      TweenSequenceItem(
        tween: Tween<double>(begin: -math.pi / 2, end: 0.0)
            .chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 20,
      ),
    ]).animate(_controller);

    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appLanguageProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Serene Home Yoga Morning Studio Background Image ──────
          Image.asset(
            'assets/images/rotate_yoga_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFF2EFE9),
            ),
          ),

          // ── 2. Luminous Ambient Gradient (Soft & Airy) ───────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.25),
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.40),
                ],
              ),
            ),
          ),

          // ── 3. Foreground Safe Area Content ───────────────────────────
          SafeArea(
            child: Stack(
              children: [
                // Close button top left
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E2D24).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF1E2D24), size: 22),
                      onPressed: widget.onClose,
                    ),
                  ),
                ),

                // Main center content - responsive and scrollable
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxHeight < 580;
                      final graphicSize = isCompact ? 105.0 : 145.0;

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 360),
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 18 : 24,
                            vertical: isCompact ? 18 : 26,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.95),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E2D24).withValues(alpha: 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Ambient Soft Sage Glow behind phone graphic
                              GestureDetector(
                                onTap: widget.onSwitchToLandscape,
                                behavior: HitTestBehavior.opaque,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: graphicSize * 1.4,
                                      height: graphicSize * 1.4,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.systemGreen.withValues(alpha: 0.22),
                                            AppColors.primary.withValues(alpha: 0.08),
                                            Colors.transparent,
                                          ],
                                          stops: const [0.0, 0.55, 1.0],
                                        ),
                                      ),
                                    ),
                                    // Animated Phone & Bidirectional Rotation Graphic
                                    AnimatedBuilder(
                                      animation: _controller,
                                      builder: (context, child) {
                                        return Transform.scale(
                                          scale: _pulseAnimation.value,
                                          child: CustomPaint(
                                            size: Size(graphicSize, graphicSize),
                                            painter: _PhoneRotationPainter(
                                              rotationAngle: _rotationAnimation.value,
                                              color: const Color(0xFF1E2D24),
                                              accentColor: AppColors.systemGreen,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isCompact ? 10 : 16),

                              // Title - Elegant, natural casing, serene
                              Text(
                                l10n.workoutRotatePhoneTitle,
                                style: GoogleFonts.outfit(
                                  color: const Color(0xFF142218),
                                  fontSize: isCompact ? 20 : 23,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              SizedBox(height: isCompact ? 16 : 22),

                              // Action buttons
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Direct switch to landscape button
                                  if (widget.onSwitchToLandscape != null) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: widget.onSwitchToLandscape,
                                        icon: const Icon(
                                          Icons.screen_rotation_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                        label: Text(
                                          l10n.workoutRotatePhoneSwitchLandscape,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.systemGreen,
                                          foregroundColor: Colors.white,
                                          elevation: 2,
                                          shadowColor: AppColors.systemGreen.withValues(alpha: 0.35),
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  // Minimalist text link to continue in portrait
                                  TextButton(
                                    onPressed: widget.onContinuePortrait,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      foregroundColor: const Color(0xFF5A6F62),
                                    ),
                                    child: Text(
                                      l10n.workoutRotatePhoneContinuePortrait,
                                      style: GoogleFonts.outfit(
                                        color: const Color(0xFF5A6F62),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                        decorationColor: const Color(0xFF5A6F62).withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter rendering a modern smartphone wireframe with bidirectional rotation arrows
class _PhoneRotationPainter extends CustomPainter {
  final double rotationAngle;
  final Color color;
  final Color accentColor;

  _PhoneRotationPainter({
    required this.rotationAngle,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // ── 1. Circular Orbit Arrows (Bidirectional) ──────────────────────
    final arrowPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final radius = size.width * 0.44;

    // Top arc & arrows at BOTH ends
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 1.15,
      math.pi * 0.7,
      false,
      arrowPaint,
    );
    // Right arrowhead
    _drawArrowHead(canvas, center, radius, math.pi * 1.85, true, arrowPaint);
    // Left arrowhead
    _drawArrowHead(canvas, center, radius, math.pi * 1.15, false, arrowPaint);

    // Bottom arc & arrows at BOTH ends
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi * 0.15,
      math.pi * 0.7,
      false,
      arrowPaint,
    );
    // Right arrowhead
    _drawArrowHead(canvas, center, radius, math.pi * 0.85, true, arrowPaint);
    // Left arrowhead
    _drawArrowHead(canvas, center, radius, math.pi * 0.15, false, arrowPaint);

    // ── 2. Rotating Phone ─────────────────────────────────────────────
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);

    final phonePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8;

    const phoneWidth = 56.0;
    const phoneHeight = 98.0;
    const cornerRadius = 14.0;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: phoneWidth, height: phoneHeight),
      const Radius.circular(cornerRadius),
    );

    // Phone outline
    canvas.drawRRect(phoneRect, phonePaint);

    // Screen fill subtle dark
    final screenFillPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(phoneRect.deflate(3.5), screenFillPaint);

    // Top speaker / notch pill
    final notchPaint = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, -phoneHeight / 2 + 7),
          width: 16,
          height: 3.5,
        ),
        const Radius.circular(2),
      ),
      notchPaint,
    );

    // Bottom home indicator
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: const Offset(0, phoneHeight / 2 - 7),
          width: 22,
          height: 2.5,
        ),
        const Radius.circular(1.5),
      ),
      notchPaint,
    );

    canvas.restore();
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset center,
    double radius,
    double angle,
    bool clockwise,
    Paint paint,
  ) {
    final tip = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    const arrowLength = 8.5;
    final tangentAngle = angle + (clockwise ? math.pi / 2 : -math.pi / 2);

    final p1 = Offset(
      tip.dx - arrowLength * math.cos(tangentAngle - 0.5),
      tip.dy - arrowLength * math.sin(tangentAngle - 0.5),
    );
    final p2 = Offset(
      tip.dx - arrowLength * math.cos(tangentAngle + 0.5),
      tip.dy - arrowLength * math.sin(tangentAngle + 0.5),
    );

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(tip.dx, tip.dy)
      ..lineTo(p2.dx, p2.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PhoneRotationPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.color != color ||
        oldDelegate.accentColor != accentColor;
  }
}
