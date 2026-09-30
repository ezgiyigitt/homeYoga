import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/theme/app_colors.dart';

/// Colour recipe for a single petal, from where it meets the centre out to
/// its tip. Keeping these together makes the whole bloom re-skinnable in one
/// line without touching the geometry.
class HYLotusPalette {
  /// Deepest tone, where the petal meets the seed pod.
  final Color base;

  /// Body of the petal — the colour it mostly reads as.
  final Color mid;

  /// Lightest tone at the tip, where light passes through the petal.
  final Color tip;

  /// Centre vein and the shaded edge.
  final Color vein;

  /// Aura and the glowing core.
  final Color aura;

  const HYLotusPalette({
    required this.base,
    required this.mid,
    required this.tip,
    required this.vein,
    required this.aura,
  });

  /// Deep forest → pale sage. Stays inside the app's green identity.
  static const HYLotusPalette sage = HYLotusPalette(
    base: Color(0xFF24492F),
    mid: Color(0xFF4A7C59),
    tip: Color(0xFFBFDCC8),
    vein: Color(0xFF1D3B26),
    aura: AppColors.primary,
  );

  /// Cream and blush, closer to a real white lotus. Warmer, more floral.
  static const HYLotusPalette bloom = HYLotusPalette(
    base: Color(0xFFD9A9A0),
    mid: Color(0xFFF6E4E0),
    tip: Color(0xFFFFFCFA),
    vein: Color(0xFFC08C86),
    aura: Color(0xFF7FA98C),
  );
}

/// A calm, three-dimensional lotus that breathes.
///
/// Three concentric rings of petals sit in real 3D space, tilted around the X
/// axis so the bloom opens toward the viewer, then projected with a
/// perspective divide and depth-sorted every frame — nearer petals genuinely
/// overlap the ones behind them.
///
/// Each petal is shaded rather than filled flat: a base→tip gradient for
/// translucency, a cross-petal gradient that curves the surface away from the
/// light, a curved centre vein, a darkened rim, and a specular highlight on
/// the petals facing the viewer. Far petals lose contrast and pick up blur, so
/// the bloom has real depth of field.
///
/// The figure expands and contracts on a 4-1-4-1 cycle (inhale · hold ·
/// exhale · hold), quietly setting a breathing pace for whoever is looking.
///
/// No assets, no packages, one ticker. Drop it behind any screen in a [Stack]:
///
/// ```dart
/// Stack(
///   children: [
///     const Positioned.fill(
///       child: IgnorePointer(child: HYBreathingLotus()),
///     ),
///     yourContent,
///   ],
/// )
/// ```
class HYBreathingLotus extends StatefulWidget {
  /// Where the bloom's centre sits within the available space.
  final Alignment center;

  /// Overall size multiplier (1.0 ≈ 60% of the shortest side).
  final double scale;

  /// Global opacity multiplier — lower it when content sits on top.
  final double opacity;

  /// Petal colouring. Defaults to [HYLotusPalette.sage].
  final HYLotusPalette palette;

  /// Floating pollen motes drifting around the bloom.
  final bool showMotes;

  const HYBreathingLotus({
    super.key,
    this.center = const Alignment(0, -0.55),
    this.scale = 1.0,
    this.opacity = 1.0,
    this.palette = HYLotusPalette.sage,
    this.showMotes = true,
  });

  @override
  State<HYBreathingLotus> createState() => _HYBreathingLotusState();
}

class _HYBreathingLotusState extends State<HYBreathingLotus>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// Drives the painter directly, so nothing in the widget tree rebuilds.
  final ValueNotifier<double> _clock = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _clock.value = elapsed.inMicroseconds / 1000000.0;
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _LotusBloomPainter(
          clock: _clock,
          center: widget.center,
          scale: widget.scale,
          opacity: widget.opacity,
          palette: widget.palette,
          showMotes: widget.showMotes,
          isDark: isDark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Geometry
// ─────────────────────────────────────────────────────────────────────────────

/// Tilt of the bloom's plane around the X axis, in radians (~57°).
const double _kTilt = 1.0;

/// Direction the light comes from, in screen space (upper left).
const double _kLightX = -0.62;
const double _kLightY = -0.78;

/// One concentric ring of petals.
class _Ring {
  final int count;
  final double radius; // multiple of the base radius
  final double lift; // height above the bloom's plane
  final double size; // petal length multiplier
  final double speed; // turns per second (sign sets direction)
  final double phase;

  const _Ring({
    required this.count,
    required this.radius,
    required this.lift,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

const List<_Ring> _kRings = [
  _Ring(count: 6, radius: 0.42, lift: -0.12, size: 1.00, speed: 0.020, phase: 0.0),
  _Ring(count: 10, radius: 0.72, lift: 0.01, size: 0.84, speed: -0.014, phase: 0.31),
  _Ring(count: 14, radius: 1.00, lift: 0.14, size: 0.68, speed: 0.009, phase: 0.17),
];

/// A petal already projected into screen space.
class _ProjectedPetal {
  final Offset position;
  final double angle;
  final double length;
  final double depth; // 0 = farthest, 1 = nearest
  final double curl; // asymmetry of the tip, −1 … 1

  const _ProjectedPetal(
    this.position,
    this.angle,
    this.length,
    this.depth,
    this.curl,
  );
}

/// A drifting pollen mote. Generated once, deterministically.
class _Mote {
  final double x, y, z, speed, size, phase;
  const _Mote(this.x, this.y, this.z, this.speed, this.size, this.phase);
}

final List<_Mote> _kMotes = List<_Mote>.generate(30, (i) {
  final rnd = math.Random(i * 977 + 13);
  return _Mote(
    rnd.nextDouble(),
    rnd.nextDouble(),
    rnd.nextDouble(),
    0.010 + rnd.nextDouble() * 0.026,
    0.7 + rnd.nextDouble() * 1.8,
    rnd.nextDouble() * math.pi * 2,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────

class _LotusBloomPainter extends CustomPainter {
  final ValueNotifier<double> clock;
  final Alignment center;
  final double scale;
  final double opacity;
  final HYLotusPalette palette;
  final bool showMotes;
  final bool isDark;

  _LotusBloomPainter({
    required this.clock,
    required this.center,
    required this.scale,
    required this.opacity,
    required this.palette,
    required this.showMotes,
    required this.isDark,
  }) : super(repaint: clock);

  static Color _alpha(Color color, double value) =>
      color.withAlpha((value.clamp(0.0, 1.0) * 255).round());

  /// Smooth 4s inhale · 1s hold · 4s exhale · 1s hold, returned as 0 → 1 → 0.
  static double _breath(double t) {
    const inhale = 4.0, hold = 1.0, exhale = 4.0;
    const total = inhale + hold + exhale + hold;
    final p = t % total;
    if (p < inhale) return _ease(p / inhale);
    if (p < inhale + hold) return 1.0;
    if (p < inhale + hold + exhale) {
      return 1.0 - _ease((p - inhale - hold) / exhale);
    }
    return 0.0;
  }

  static double _ease(double x) {
    final c = x.clamp(0.0, 1.0);
    if (c < 0.5) return 2 * c * c;
    final k = -2 * c + 2;
    return 1 - (k * k) / 2;
  }

  /// An ovate petal with a pointed, slightly turned tip, anchored at the
  /// origin and pointing along −Y. [curl] leans the tip to one side so no two
  /// neighbouring petals are identical.
  static Path _petalPath(double len, double curl) {
    final w = len * 0.34;
    return Path()
      ..moveTo(0, 0)
      ..cubicTo(
        w * (1.12 + curl * 0.20), -len * 0.23,
        w * (0.90 + curl * 0.30), -len * 0.69,
        curl * w * 0.42, -len,
      )
      ..cubicTo(
        -w * (0.90 - curl * 0.30), -len * 0.69,
        -w * (1.12 - curl * 0.20), -len * 0.23,
        0, 0,
      )
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || opacity <= 0) return;

    final t = clock.value;
    final origin = center.alongSize(size);
    final radius = size.shortestSide * 0.30 * scale;
    if (radius <= 0) return;
    final breath = _breath(t);

    _paintAura(canvas, origin, radius, breath);
    if (showMotes) _paintMotes(canvas, size, t);
    _paintPetals(canvas, origin, radius, t, breath);
    _paintCore(canvas, origin, radius, breath);
  }

  void _paintAura(Canvas canvas, Offset origin, double radius, double breath) {
    final rect = Rect.fromCircle(center: origin, radius: radius * 2.7);
    final strength = (isDark ? 0.24 : 0.14) * opacity * (0.72 + 0.38 * breath);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [_alpha(palette.aura, strength), _alpha(palette.aura, 0)],
          stops: const [0.0, 1.0],
        ).createShader(rect),
    );
  }

  void _paintPetals(
    Canvas canvas,
    Offset origin,
    double radius,
    double t,
    double breath,
  ) {
    final sinTilt = math.sin(_kTilt);
    final cosTilt = math.cos(_kTilt);
    final focal = radius * 3.4;

    final petals = <_ProjectedPetal>[];

    for (final ring in _kRings) {
      final ringRadius = radius * ring.radius * (0.86 + 0.20 * breath);

      for (var i = 0; i < ring.count; i++) {
        final a = (i / ring.count) * math.pi * 2 +
            t * ring.speed * math.pi * 2 +
            ring.phase;

        final wobble = 1 + math.sin(t * 0.8 + i * 1.7) * 0.028;
        final x = math.cos(a) * ringRadius * wobble;
        final y = math.sin(a) * ringRadius * wobble;
        final z = radius * ring.lift + math.sin(t * 0.6 + a * 2) * radius * 0.05;

        // Rotate around X, then project.
        final yr = y * cosTilt - z * sinTilt;
        final zr = y * sinTilt + z * cosTilt;
        final k = focal / (focal + zr);
        if (k <= 0) continue;

        final sx = origin.dx + x * k;
        final sy = origin.dy + yr * k;

        petals.add(_ProjectedPetal(
          Offset(sx, sy),
          math.atan2(sy - origin.dy, sx - origin.dx) + math.pi / 2,
          radius * 0.34 * ring.size * k * (0.88 + 0.26 * breath),
          ((k - 0.76) / 0.60).clamp(0.0, 1.0),
          math.sin(i * 2.4 + ring.phase * 3) * 0.55,
        ));
      }
    }

    // Farthest first, so nearer petals overlap the ones behind them.
    petals.sort((a, b) => a.depth.compareTo(b.depth));

    for (final petal in petals) {
      _paintPetal(canvas, petal, breath);
    }
  }

  void _paintPetal(Canvas canvas, _ProjectedPetal petal, double breath) {
    final len = petal.length;
    if (len <= 0.5) return;

    final depth = petal.depth;
    final visibility = opacity * (0.72 + 0.34 * breath) * (0.34 + 0.66 * depth);
    if (visibility <= 0.01) return;

    final w = len * 0.34;
    final path = _petalPath(len, petal.curl);
    final rect = Rect.fromLTRB(-w * 1.2, -len, w * 1.2, 0);

    // Where the light falls on this petal once it is rotated outward.
    final lightSide =
        _kLightX * math.cos(petal.angle) + _kLightY * math.sin(petal.angle);
    final lit = lightSide >= 0 ? 1.0 : -1.0;

    canvas.save();
    canvas.translate(petal.position.dx, petal.position.dy);
    canvas.rotate(petal.angle);

    // Far petals blur out — real depth of field rather than flat opacity.
    final blurred = depth < 0.55;
    final body = Paint();
    if (blurred) {
      body.maskFilter =
          MaskFilter.blur(BlurStyle.normal, (0.55 - depth) * 5.0 + 0.4);
    }

    // 1. Base → tip gradient: deep where it meets the centre, translucent at
    //    the tip where light passes through.
    body.shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        _alpha(palette.base, visibility * 0.95),
        _alpha(palette.mid, visibility * 0.88),
        _alpha(palette.tip, visibility * 0.70),
      ],
      stops: const [0.0, 0.58, 1.0],
    ).createShader(rect);
    canvas.drawPath(path, body);

    // Near petals get the expensive detail; far ones are blurred anyway.
    if (!blurred) {
      canvas.save();
      canvas.clipPath(path);

      // 2. Cross-petal shading: curves the surface away from the light.
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(-lit, 0),
            end: Alignment(lit, 0),
            colors: [
              _alpha(palette.vein, visibility * 0.42),
              _alpha(palette.vein, 0),
              _alpha(palette.tip, visibility * 0.30),
            ],
            stops: const [0.0, 0.52, 1.0],
          ).createShader(rect),
      );

      // 3. Specular sheen on the petals turned toward the viewer.
      if (depth > 0.62) {
        final sheen = Rect.fromCenter(
          center: Offset(lit * w * 0.34, -len * 0.60),
          width: w * 0.90,
          height: len * 0.52,
        );
        canvas.drawOval(
          sheen,
          Paint()
            ..shader = RadialGradient(
              colors: [
                _alpha(palette.tip, visibility * 0.34 * (depth - 0.62) / 0.38),
                _alpha(palette.tip, 0),
              ],
            ).createShader(sheen),
        );
      }
      canvas.restore();

      // 4. Centre vein.
      canvas.drawPath(
        Path()
          ..moveTo(0, -len * 0.08)
          ..quadraticBezierTo(
            petal.curl * w * 0.20, -len * 0.54,
            petal.curl * w * 0.34, -len * 0.90,
          ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.5, len * 0.020)
          ..strokeCap = StrokeCap.round
          ..color = _alpha(palette.vein, visibility * 0.30),
      );

      // 5. Darkened rim, so overlapping petals stay readable.
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.5, len * 0.014)
          ..color = _alpha(palette.vein, visibility * 0.26),
      );
    }

    canvas.restore();
  }

  void _paintCore(Canvas canvas, Offset origin, double radius, double breath) {
    final glowRadius = radius * (0.30 + 0.12 * breath);
    final rect = Rect.fromCircle(center: origin, radius: glowRadius);

    canvas.drawCircle(
      origin,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _alpha(palette.aura, (0.18 + 0.16 * breath) * opacity),
            _alpha(palette.aura, 0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(rect),
    );

    // Seed pod: a small domed centre with a lit top edge.
    final podRadius = radius * (0.070 + 0.020 * breath);
    final podRect = Rect.fromCircle(center: origin, radius: podRadius);
    canvas.drawCircle(
      origin,
      podRadius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.55),
          colors: [
            _alpha(palette.tip, 0.92 * opacity),
            _alpha(palette.mid, 0.85 * opacity),
            _alpha(palette.base, 0.80 * opacity),
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(podRect),
    );
  }

  void _paintMotes(Canvas canvas, Size size, double t) {
    final paint = Paint();
    for (final mote in _kMotes) {
      final depth = 0.35 + mote.z * 0.65;
      final y = (mote.y - t * mote.speed) % 1.0;
      final x = mote.x + math.sin(t * 0.22 + mote.phase) * 0.018;

      paint.color = _alpha(palette.aura, (0.05 + 0.14 * mote.z) * opacity);
      canvas.drawCircle(
        Offset(x * size.width, y * size.height),
        mote.size * depth,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LotusBloomPainter old) {
    return old.center != center ||
        old.scale != scale ||
        old.opacity != opacity ||
        old.palette != palette ||
        old.showMotes != showMotes ||
        old.isDark != isDark;
  }
}
