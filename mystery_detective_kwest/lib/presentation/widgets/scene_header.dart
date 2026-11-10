import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import 'ambient.dart';

/// Настроение локации: цвета неба/стен, свечение и тип частиц.
class SceneMood {
  final Color top;
  final Color bottom;
  final Color glow;
  final ParticleKind kind;

  const SceneMood(this.top, this.bottom, this.glow, this.kind);

  List<Color> get backdrop => [
        Color.lerp(top, Colors.black, 0.35)!,
        Color.lerp(bottom, Colors.black, 0.2)!,
        Colors.black,
      ];

  static SceneMood of(String id) {
    final m = _moods[id];
    if (m != null) return m;
    final p = AppTheme.palette;
    return SceneMood(
      Color.lerp(p.bg, p.accent, 0.3)!,
      p.bg,
      p.accent,
      ParticleKind.dust,
    );
  }

  static const Map<String, SceneMood> _moods = {
    // ---------- Часть 1 ----------
    'entrance': SceneMood(
        Color(0xFF1F2E48), Color(0xFF0A0F18), Color(0xFF8DBBFF), ParticleKind.rain),
    'hall': SceneMood(
        Color(0xFF3F2C44), Color(0xFF130D17), Color(0xFFFFC27A), ParticleKind.dust),
    'library': SceneMood(
        Color(0xFF45301B), Color(0xFF150E08), Color(0xFFFFB75E), ParticleKind.dust),
    'kitchen': SceneMood(
        Color(0xFF21403B), Color(0xFF0A1412), Color(0xFF7FE8D0), ParticleKind.dust),
    'basement': SceneMood(
        Color(0xFF1C2433), Color(0xFF05070B), Color(0xFF7CC4FF), ParticleKind.mist),
    'laboratory': SceneMood(
        Color(0xFF12403F), Color(0xFF04100F), Color(0xFF5EEAD4), ParticleKind.sparks),
    'secret': SceneMood(
        Color(0xFF3E2062), Color(0xFF0A0613), Color(0xFFD6A8FF), ParticleKind.mist),
    // ---------- Часть 2 (1927) ----------
    'entrance_1927': SceneMood(
        Color(0xFF4D3822), Color(0xFF140E08), Color(0xFFFFD08A), ParticleKind.dust),
    'hall_1927': SceneMood(
        Color(0xFF513A26), Color(0xFF170F09), Color(0xFFFFC46B), ParticleKind.dust),
    'study': SceneMood(
        Color(0xFF4A3118), Color(0xFF150D06), Color(0xFFFFAE52), ParticleKind.embers),
    'conservatory': SceneMood(
        Color(0xFF1F4A33), Color(0xFF07140C), Color(0xFF8CF0A8), ParticleKind.mist),
    'workshop': SceneMood(
        Color(0xFF4F2B18), Color(0xFF140905), Color(0xFFFFA25B), ParticleKind.sparks),
    'cellar_1927': SceneMood(
        Color(0xFF1C2D40), Color(0xFF05080D), Color(0xFF86C7FF), ParticleKind.mist),
    'threshold': SceneMood(
        Color(0xFF2B2266), Color(0xFF07051A), Color(0xFF7CF5FF), ParticleKind.sparks),
  };
}

/// Большая «кинематографичная» шапка локации.
class SceneHeader extends StatefulWidget {
  final Location location;
  final double height;

  const SceneHeader({super.key, required this.location, this.height = 250});

  @override
  State<SceneHeader> createState() => _SceneHeaderState();
}

class _SceneHeaderState extends State<SceneHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.location;
    final mood = SceneMood.of(loc.id);
    final p = AppTheme.palette;
    final seed = loc.id.hashCode & 0xFFFF;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: mood.glow.withValues(alpha: 0.22),
            blurRadius: 36,
            spreadRadius: -8,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(27),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Градиент «стены»
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [mood.top, mood.bottom],
                ),
              ),
            ),

            // Свет из окна / арка
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) => CustomPaint(
                painter: _ArchLightPainter(
                  mood.glow,
                  0.5 + 0.5 * math.sin(_c.value * math.pi * 2),
                ),
              ),
            ),

            ParticleField(
              key: ValueKey(loc.id),
              kind: mood.kind,
              color: mood.glow,
              count: 30,
              seed: seed,
            ),

            // Эмодзи-«иллюстрация» со свечением и лёгким покачиванием
            Center(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final bob = math.sin(_c.value * math.pi * 2) * 6;
                  return Transform.translate(
                    offset: Offset(0, bob - 14),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                mood.glow.withValues(alpha: 0.40),
                                mood.glow.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                        Text(
                          loc.icon,
                          style: TextStyle(
                            fontSize: 92,
                            shadows: [
                              Shadow(
                                color: mood.glow.withValues(alpha: 0.8),
                                blurRadius: 34,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Затемнение снизу + подпись
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 40, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.78),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.name,
                      style: AppTheme.title(26),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.atmosphere,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        fontStyle: FontStyle.italic,
                        color: p.text.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchLightPainter extends CustomPainter {
  final Color glow;
  final double breathe;

  _ArchLightPainter(this.glow, this.breathe);

  @override
  void paint(Canvas canvas, Size size) {
    // Конус света сверху.
    final beam = Path()
      ..moveTo(size.width * 0.42, 0)
      ..lineTo(size.width * 0.58, 0)
      ..lineTo(size.width * 0.86, size.height)
      ..lineTo(size.width * 0.14, size.height)
      ..close();
    final rect = Offset.zero & size;
    canvas.drawPath(
      beam,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            glow.withValues(alpha: 0.10 + 0.10 * breathe),
            glow.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );

    // Силуэт арки на дальнем плане.
    final w = size.width * 0.36;
    final cx = size.width / 2;
    final top = size.height * 0.10;
    final archRect = Rect.fromLTWH(cx - w / 2, top, w, size.height);
    final arch = Path()
      ..moveTo(archRect.left, archRect.bottom)
      ..lineTo(archRect.left, archRect.top + w / 2)
      ..arcToPoint(
        Offset(archRect.right, archRect.top + w / 2),
        radius: Radius.circular(w / 2),
      )
      ..lineTo(archRect.right, archRect.bottom)
      ..close();
    canvas.drawPath(
      arch,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      arch,
      Paint()
        ..color = glow.withValues(alpha: 0.18 + 0.12 * breathe)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _ArchLightPainter old) =>
      old.breathe != breathe || old.glow != glow;
}
