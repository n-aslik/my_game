import 'package:flutter/material.dart';
import '../../data/game_data.dart';
import '../../domain/game_controller.dart';
import 'dialogue_screen.dart';
import 'ending_screen.dart';
import 'evidence_screen.dart';
import 'puzzle_screen.dart';
import '../widgets/music_toggle_button.dart';

class GameScreen extends StatefulWidget {
  final GameController game;

  const GameScreen({
    super.key,
    required this.game,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameController get game => widget.game;

  @override
  void initState() {
    super.initState();
    game.addListener(_changed);
  }

  @override
  void dispose() {
    game.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) {
      setState(() {});
    }
  }

  void _showMessage() {
    if (game.message == null) return;

    final message = game.message!;

    // Очищаем сообщение перед показом,
    // чтобы оно не показывалось повторно.
    game.message = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => _showMessage(),
    );

    final loc = game.location;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.name),
        actions: [
          const MusicToggleButton(),
          IconButton(
            onPressed: game.save,
            icon: const Icon(Icons.save),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EvidenceScreen(
                    game: game,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.account_tree),
          ),
          IconButton(
            onPressed: _openEndings,
            icon: const Icon(Icons.flag),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _world(loc),
          ),

          // Инвентарь
          _inventory(),

          // Навигация
          _navigation(loc),
        ],
      ),
    );
  }

  // ============================================================
  // WORLD
  // ============================================================

  Widget _world(dynamic loc) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Container(
          height: 230,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF3B3147),
                Color(0xFF111017),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Text(
              loc.icon,
              style: const TextStyle(
                fontSize: 90,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        Text(
          loc.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),

        const SizedBox(height: 6),

        Text(loc.atmosphere),

        const SizedBox(height: 18),

        // ======================================================
        // ITEMS
        // ======================================================

        if (loc.itemIds.isNotEmpty)
          _section(
            'Предметы',
            loc.itemIds.map<Widget>((id) {
              final taken = game.collectedItems.contains(id);

              return Card(
                child: ListTile(
                  leading: Text(
                    game.item(id).icon,
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  title: Text(
                    game.item(id).name,
                  ),
                  subtitle: Text(
                    game.item(id).description,
                  ),
                  trailing: taken
                      ? const Icon(Icons.check)
                      : FilledButton(
                    onPressed: () {
                      game.pickUp(id);
                    },
                    child: const Text('Взять'),
                  ),
                ),
              );
            }).toList(),
          ),

        // ======================================================
        // OBJECTS
        // ======================================================

        if (loc.objectIds.isNotEmpty)
          _section(
            'Объекты',
            loc.objectIds.map<Widget>((id) {
              final o = game.object(id);

              final hasSelectedItem =
                  game.selectedItemId != null;

              final selectedItem = game.selectedItemId;

              final canUseItem =
                  selectedItem != null &&
                      o.requiredItemId == selectedItem;

              // Место, где требуемый предмет уже израсходован,
              // больше не активно.
              final isUsedUp = o.requiredItemId != null &&
                  game.usedObjects.contains(id);

              return Card(
                child: Opacity(
                  opacity: isUsedUp ? 0.5 : 1,
                  child: ListTile(
                    enabled: !isUsedUp,
                    leading: Icon(
                      isUsedUp
                          ? Icons.check_circle
                          : canUseItem
                          ? Icons.check_circle_outline
                          : Icons.search,
                    ),

                    title: Text(o.name),

                    subtitle: Text(
                      isUsedUp
                          ? 'Здесь больше нечего делать'
                          : hasSelectedItem
                          ? canUseItem
                          ? 'Использовать выбранный предмет'
                          : o.description
                          : o.description,
                    ),

                    trailing: isUsedUp
                        ? null
                        : Icon(
                      o.puzzleId == null
                          ? Icons.touch_app
                          : Icons.extension,
                    ),

                    onTap: isUsedUp
                        ? null
                        : () {
                      // ==================================================
                      // 1. Если выбран предмет — сначала используем его
                      // ==================================================

                      if (game.selectedItemId != null) {
                        final success =
                        game.useSelectedOn(id);

                        if (success) {
                          return;
                        }

                        // Если предмет не подходит,
                        // дальше можно открыть обычное взаимодействие.
                      }

                      // ==================================================
                      // 2. Если предмет не выбран — работаем с объектом
                      // ==================================================

                      if (o.puzzleId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PuzzleScreen(
                              game: game,
                              puzzleId: o.puzzleId!,
                            ),
                          ),
                        );
                      } else {
                        game.useObject(id);
                      }
                    },
                  ),
                ),
              );
            }).toList(),
          ),

        _characters(),
      ],
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section(
      String title,
      List<Widget> children,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        ...children,
      ],
    );
  }

  // ============================================================
  // CHARACTERS
  // ============================================================

  Widget _characters() {
    if (game.locationId != 'entrance') {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: const Text(
          'Смотритель Марк',
        ),
        subtitle: const Text(
          'Он ждёт возле входа.',
        ),
        trailing: const Icon(
          Icons.chat,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DialogueScreen(
                game: game,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Widget _inventory() {
    return SizedBox(
      height: 100,
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        scrollDirection: Axis.horizontal,
        children: game.inventory.map((id) {
          final gameItem = game.item(id);

          final isSelected =
              game.selectedItemId == id;

          return _inventoryItem(
            gameItem,
            id,
            isSelected,
          );
        }).toList(),
      ),
    );
  }

  // ============================================================
  // INVENTORY ITEM
  // ============================================================

  Widget _inventoryItem(
      dynamic gameItem,
      String itemId,
      bool isSelected,
      ) {
    return GestureDetector(
      onTap: () {
        // =====================================================
        // НЕТ ВЫБРАННОГО ПРЕДМЕТА
        // =====================================================

        if (game.selectedItemId == null) {
          setState(() {
            game.selectedItemId = itemId;
          });

          game.notify(
            'Выбран: ${gameItem.name}',
          );

          return;
        }

        // =====================================================
        // НАЖАЛИ НА ТОТ ЖЕ САМЫЙ ПРЕДМЕТ
        // =====================================================

        if (game.selectedItemId == itemId) {
          setState(() {
            game.selectedItemId = null;
          });

          game.notify('Выбор предмета отменён.');

          return;
        }

        // =====================================================
        // УЖЕ ВЫБРАН ДРУГОЙ ПРЕДМЕТ
        // ПЫТАЕМСЯ ОБЪЕДИНИТЬ
        // =====================================================

        final firstItemId = game.selectedItemId!;

        final combined = game.combine(
          firstItemId,
          itemId,
        );

        // Если объединение удалось,
        // selectedItemId уже очищается в combine()
        if (combined) {
          setState(() {});
          return;
        }

        // =====================================================
        // ЕСЛИ НЕ УДАЛОСЬ ОБЪЕДИНИТЬ
        // ОСТАВЛЯЕМ ПЕРВЫЙ ПРЕДМЕТ ВЫБРАННЫМ
        // =====================================================

        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 150,
        ),
        width: 82,
        margin: const EdgeInsets.only(
          right: 7,
        ),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5B3A75)
              : const Color(0xFF17151D),

          borderRadius: BorderRadius.circular(12),

          border: Border.all(
            color: isSelected
                ? const Color(0xFFD6A8FF)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Text(
              gameItem.icon,
              style: const TextStyle(
                fontSize: 28,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              gameItem.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _navigation(dynamic loc) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 62,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          scrollDirection: Axis.horizontal,
          children: loc.exits.map<Widget>((id) {
            final target = locations.firstWhere(
                  (x) => x.id == id,
            );

            final unlocked =
            game.unlockedLocations.contains(id);

            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: OutlinedButton.icon(
                onPressed: unlocked
                    ? () => game.go(id)
                    : null,

                icon: Icon(
                  unlocked
                      ? Icons.arrow_forward
                      : Icons.lock,
                ),

                label: Text(
                  target.name,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // ENDINGS
  // ============================================================

  void _openEndings() {
    final available =
    endings.where(game.canEnd).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EndingScreen(
          game: game,
          available: available,
        ),
      ),
    );
  }
}