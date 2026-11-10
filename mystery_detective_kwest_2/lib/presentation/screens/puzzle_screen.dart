import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../../domain/game_controller.dart';
import '../widgets/ambient.dart';
import '../widgets/ui_kit.dart';

class PuzzleScreen extends StatefulWidget {
  final GameController game;
  final String puzzleId;

  const PuzzleScreen({super.key, required this.game, required this.puzzleId});

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  bool hint = false;
  bool wrongFlash = false;
  int shakeCount = 0;

  // Собранные тапом токены, в порядке вставки.
  final List<String> assembled = [];

  // Токены, ещё не вставленные (для паззлов, где каждый токен
  // используется один раз). Для клавиатурных паззлов (allowRepeatTokens)
  // этот список не тратится.
  late List<String> remaining;

  // Сколько из нужных фрагментов-предметов уже найдено в доме —
  // только для головоломок с pieceItemIds.
  late int piecesFound;
  late int piecesTotal;

  @override
  void initState() {
    super.initState();
    final p = widget.game.puzzle(widget.puzzleId);
    remaining = List.of(_startingTokens(p));
    piecesFound = widget.game.piecesFoundCount(p);
    piecesTotal = p.pieceItemIds.length;
  }

  // Откуда брать вставляемые варианты: либо статичный набор (цифровая
  // клавиатура и т.п.), либо токены уже найденных в доме фрагментов.
  List<String> _startingTokens(Puzzle p) {
    if (p.pieceItemIds.isNotEmpty) {
      return widget.game.foundPieceTokens(p);
    }
    return p.tokens;
  }

  String _assembledText(Puzzle p) => assembled.join(p.tokenSeparator);

  void _insert(Puzzle p, String token, int tokenIndex) {
    setState(() {
      assembled.add(token);
      if (!p.allowRepeatTokens) {
        remaining.removeAt(tokenIndex);
      }
      wrongFlash = false;
    });
  }

  void _removeLast(Puzzle p) {
    if (assembled.isEmpty) return;
    setState(() {
      final last = assembled.removeLast();
      if (!p.allowRepeatTokens) {
        remaining.add(last);
      }
    });
  }

  void _clear(Puzzle p) {
    setState(() {
      assembled.clear();
      remaining = List.of(_startingTokens(p));
    });
  }

  void _submit(Puzzle p) {
    final answer = _assembledText(p);
    if (widget.game.solve(p.id, answer)) {
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        wrongFlash = true;
        shakeCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = AppTheme.palette;
    final p = widget.game.puzzle(widget.puzzleId);
    final solved = widget.game.solvedPuzzles.contains(p.id);
    final usesPieces = p.pieceItemIds.isNotEmpty;
    final hasTokens = p.tokens.isNotEmpty || usesPieces;
    final allPiecesFound = !usesPieces || piecesFound >= piecesTotal;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(title: Text(p.title)),
      body: AmbientBackground(
        kind: ParticleKind.sparks,
        particleColor: pal.accent2,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Reveal(
                child: Center(
                  child: PulseGlow(
                    color: solved ? pal.accent2 : pal.accent,
                    radius: 46,
                    child: Container(
                      width: 104,
                      height: 104,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            (solved ? pal.accent2 : pal.accent)
                                .withValues(alpha: 0.35),
                            pal.surface,
                          ],
                        ),
                        border: Border.all(
                          color: (solved ? pal.accent2 : pal.accent)
                              .withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        solved ? Icons.lock_open_rounded : Icons.extension_rounded,
                        size: 50,
                        color: solved ? pal.accent2 : pal.accent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Reveal(
                index: 1,
                child: GlassPanel(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    p.description,
                    style: const TextStyle(fontSize: 16.5, height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (usesPieces && !solved) ...[
                GlassPanel(
                  padding: const EdgeInsets.all(14),
                  borderColor: (allPiecesFound ? pal.accent2 : pal.warm)
                      .withValues(alpha: 0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            allPiecesFound
                                ? Icons.check_circle_rounded
                                : Icons.search_rounded,
                            size: 18,
                            color: allPiecesFound ? Colors.greenAccent : pal.warm,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Найдено фрагментов: $piecesFound из $piecesTotal',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: piecesTotal == 0 ? 0 : piecesFound / piecesTotal,
                          minHeight: 6,
                        ),
                      ),
                      if (!allPiecesFound) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Остальные фрагменты спрятаны в доме — исследуйте другие комнаты и вернитесь сюда позже.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: pal.textDim,
                            height: 1.35,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (hint)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassPanel(
                    tint: pal.warm,
                    borderColor: pal.warm.withValues(alpha: 0.5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded, color: pal.warm),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Подсказка: ${p.hint}',
                            style: const TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (!solved) ...[
                if (hasTokens) ...[
                  // ==========================================================
                  // СОБРАННЫЙ ОТВЕТ
                  // ==========================================================
                  Shake(
                    trigger: shakeCount,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      constraints: const BoxConstraints(minHeight: 72),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: wrongFlash
                            ? const Color(0x33FF5252)
                            : Colors.black.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: wrongFlash
                              ? Colors.redAccent
                              : pal.accent.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        assembled.isEmpty
                            ? 'Вставьте ответ снизу…'
                            : _assembledText(p),
                        style: assembled.isEmpty
                            ? TextStyle(
                                color: pal.textDim,
                                fontStyle: FontStyle.italic,
                                fontSize: 16,
                              )
                            : AppTheme.title(26, spacing: 3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==========================================================
                  // ДОСТУПНЫЕ ВАРИАНТЫ ДЛЯ ВСТАВКИ
                  // ==========================================================
                  if (remaining.isEmpty && usesPieces)
                    Text(
                      'Фрагментов для вставки пока нет — сначала найдите хотя бы один.',
                      style: TextStyle(color: pal.textDim),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        for (var i = 0; i < remaining.length; i++)
                          _tokenButton(p, remaining[i], i),
                      ],
                    ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed:
                              assembled.isEmpty ? null : () => _removeLast(p),
                          icon: const Icon(Icons.backspace_outlined),
                          label: const Text('Стереть'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: assembled.isEmpty ? null : () => _clear(p),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Очистить'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],

                GlowButton(
                  label: 'Проверить',
                  icon: Icons.fact_check_rounded,
                  onPressed:
                      (hasTokens && assembled.isEmpty) ? null : () => _submit(p),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  onPressed: () => setState(() => hint = true),
                  icon: const Icon(Icons.lightbulb_outline_rounded),
                  label: const Text('Показать подсказку'),
                ),
              ] else
                GlassPanel(
                  tint: pal.accent2,
                  borderColor: pal.accent2.withValues(alpha: 0.5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: pal.accent2),
                      const SizedBox(width: 10),
                      Text(
                        'Решено',
                        style: AppTheme.title(18, color: pal.accent2),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 22),
              Text(
                'Важно: решение должно следовать логике найденных улик, а не случайному перебору.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: pal.textDim,
                  fontSize: 12.5,
                  height: 1.4,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tokenButton(Puzzle p, String token, int index) {
    final pal = AppTheme.palette;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              pal.accent.withValues(alpha: 0.22),
              pal.surface.withValues(alpha: 0.8),
            ],
          ),
          border: Border.all(color: pal.accent.withValues(alpha: 0.45)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _insert(p, token, index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              token,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
