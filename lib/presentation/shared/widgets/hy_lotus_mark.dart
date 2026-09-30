import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A hand-drawn lotus mark, rendered as vector paths instead of the 🪷 emoji.
///
/// Seven petals are laid out in three depth layers — two splayed back petals,
/// two mid petals, three front petals — each one drawn back to front with a
/// slightly stronger tint, so the flower reads as layered rather than flat.
/// Because it is painted rather than typed, it scales cleanly, follows the
/// theme colour, and looks the same on every platform (the emoji does not).
class HYLotusMark extends StatelessWidget {
  final double size;
  final Color color;

  const HYLotusMark({
    super.key,
    this.size = 44,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _LotusMarkPainter(color)),
    );
  }
}

class _LotusMarkPainter extends CustomPainter {
  final Color color;

  const _LotusMarkPainter(this.color);

  /// Petal layout: angle from vertical (deg), length factor, width factor,
  /// tint strength. Ordered back → front so later petals overlap earlier ones.
  static const List<List<double>> _petals = [
    [-74, 0.62, 0.52, 0.34],
    [74, 0.62, 0.52, 0.34],
    [-46, 0.82, 0.46, 0.52],
    [46, 0.82, 0.46, 0.52],
    [-21, 0.95, 0.40, 0.74],
    [21, 0.95, 0.40, 0.74],
    [0, 1.00, 0.42, 1.00],
  ];

  static Color _alpha(Color c, double v) =>
      c.withAlpha((v.clamp(0.0, 1.0) * 255).round());

  /// An ovate petal with a pointed tip, anchored at the origin, pointing −Y.
  static Path _petal(double len, double halfWidth) {
    return Path()
      ..moveTo(0, 0)
      ..cubicTo(
        halfWidth * 1.10, -len * 0.24,
        halfWidth * 0.86, -len * 0.70,
        0, -len,
      )
      ..cubicTo(
        -halfWidth * 0.86, -len * 0.70,
        -halfWidth * 1.10, -len * 0.24,
        0, 0,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final anchor = Offset(size.width / 2, size.height * 0.90);
    final base = size.height * 0.74;

    for (final p in _petals) {
      final angle = p[0] * math.pi / 180;
      final len = base * p[1];
      final halfWidth = len * p[2] * 0.62;
      final tint = p[3];

      canvas.save();
      canvas.translate(anchor.dx, anchor.dy);
      canvas.rotate(angle);

      final path = _petal(len, halfWidth);
      final rect = Rect.fromLTRB(-halfWidth, -len, halfWidth, 0);

      // Base → tip gradient: deeper where the petal meets the centre.
      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              _alpha(color, 0.30 * tint),
              _alpha(color, 0.86 * tint),
              _alpha(color, 0.55 * tint),
            ],
            stops: const [0.0, 0.62, 1.0],
          ).createShader(rect),
      );

      // Crisp edge so overlapping petals stay legible at small sizes.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.6, size.height * 0.014)
          ..color = _alpha(color, 0.30 * tint),
      );

      // Centre vein.
      canvas.drawPath(
        Path()
          ..moveTo(0, -len * 0.10)
          ..quadraticBezierTo(halfWidth * 0.06, -len * 0.55, 0, -len * 0.88),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.5, size.height * 0.010)
          ..strokeCap = StrokeCap.round
          ..color = _alpha(color, 0.22 * tint),
      );

      canvas.restore();
    }

    // Small seed pod at the base of the bloom.
    canvas.drawCircle(
      anchor.translate(0, -size.height * 0.06),
      size.height * 0.055,
      Paint()..color = _alpha(color, 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _LotusMarkPainter old) => old.color != color;
}
