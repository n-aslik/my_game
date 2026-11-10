import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

enum ParticleKind { dust, rain, embers, mist, sparks }

class _Particle {
  final double x, y, size, speed, phase;
  const _Particle(this.x, this.y, this.size, this.speed, this.phase);
}

List<_Particle> _generate(int count, int seed) {
  final r = math.Random(seed);
  return List.generate(
    count,
    (_) => _Particle(
      r.nextDouble(),
      r.nextDouble(),
      r.nextDouble(),
      r.nextDouble(),
      r.nextDouble() * math.pi * 2,
    ),
  );
}

/// Анимированный слой частиц: пыль, дождь, искры, туман.
class ParticleField extends StatefulWidget {
  final ParticleKind kind;
  final Color color;
  final int count;
  final int seed;

  const ParticleField({
    super.key,
    required this.kind,
    required this.color,
    this.count = 36,
    this.seed = 7,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 20))
      ..repeat();
    final n = widget.kind == ParticleKind.mist ? 6 : widget.count;
    _particles = _generate(n, widget.seed);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => SizedBox.expand(
            child: CustomPaint(
              painter: _ParticlePainter(
                _particles,
                _c.value,
                widget.kind,
                widget.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> ps;
  final double t;
  final ParticleKind kind;
  final Color color;

  _ParticlePainter(this.ps, this.t, this.kind, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    if (w <= 0 || h <= 0) return;
    final tau = math.pi * 2;
    final paint = Paint();

    for (final p in ps) {
      switch (kind) {
        case ParticleKind.dust: {
          final n = 1 + (p.speed * 2).floor();
          final y = (p.y - t * n) % 1.0;
          final x = p.x + math.sin(t * tau * 2 + p.phase) * 0.02;
          final tw = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(t * tau * 3 + p.phase));
          paint.color = color.withValues(alpha: 0.05 + 0.22 * tw * p.size);
          canvas.drawCircle(Offset(x * w, y * h), 0.8 + p.size * 2.2, paint);
          break;
        }
        case ParticleKind.rain: {
          final n = 18 + (p.speed * 10).floor();
          final y = (p.y + t * n) % 1.0;
          final x = p.x * w;
          paint
            ..color = color.withValues(alpha: 0.10 + 0.18 * p.size)
            ..strokeWidth = 1
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(
            Offset(x, y * h),
            Offset(x - 5, y * h + 14 + p.size * 10),
            paint,
          );
          break;
        }
        case ParticleKind.embers: {
          final n = 2 + (p.speed * 3).floor();
          final y = (p.y - t * n) % 1.0;
          final x = p.x + math.sin(t * tau * 3 + p.phase) * 0.03;
          final fade = math.sin(y * math.pi);
          paint.color = color.withValues(alpha: (0.55 * fade).clamp(0.0, 1.0).toDouble());
          canvas.drawCircle(Offset(x * w, y * h), 0.8 + p.size * 1.8, paint);
          break;
        }
        case ParticleKind.sparks: {
          final m = 2 + (p.speed * 4).floor();
          final s = math.sin(t * tau * m + p.phase);
          final a = s > 0 ? math.pow(s, 6).toDouble() : 0.0;
          if (a < 0.02) break;
          final c = Offset(p.x * w, p.y * h);
          final r = 2.0 + p.size * 5;
          paint
            ..color = color.withValues(alpha: 0.8 * a)
            ..strokeWidth = 1.2
            ..strokeCap = StrokeCap.round;
          canvas.drawLine(c.translate(-r, 0), c.translate(r, 0), paint);
          canvas.drawLine(c.translate(0, -r), c.translate(0, r), paint);
          break;
        }
        case ParticleKind.mist: {
          final cx = (p.x + 0.10 * math.sin(t * tau + p.phase)) * w;
          final cy = (p.y + 0.04 * math.cos(t * tau + p.phase)) * h;
          final r = 90 + p.size * 120;
          final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
          final shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.13),
              color.withValues(alpha: 0.0),
            ],
          ).createShader(rect);
          canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = shader);
          break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter old) => old.t != t;
}

/// Фон экрана: градиент + частицы + виньетка.
class AmbientBackground extends StatelessWidget {
  final List<Color>? gradient;
  final ParticleKind kind;
  final Color? particleColor;
  final Widget? child;
  final int seed;

  const AmbientBackground({
    super.key,
    this.gradient,
    this.kind = ParticleKind.dust,
    this.particleColor,
    this.child,
    this.seed = 7,
  });

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    final colors = gradient ??
        [
          Color.lerp(p.bg, p.accent, 0.14)!,
          p.bg,
          Color.lerp(p.bg, Colors.black, 0.5)!,
        ];

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 700),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: colors,
            ),
          ),
        ),
        ParticleField(
          key: ValueKey(kind),
          kind: kind,
          color: particleColor ?? p.accent,
          seed: seed,
        ),
        IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.15,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.55),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),
        if (child != null) child!,
      ],
    );
  }
}
