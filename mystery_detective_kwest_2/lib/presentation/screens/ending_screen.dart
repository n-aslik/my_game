import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../domain/game_controller.dart';
import '../widgets/ambient.dart';
import '../widgets/ui_kit.dart';

class EndingScreen extends StatelessWidget {
  final GameController game;
  final List<Ending> available;

  const EndingScreen({super.key, required this.game, required this.available});

  Color _color(EndingType t, AppPalette p) {
    switch (t) {
      case EndingType.truth:
        return p.accent2;
      case EndingType.incomplete:
        return p.warm;
      case EndingType.mystery:
        return const Color(0xFFD6A8FF);
    }
  }

  IconData _icon(EndingType t) {
    switch (t) {
      case EndingType.truth:
        return Icons.verified_rounded;
      case EndingType.incomplete:
        return Icons.hourglass_bottom_rounded;
      case EndingType.mystery:
        return Icons.blur_on_rounded;
    }
  }

  String _label(EndingType t) {
    switch (t) {
      case EndingType.truth:
        return 'ИСТИНА';
      case EndingType.incomplete:
        return 'НЕЗАКОНЧЕННО';
      case EndingType.mystery:
        return 'ЗАГАДКА';
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Финал расследования')),
      body: AmbientBackground(
        kind: ParticleKind.mist,
        particleColor: p.accent,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Reveal(
                child: Center(
                  child: PulseGlow(
                    color: p.accent,
                    radius: 54,
                    child: Container(
                      width: 112,
                      height: 112,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [p.accent.withValues(alpha: 0.35), p.surface],
                        ),
                        border: Border.all(
                          color: p.accent.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(Icons.flag_rounded, size: 54, color: p.accent),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Reveal(
                index: 1,
                child: Text(
                  'Ваши выводы зависят от собранных доказательств.',
                  textAlign: TextAlign.center,
                  style: AppTheme.title(19).copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (available.isEmpty)
                Reveal(
                  index: 2,
                  child: GlassPanel(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(Icons.lock_clock_rounded, color: p.textDim),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Пока недостаточно доказательств для финала. Продолжайте расследование.',
                            style: TextStyle(height: 1.4, color: p.textDim),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ...available.asMap().entries.map((entry) {
                final e = entry.value;
                final c = _color(e.type, p);
                return Reveal(
                  index: entry.key + 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GlassPanel(
                      tint: c,
                      borderColor: c.withValues(alpha: 0.45),
                      padding: EdgeInsets.zero,
                      radius: 24,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () => _openEnding(context, e, c),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.withValues(alpha: 0.18),
                                    border: Border.all(
                                      color: c.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Icon(_icon(e.type), color: c),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Pill(_label(e.type), color: c),
                                      const SizedBox(height: 6),
                                      Text(e.title, style: AppTheme.title(20)),
                                      const SizedBox(height: 4),
                                      Text(
                                        e.text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.35,
                                          color: p.textDim,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right_rounded, color: c),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _openEnding(BuildContext context, Ending e, Color c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(e.title),
        content: SingleChildScrollView(
          child: Text(
            e.text,
            style: const TextStyle(fontSize: 15.5, height: 1.55),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
