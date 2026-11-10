import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Анимированная иллюстрация главного меню: луна, дом с мерцающими
/// окнами и (в части 2) вращающийся часовой круг.
class HouseScene extends StatefulWidget {
  final double height;

  const HouseScene({super.key, this.height = 300});

  @override
  State<HouseScene> createState() => _HouseSceneState();
}

class _HouseSceneState extends State<HouseScene>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => SizedBox(
          height: widget.height,
          width: double.infinity,
          child: CustomPaint(painter: _HousePainter(_c.value, p)),
        ),
      ),
    );
  }
}

class _HousePainter extends CustomPainter {
  final double t;
  final AppPalette p;

  _HousePainter(this.t, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tau = math.pi * 2;

    // ---------- Луна / часовой круг ----------
    final moonC = Offset(w * 0.5, h * 0.36);
    final moonR = math.min(w, h) * 0.20;
    final haloColor = p.accent;

    canvas.drawCircle(
      moonC,
      moonR * 2.6,
      Paint()
        ..shader = RadialGradient(
          colors: [
            haloColor.withValues(alpha: 0.30),
            haloColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: moonC, radius: moonR * 2.6)),
    );

    if (p.chrono) {
      // Часовой круг: кольцо с делениями, вращающееся медленно.
      final ring = Paint()
        ..color = p.accent.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(moonC, moonR * 1.55, ring);
      canvas.drawCircle(moonC, moonR * 1.32, ring);
      final tick = Paint()
        ..color = p.accent.withValues(alpha: 0.55)
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 60; i++) {
        final a = i / 60 * tau + t * tau * 0.25;
        final long = i % 5 == 0;
        final r1 = moonR * (long ? 1.32 : 1.40);
        final r2 = moonR * 1.55;
        canvas.drawLine(
          moonC + Offset(math.cos(a), math.sin(a)) * r1,
          moonC + Offset(math.cos(a), math.sin(a)) * r2,
          tick,
        );
      }
      // Стрелки.
      final hand = Paint()
        ..color = p.accent2.withValues(alpha: 0.9)
        ..strokeCap = StrokeCap.round;
      final aMin = -math.pi / 2 + t * tau * 12;
      final aHour = -math.pi / 2 + t * tau;
      canvas.drawLine(
        moonC,
        moonC + Offset(math.cos(aMin), math.sin(aMin)) * moonR * 0.9,
        hand..strokeWidth = 2,
      );
      canvas.drawLine(
        moonC,
        moonC + Offset(math.cos(aHour), math.sin(aHour)) * moonR * 0.6,
        hand..strokeWidth = 3.2,
      );
    }

    // Диск луны.
    canvas.drawCircle(
      moonC,
      moonR,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [
            Color.lerp(Colors.white, p.accent, 0.15)!,
            Color.lerp(p.accent, p.bg, 0.45)!,
          ],
        ).createShader(Rect.fromCircle(center: moonC, radius: moonR)),
    );
    if (p.chrono) {
      // Поверх часов диск полупрозрачный, чтобы стрелки читались.
      canvas.drawCircle(
        moonC,
        moonR,
        Paint()..color = p.bg.withValues(alpha: 0.55),
      );
      canvas.drawCircle(
        moonC,
        moonR,
        Paint()
          ..color = p.accent.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    } else {
      // Кратеры.
      final crater = Paint()..color = p.bg.withValues(alpha: 0.12);
      canvas.drawCircle(moonC + Offset(-moonR * 0.35, -moonR * 0.2), moonR * 0.18, crater);
      canvas.drawCircle(moonC + Offset(moonR * 0.30, moonR * 0.25), moonR * 0.24, crater);
      canvas.drawCircle(moonC + Offset(moonR * 0.05, -moonR * 0.5), moonR * 0.10, crater);
    }

    // ---------- Дальние холмы ----------
    final hills = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.22, h * 0.66, w * 0.45, h * 0.76)
      ..quadraticBezierTo(w * 0.72, h * 0.86, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      hills,
      Paint()..color = Color.lerp(p.bg, p.accent, 0.10)!,
    );

    // ---------- Дом ----------
    final houseColor = Color.lerp(p.bg, Colors.black, 0.6)!;
    final base = h * 0.90;
    final hw = w * 0.46;
    final left = (w - hw) / 2;
    final bodyTop = base - h * 0.26;

    final house = Path()
      // тело
      ..moveTo(left, base)
      ..lineTo(left, bodyTop)
      // левая башенка
      ..lineTo(left, bodyTop - h * 0.06)
      ..lineTo(left + hw * 0.16, bodyTop - h * 0.20)
      ..lineTo(left + hw * 0.32, bodyTop - h * 0.06)
      // главная крыша
      ..lineTo(left + hw * 0.32, bodyTop)
      ..lineTo(left + hw * 0.50, bodyTop - h * 0.15)
      ..lineTo(left + hw * 0.74, bodyTop)
      // труба
      ..lineTo(left + hw * 0.74, bodyTop - h * 0.12)
      ..lineTo(left + hw * 0.80, bodyTop - h * 0.12)
      ..lineTo(left + hw * 0.80, bodyTop)
      ..lineTo(left + hw, bodyTop)
      ..lineTo(left + hw, base)
      ..close();
    canvas.drawPath(house, Paint()..color = houseColor);
    canvas.drawPath(
      house,
      Paint()
        ..color = p.accent.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Окна с мерцанием.
    final windows = <Rect>[
      Rect.fromLTWH(left + hw * 0.07, bodyTop + h * 0.04, hw * 0.10, h * 0.07),
      Rect.fromLTWH(left + hw * 0.26, bodyTop + h * 0.04, hw * 0.10, h * 0.07),
      Rect.fromLTWH(left + hw * 0.46, bodyTop + h * 0.04, hw * 0.10, h * 0.07),
      Rect.fromLTWH(left + hw * 0.66, bodyTop + h * 0.04, hw * 0.10, h * 0.07),
      Rect.fromLTWH(left + hw * 0.84, bodyTop + h * 0.04, hw * 0.09, h * 0.07),
      Rect.fromLTWH(left + hw * 0.14, bodyTop - h * 0.04, hw * 0.05, h * 0.045),
    ];
    for (var i = 0; i < windows.length; i++) {
      final flick = 0.5 + 0.5 * math.sin(t * tau * (3 + i) + i * 1.7);
      // Часть окон «выключена» — дом заброшен.
      final lit = (i == 1 || i == 4 || i == 5) ? 1.0 : 0.0;
      final a = lit == 0 ? 0.05 : 0.35 + 0.55 * flick;
      final c = (i % 2 == 0) ? p.warm : p.accent2;
      canvas.drawRect(windows[i], Paint()..color = c.withValues(alpha: a));
      if (lit > 0) {
        canvas.drawRect(
          windows[i].inflate(6),
          Paint()
            ..color = c.withValues(alpha: 0.10 * flick)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
      }
    }

    // Дверь.
    final door = Rect.fromLTWH(left + hw * 0.43, base - h * 0.10, hw * 0.14, h * 0.10);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        door,
        topLeft: Radius.circular(hw * 0.07),
        topRight: Radius.circular(hw * 0.07),
      ),
      Paint()..color = p.warm.withValues(alpha: 0.12),
    );

    // Передний план: земля.
    canvas.drawRect(
      Rect.fromLTWH(0, base, w, h - base),
      Paint()..color = Color.lerp(p.bg, Colors.black, 0.7)!,
    );

    // Туман над землёй.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.74, w, h * 0.26),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            p.accent.withValues(alpha: 0.0),
            p.accent.withValues(alpha: 0.10 + 0.04 * math.sin(t * tau * 2)),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.74, w, h * 0.26)),
    );

    // Летучие мыши.
    final bat = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final k = (t * 2 + i / 3) % 1.0;
      final bx = w * (1.05 - k * 1.1);
      final by = h * (0.18 + i * 0.07) + math.sin(k * tau * 3 + i) * 10;
      final flap = math.sin(t * tau * 40 + i) * 3;
      final path = Path()
        ..moveTo(bx - 7, by + flap)
        ..quadraticBezierTo(bx - 3, by - 4, bx, by)
        ..quadraticBezierTo(bx + 3, by - 4, bx + 7, by + flap);
      canvas.drawPath(path, bat);
    }
  }

  @override
  bool shouldRepaint(covariant _HousePainter old) => old.t != t;
}
