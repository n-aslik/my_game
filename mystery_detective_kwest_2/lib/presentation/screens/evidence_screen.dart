import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/game_data.dart';
import '../../data/models/models.dart';
import '../../domain/game_controller.dart';
import '../widgets/ambient.dart';
import '../widgets/ui_kit.dart';

class EvidenceScreen extends StatelessWidget {
  final GameController game;
  const EvidenceScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    final found = evidence.where((e) => game.evidenceFound.contains(e.id)).toList();
    final progress = evidence.isEmpty ? 0.0 : found.length / evidence.length;
    final shownLinks = links
        .where((l) =>
            game.evidenceFound.contains(l.fromId) &&
            game.evidenceFound.contains(l.toId))
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Расследование')),
      body: AmbientBackground(
        kind: ParticleKind.dust,
        particleColor: p.accent,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              // ---------- Прогресс ----------
              Reveal(
                child: GlassPanel(
                  padding: const EdgeInsets.all(18),
                  radius: 26,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 78,
                              height: 78,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: progress),
                                duration: const Duration(milliseconds: 900),
                                curve: Curves.easeOutCubic,
                                builder: (context, v, _) =>
                                    CircularProgressIndicator(
                                  value: v,
                                  strokeWidth: 6,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                            Text(
                              '${(progress * 100).round()}%',
                              style: AppTheme.title(18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Улики', style: AppTheme.title(24)),
                            const SizedBox(height: 4),
                            Text(
                              'Собрано ${found.length} из ${evidence.length}',
                              style: TextStyle(color: p.textDim),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SectionLabel('Доска улик', icon: Icons.push_pin_rounded),

              if (found.isEmpty)
                Reveal(
                  index: 1,
                  child: GlassPanel(
                    child: Row(
                      children: [
                        Icon(Icons.search_off_rounded, color: p.textDim),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Пока ничего не найдено.',
                            style: TextStyle(color: p.textDim),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ...found.asMap().entries.map((entry) {
                final e = entry.value;
                final color = _color(e.type, p);
                return Reveal(
                  index: entry.key + 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: GlassPanel(
                      tint: color,
                      borderColor: color.withValues(alpha: 0.35),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: color.withValues(alpha: 0.18),
                              border: Border.all(
                                color: color.withValues(alpha: 0.45),
                              ),
                            ),
                            child: Icon(_icon(e.type), color: color),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Pill(_label(e.type), color: color),
                                const SizedBox(height: 6),
                                Text(
                                  e.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.5,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  e.description,
                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.35,
                                    color: p.textDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SectionLabel('Связи', icon: Icons.hub_rounded),

              if (shownLinks.isEmpty)
                GlassPanel(
                  child: Row(
                    children: [
                      Icon(Icons.link_off_rounded, color: p.textDim),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Связи появятся, когда вы найдёте достаточно улик.',
                          style: TextStyle(color: p.textDim),
                        ),
                      ),
                    ],
                  ),
                ),

              ...shownLinks.map(
                (l) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: GlassPanel(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Pill(_name(l.fromId), color: p.accent),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              color: p.textDim,
                            ),
                            Pill(_name(l.toId), color: p.accent2),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l.explanation,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.4,
                            color: p.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(EvidenceType type) {
    switch (type) {
      case EvidenceType.photograph: return Icons.photo_camera_rounded;
      case EvidenceType.document: return Icons.description_rounded;
      case EvidenceType.symbol: return Icons.auto_awesome;
      case EvidenceType.audio: return Icons.graphic_eq_rounded;
      case EvidenceType.testimony: return Icons.record_voice_over_rounded;
      case EvidenceType.object: return Icons.inventory_2_rounded;
    }
  }

  String _label(EvidenceType type) {
    switch (type) {
      case EvidenceType.photograph: return 'ФОТО';
      case EvidenceType.document: return 'ДОКУМЕНТ';
      case EvidenceType.symbol: return 'СИМВОЛ';
      case EvidenceType.audio: return 'ЗАПИСЬ';
      case EvidenceType.testimony: return 'ПОКАЗАНИЕ';
      case EvidenceType.object: return 'ПРЕДМЕТ';
    }
  }

  Color _color(EvidenceType type, AppPalette p) {
    switch (type) {
      case EvidenceType.photograph: return const Color(0xFF7FB2FF);
      case EvidenceType.document: return p.warm;
      case EvidenceType.symbol: return const Color(0xFFD6A8FF);
      case EvidenceType.audio: return p.accent2;
      case EvidenceType.testimony: return const Color(0xFFFF8FB1);
      case EvidenceType.object: return const Color(0xFFB8E986);
    }
  }

  String _name(String id) => evidence.firstWhere((e) => e.id == id).title;
}
