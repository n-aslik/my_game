import 'package:flutter/material.dart';
import 'package:mystery_detective_kwest/data/models/models.dart';
import '../../data/game_data.dart';
import '../../domain/game_controller.dart';

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
      setState(() => wrongFlash = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.game.puzzle(widget.puzzleId);
    final solved = widget.game.solvedPuzzles.contains(p.id);
    final usesPieces = p.pieceItemIds.isNotEmpty;
    final hasTokens = p.tokens.isNotEmpty || usesPieces;
    final allPiecesFound = !usesPieces || piecesFound >= piecesTotal;

    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.extension, size: 80),
          const SizedBox(height: 20),
          Text(p.description, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),

          if (usesPieces && !solved) ...[
            Row(
              children: [
                Icon(
                  allPiecesFound ? Icons.check_circle : Icons.search,
                  size: 18,
                  color: allPiecesFound ? Colors.greenAccent : null,
                ),
                const SizedBox(width: 8),
                Text('Найдено фрагментов: $piecesFound из $piecesTotal'),
              ],
            ),
            if (!allPiecesFound) ...[
              const SizedBox(height: 6),
              const Text(
                'Остальные фрагменты спрятаны в доме — исследуйте другие комнаты и вернитесь сюда позже.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 12),
          ],

          if (hint)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text('Подсказка: ${p.hint}'),
              ),
            ),
          const SizedBox(height: 12),

          if (!solved) ...[
            if (hasTokens) ...[
              // ==========================================================
              // СОБРАННЫЙ ОТВЕТ
              // ==========================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                decoration: BoxDecoration(
                  color: wrongFlash
                      ? const Color(0x33FF5252)
                      : const Color(0xFF17151D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: wrongFlash ? Colors.redAccent : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  assembled.isEmpty ? 'Вставьте ответ снизу…' : _assembledText(p),
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),

              // ==========================================================
              // ДОСТУПНЫЕ ВАРИАНТЫ ДЛЯ ВСТАВКИ
              // ==========================================================
              if (remaining.isEmpty && usesPieces)
                const Text(
                  'Фрагментов для вставки пока нет — сначала найдите хотя бы один.',
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    for (var i = 0; i < remaining.length; i++)
                      OutlinedButton(
                        onPressed: () => _insert(p, remaining[i], i),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: Text(remaining[i]),
                      ),
                  ],
                ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: assembled.isEmpty ? null : () => _removeLast(p),
                      icon: const Icon(Icons.backspace_outlined),
                      label: const Text('Стереть'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: assembled.isEmpty ? null : () => _clear(p),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Очистить'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],

            FilledButton(
              onPressed: (hasTokens && assembled.isEmpty) ? null : () => _submit(p),
              child: const Text('Проверить'),
            ),
            OutlinedButton(
              onPressed: () => setState(() => hint = true),
              child: const Text('Показать подсказку'),
            ),
          ] else
            const FilledButton(
              onPressed: null,
              child: Text('Решено'),
            ),

          const SizedBox(height: 18),
          const Text('Важно: решение должно следовать логике найденных улик, а не случайному перебору.'),
        ],
      ),
    );
  }
}
