import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/game_data.dart';
import '../../domain/game_controller.dart';
import '../widgets/ambient.dart';
import '../widgets/music_toggle_button.dart';
import '../widgets/scene_header.dart';
import '../widgets/ui_kit.dart';
import 'dialogue_screen.dart';
import 'ending_screen.dart';
import 'evidence_screen.dart';
import 'puzzle_screen.dart';

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

    // На экране локации поднимаем уведомление над инвентарём.
    final onGameScreen = ModalRoute.of(context)?.isCurrent ?? true;
    final p = AppTheme.palette;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(16, 0, 16, onGameScreen ? 190 : 24),
        content: Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: p.accent),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (mounted) _showMessage();
      },
    );

    final loc = game.location;
    final mood = SceneMood.of(loc.id);

    return Scaffold(
      body: AmbientBackground(
        gradient: mood.backdrop,
        kind: mood.kind,
        particleColor: mood.glow,
        seed: loc.id.hashCode & 0xFFFF,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _topBar(loc),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(loc.id),
                    child: _world(loc),
                  ),
                ),
              ),

              // Инвентарь
              _inventory(),

              // Навигация
              _navigation(loc),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _topBar(dynamic loc) {
    final p = AppTheme.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 4),
      child: Row(
        children: [
          GlassIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Назад',
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ЛОКАЦИЯ',
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 2.4,
                    fontWeight: FontWeight.w800,
                    color: p.accent,
                  ),
                ),
                Text(
                  loc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.title(17),
                ),
              ],
            ),
          ),
          const MusicToggleButton(),
          GlassIconButton(
            icon: Icons.save_rounded,
            tooltip: 'Сохранить',
            onTap: game.save,
          ),
          GlassIconButton(
            icon: Icons.account_tree_rounded,
            tooltip: 'Расследование',
            badge: game.evidenceFound.length,
            onTap: () {
              Navigator.push(
                context,
                softRoute(EvidenceScreen(game: game)),
              );
            },
          ),
          GlassIconButton(
            icon: Icons.flag_rounded,
            tooltip: 'Финал',
            onTap: _openEndings,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WORLD
  // ============================================================

  Widget _world(dynamic loc) {
    var i = 0;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      children: [
        Reveal(child: SceneHeader(location: loc)),

        // ======================================================
        // ITEMS
        // ======================================================

        if (loc.itemIds.isNotEmpty)
          _section(
            'Предметы',
            Icons.inventory_2_rounded,
            loc.itemIds.map<Widget>((id) {
              final taken = game.collectedItems.contains(id);
              final item = game.item(id);

              return Reveal(
                index: ++i,
                child: _itemTile(id, item, taken),
              );
            }).toList(),
          ),

        // ======================================================
        // OBJECTS
        // ======================================================

        if (loc.objectIds.isNotEmpty)
          _section(
            'Объекты',
            Icons.search_rounded,
            loc.objectIds.map<Widget>((id) {
              final o = game.object(id);
              return Reveal(
                index: ++i,
                child: _objectTile(id, o),
              );
            }).toList(),
          ),

        _characters(),
      ],
    );
  }

  Widget _itemTile(String id, dynamic item, bool taken) {
    final p = AppTheme.palette;
    return Opacity(
      opacity: taken ? 0.55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: GlassPanel(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: RadialGradient(
                    colors: [
                      p.warm.withValues(alpha: 0.28),
                      p.warm.withValues(alpha: 0.05),
                    ],
                  ),
                  border: Border.all(color: p.warm.withValues(alpha: 0.25)),
                ),
                child: Text(
                  item.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.3,
                        color: p.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              taken
                  ? Icon(Icons.check_circle_rounded, color: p.accent2)
                  : FilledButton(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onPressed: () {
                        game.pickUp(id);
                      },
                      child: const Text('Взять'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _objectTile(String id, dynamic o) {
    final p = AppTheme.palette;

    final hasSelectedItem = game.selectedItemId != null;
    final selectedItem = game.selectedItemId;

    final canUseItem = selectedItem != null && o.requiredItemId == selectedItem;

    // Место, где требуемый предмет уже израсходован,
    // больше не активно.
    final isUsedUp = o.requiredItemId != null && game.usedObjects.contains(id);

    final hasPuzzle = o.puzzleId != null;

    final IconData leadIcon = isUsedUp
        ? Icons.check_circle_rounded
        : canUseItem
            ? Icons.bolt_rounded
            : hasPuzzle
                ? Icons.extension_rounded
                : Icons.search_rounded;

    final Color leadColor = isUsedUp
        ? p.accent2
        : canUseItem
            ? p.warm
            : p.accent;

    final String subtitle = isUsedUp
        ? 'Здесь больше нечего делать'
        : hasSelectedItem
            ? canUseItem
                ? 'Использовать выбранный предмет'
                : o.description
            : o.description;

    return Opacity(
      opacity: isUsedUp ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: canUseItem
                ? [
                    BoxShadow(
                      color: p.warm.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: -2,
                    ),
                  ]
                : const [],
          ),
          child: GlassPanel(
            padding: EdgeInsets.zero,
            borderColor: canUseItem ? p.warm.withValues(alpha: 0.8) : null,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: isUsedUp
                    ? null
                    : () {
                        // ==================================================
                        // 1. Если выбран предмет — сначала используем его
                        // ==================================================

                        if (game.selectedItemId != null) {
                          final success = game.useSelectedOn(id);

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
                            softRoute(
                              PuzzleScreen(
                                game: game,
                                puzzleId: o.puzzleId!,
                              ),
                            ),
                          );
                        } else {
                          game.useObject(id);
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: leadColor.withValues(alpha: 0.14),
                          border: Border.all(
                            color: leadColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Icon(leadIcon, color: leadColor, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    o.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                ),
                                if (hasPuzzle && !isUsedUp) ...[
                                  const SizedBox(width: 8),
                                  const Pill('ГОЛОВОЛОМКА'),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                color: canUseItem ? p.warm : p.textDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isUsedUp) ...[
                        const SizedBox(width: 8),
                        Icon(
                          hasPuzzle
                              ? Icons.chevron_right_rounded
                              : Icons.touch_app_rounded,
                          color: p.textDim,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title, icon: icon),
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

    final p = AppTheme.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Персонажи', icon: Icons.people_alt_rounded),
        GlassPanel(
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () {
                Navigator.push(
                  context,
                  softRoute(DialogueScreen(game: game)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    PulseGlow(
                      color: p.accent,
                      radius: 22,
                      child: CircleAvatar(
                        radius: 26,
                        backgroundColor: p.accent.withValues(alpha: 0.2),
                        child: Icon(Icons.person_rounded, color: p.accent),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Смотритель Марк',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15.5,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Он ждёт возле входа.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chat_bubble_rounded, color: p.accent),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INVENTORY
  // ============================================================

  Widget _inventory() {
    final p = AppTheme.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: GlassPanel(
        blur: true,
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        radius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.backpack_rounded, size: 14, color: p.accent),
                const SizedBox(width: 6),
                Text(
                  'ИНВЕНТАРЬ',
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w800,
                    color: p.textDim,
                  ),
                ),
                const Spacer(),
                Text(
                  game.selectedItemId == null
                      ? '${game.inventory.length}'
                      : 'выберите цель или второй предмет',
                  style: TextStyle(
                    fontSize: 11,
                    color: game.selectedItemId == null ? p.textDim : p.warm,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 70,
              child: game.inventory.isEmpty
                  ? Center(
                      child: Text(
                        'Пусто — осмотритесь вокруг',
                        style: TextStyle(
                          color: p.textDim,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    )
                  : ListView(
                      scrollDirection: Axis.horizontal,
                      children: game.inventory.map((id) {
                        final gameItem = game.item(id);

                        final isSelected = game.selectedItemId == id;

                        return _inventoryItem(
                          gameItem,
                          id,
                          isSelected,
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
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
    final p = AppTheme.palette;
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        width: 76,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        transform: Matrix4.translationValues(0, isSelected ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: isSelected
              ? p.accent.withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? p.accent : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: p.accent.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: -2,
                  ),
                ]
              : const [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              gameItem.icon,
              style: const TextStyle(
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              gameItem.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    final p = AppTheme.palette;
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 60,
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          scrollDirection: Axis.horizontal,
          children: loc.exits.map<Widget>((id) {
            final target = locations.firstWhere(
              (x) => x.id == id,
            );

            final unlocked = game.unlockedLocations.contains(id);
            final mood = SceneMood.of(id);

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Opacity(
                opacity: unlocked ? 1 : 0.5,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          mood.glow.withValues(alpha: unlocked ? 0.28 : 0.08),
                          mood.top.withValues(alpha: 0.5),
                        ],
                      ),
                      border: Border.all(
                        color: unlocked
                            ? mood.glow.withValues(alpha: 0.55)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: unlocked ? () => game.go(id) : null,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              unlocked
                                  ? Icons.arrow_forward_rounded
                                  : Icons.lock_rounded,
                              size: 18,
                              color: unlocked ? mood.glow : p.textDim,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              target.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
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
    final available = endings.where(game.canEnd).toList();

    Navigator.push(
      context,
      softRoute(
        EndingScreen(
          game: game,
          available: available,
        ),
      ),
    );
  }
}
