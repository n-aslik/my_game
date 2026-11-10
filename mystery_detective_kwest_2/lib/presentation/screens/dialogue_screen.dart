import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/game_data.dart';
import '../../domain/game_controller.dart';
import '../widgets/ambient.dart';
import '../widgets/ui_kit.dart';

class DialogueScreen extends StatefulWidget {
  final GameController game;
  const DialogueScreen({super.key, required this.game});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  String? response;

  @override
  Widget build(BuildContext context) {
    final p = AppTheme.palette;
    final dialogue = dialogues.first;
    final available = dialogue.options
        .where(
          (o) => o.available(widget.game.evidenceFound, widget.game.inventory),
        )
        .toList();

    final speaker = characters.firstWhere(
      (c) => c.id == dialogue.characterId,
      orElse: () => characters.first,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: const Text('Разговор')),
      body: AmbientBackground(
        kind: ParticleKind.dust,
        particleColor: p.warm,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              // ---------- Собеседник ----------
              Reveal(
                child: Column(
                  children: [
                    PulseGlow(
                      color: p.accent,
                      radius: 40,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: p.accent.withValues(alpha: 0.18),
                        child: Icon(
                          Icons.person_rounded,
                          size: 52,
                          color: p.accent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(speaker.name, style: AppTheme.title(24)),
                    const SizedBox(height: 4),
                    Text(
                      speaker.role.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w700,
                        color: p.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ---------- Реплика-вступление ----------
              Reveal(
                index: 1,
                child: _bubble(
                  child: Text(
                    dialogue.intro,
                    style: const TextStyle(
                      fontSize: 16.5,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  fromNpc: true,
                ),
              ),

              // ---------- Ответ ----------
              if (response != null) ...[
                const SizedBox(height: 14),
                _bubble(
                  fromNpc: true,
                  child: Typewriter(
                    response!,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ],

              const SizedBox(height: 26),
              const SectionLabel('Ваш вопрос', icon: Icons.forum_rounded),

              // ---------- Варианты ----------
              ...available.asMap().entries.map(
                    (e) => Reveal(
                      index: e.key + 2,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: _option(e.value),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bubble({required Widget child, required bool fromNpc}) {
    final p = AppTheme.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(6),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            p.accent.withValues(alpha: 0.18),
            p.surface.withValues(alpha: 0.75),
          ],
        ),
        border: Border.all(color: p.accent.withValues(alpha: 0.25)),
      ),
      child: child,
    );
  }

  Widget _option(dynamic o) {
    final p = AppTheme.palette;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() {
            response = o.response;
            if (o.grantsEvidenceId != null) {
              widget.game.collectEvidence(o.grantsEvidenceId!);
            }
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(Icons.subdirectory_arrow_right_rounded, color: p.accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    o.text,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
