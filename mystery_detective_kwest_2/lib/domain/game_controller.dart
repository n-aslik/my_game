import 'package:flutter/foundation.dart';
import '../data/game_data.dart';
import '../data/models/models.dart';
import '../services/save_service.dart';

class GameController extends ChangeNotifier {
  final SaveService saveService;

  String locationId = 'entrance_1927';

  final Set<String> inventory = {};
  final Set<String> collectedItems = {};
  final Set<String> evidenceFound = {};
  final Set<String> solvedPuzzles = {};
  final Set<String> unlockedLocations = {'entrance_1927', 'hall_1927'};
  final Map<String, Set<String>> locationConnections = {
    'entrance_1927': {'hall_1927'},
    'hall_1927': {'entrance_1927', 'study', 'conservatory', 'workshop'},
    'study': {'hall_1927'},
    'conservatory': {'hall_1927'},
    'workshop': {'hall_1927', 'cellar_1927'},
    'cellar_1927': {'workshop', 'threshold'},
    'threshold': {'cellar_1927'},
  };
  final Set<String> eventsDone = {};
  final Set<String> endingsSeen = {};

  // Объекты, на которых уже был израсходован требуемый предмет —
  // такие места становятся неактивными в интерфейсе.
  final Set<String> usedObjects = {};

  String? selectedItemId;
  String? message;

  void selectItem(String id) {
    if (!inventory.contains(id)) {
      notify('Этого предмета нет в инвентаре.');
      return;
    }

    if (selectedItemId == id) {
      selectedItemId = null;
      notify('Предмет отменён.');
      return;
    }

    selectedItemId = id;

    final selected = item(id);

    notify('Выбран предмет: ${selected.name}');
  }

  GameController({SaveService? saveService})
      : saveService = saveService ?? SaveService();

  // =========================
  // GETTERS
  // =========================

  Location get location =>
      locations.firstWhere((e) => e.id == locationId);

  List<Location> get allLocations => locations;

  List<Evidence> get evidenceList =>
      List.unmodifiable(evidence);

  // =========================
  // FIND BY ID
  // =========================

  Item item(String id) {
    return items.firstWhere((e) => e.id == id);
  }

  Puzzle puzzle(String id) {
    return puzzles.firstWhere((e) => e.id == id);
  }

  GameObject object(String id) {
    return objects.firstWhere((e) => e.id == id);
  }

  Evidence evidenceById(String id) {
    return evidence.firstWhere((e) => e.id == id);
  }

  // =========================
  // MESSAGE
  // =========================

  void notify(String text) {
    message = text;
    notifyListeners();
  }

  // =========================
  // NEW GAME
  // =========================

  void newGame() {
    locationId = 'entrance_1927';

    inventory.clear();
    collectedItems.clear();
    evidenceFound.clear();
    solvedPuzzles.clear();

    unlockedLocations
      ..clear()
      ..addAll({
        'entrance_1927',
        'hall_1927',
      });

    eventsDone.clear();
    endingsSeen.clear();
    usedObjects.clear();

    selectedItemId = null;
    message = null;

    notifyListeners();
  }

  // =========================
  // PICK UP ITEM
  // =========================

  void pickUp(String id) {
    if (collectedItems.contains(id)) {
      notify('Вы уже забрали этот предмет.');
      return;
    }

    collectedItems.add(id);
    inventory.add(id);

    // Некоторые находки — сами по себе улики и не требуют
    // дополнительных действий, чтобы попасть в дело.
    final linkedEvidence = autoEvidenceOnPickup[id];
    if (linkedEvidence != null) {
      evidenceFound.add(linkedEvidence);
    }

    notify('Получено: ${item(id).name}');
  }

  // =========================
  // COLLECT EVIDENCE
  // =========================

  void collectEvidence(String id) {
    if (evidenceFound.add(id)) {
      notify(
        'Найдена улика: ${evidenceById(id).title}',
      );
    }
  }

  // =========================
  // PUZZLE PIECES (находимые фрагменты)
  // =========================

  // Сколько из нужных фрагментов уже лежит в инвентаре.
  int piecesFoundCount(Puzzle p) {
    return p.pieceItemIds.where(inventory.contains).length;
  }

  // Токены найденных фрагментов — то, что реально можно вставить
  // в ответ прямо сейчас. Если фрагмент ещё не найден, его токена
  // в этом списке не будет, и собрать правильный ответ не получится,
  // пока игрок не исследует дом дальше.
  List<String> foundPieceTokens(Puzzle p) {
    return p.pieceItemIds
        .where(inventory.contains)
        .map((id) => item(id).puzzleToken ?? '?')
        .toList();
  }

  // =========================
  // SOLVE PUZZLE
  // =========================

  bool solve(String puzzleId, String answer) {
    final p = puzzle(puzzleId);

    if (solvedPuzzles.contains(puzzleId)) {
      notify('Эта головоломка уже решена.');
      return true;
    }

    if (!p.accepts(answer)) {
      notify('Неверно. Изучите подсказки ещё раз.');
      return false;
    }

    solvedPuzzles.add(puzzleId);

    // Фрагменты-подсказки этой головоломки больше не нужны —
    // они были потрачены на то, чтобы собрать правильный ответ.
    for (final pieceId in p.pieceItemIds) {
      inventory.remove(pieceId);
    }

    // Награда-предмет
    if (p.rewardItemId != null) {
      pickUp(p.rewardItemId!);
    }

    // Награда-улика
    if (p.rewardEvidenceId != null) {
      collectEvidence(p.rewardEvidenceId!);
    }

    // Проверяем открытие новых локаций
    unlockByProgress();

    // Проверяем события
    triggerEvents();

    notify('Головоломка решена.');

    return true;
  }

  // =========================
  // UNLOCK LOCATIONS
  // =========================

  void unlockByProgress() {
    // =========================
    // 1. ХОЛЛ
    // =========================
    unlockedLocations.add('hall_1927');

    // =========================
    // 2. КАБИНЕТ И ОРАНЖЕРЕЯ
    // =========================
    // После попадания в холл обе комнаты становятся доступны.
    if (unlockedLocations.contains('hall_1927')) {
      unlockedLocations.add('study');
      unlockedLocations.add('conservatory');
    }

    // =========================
    // 3. МАСТЕРСКАЯ
    // =========================
    // Мастерская открывается после решения шифра стола профессора.
    if (solvedPuzzles.contains('desk')) {
      unlockedLocations.add('workshop');
    }

    // =========================
    // 4. ПОДВАЛ, 1927
    // =========================
    // Подвал открывается после запуска аппарата.
    if (solvedPuzzles.contains('apparatus')) {
      unlockedLocations.add('cellar_1927');
    }

    // =========================
    // 5. ПОРОГ МЕЖДУ ЭПОХАМИ
    // =========================
    // Нужно решить обе загадки — ворота мастерской и колокола подвала.
    if (solvedPuzzles.contains('gate_symbols') &&
        solvedPuzzles.contains('chimes')) {
      unlockedLocations.add('threshold');
    }
  }

  // =========================
  // GO TO LOCATION
  // =========================

  void go(String id) {
    // Проверяем, открыта ли локация
    if (!unlockedLocations.contains(id)) {
      notify('Эта локация пока недоступна.');
      return;
    }

    // Проверяем, можно ли перейти туда из текущей локации
    final connectedLocations =
        locationConnections[locationId] ?? {};

    if (!connectedLocations.contains(id)) {
      notify('Отсюда туда пройти нельзя.');
      return;
    }

    // Переходим
    locationId = id;

    selectedItemId = null;
    message = null;

    // Проверяем открытие новых локаций
    unlockByProgress();

    // Проверяем события
    triggerEvents();

    notifyListeners();
  }

  // =========================
  // EVENTS
  // =========================

  void triggerEvents() {
    for (final event in events) {
      if (event.locationId != locationId ||
          eventsDone.contains(event.id)) {
        continue;
      }

      final puzzlesOk =
      event.requiredPuzzles.every(solvedPuzzles.contains);

      final evidenceOk =
      event.requiredEvidence.every(evidenceFound.contains);

      if (puzzlesOk && evidenceOk) {
        eventsDone.add(event.id);
        message = event.message;
        return;
      }
    }
  }

  // =========================
  // USE OBJECT
  // =========================

  void useObject(String objectId) {
    final o = object(objectId);

    if (o.requiredItemId != null &&
        !inventory.contains(o.requiredItemId)) {
      notify(
        'Нужен предмет: ${item(o.requiredItemId!).name}',
      );
      return;
    }

    if (o.puzzleId != null) {
      notify(
        'Нужно решить: ${puzzle(o.puzzleId!).title}',
      );
      return;
    }

    notify(o.description);
  }

  // =========================
  // COMBINE ITEMS
  // =========================

  bool combine(String a, String b) {
    if (a == b) {
      notify('Нельзя объединить предмет с самим собой.');
      return false;
    }

    for (final c in combinations) {
      if (c.matches(a, b)) {
        // Проверяем, что оба предмета действительно есть
        if (!inventory.contains(a) || !inventory.contains(b)) {
          notify('Для объединения нужны оба предмета.');
          return false;
        }

        inventory.remove(a);
        inventory.remove(b);

        inventory.add(c.result);

        selectedItemId = null;

        notify(
          'Предметы объединены: ${item(c.result).name}',
        );

        return true;
      }
    }

    notify('Эти предметы нельзя объединить.');

    return false;
  }

  // =========================
  // USE SELECTED ITEM
  // =========================

  bool useSelectedOn(String targetId) {
    if (selectedItemId == null) {
      notify('Сначала выберите предмет в инвентаре.');
      return false;
    }

    final itemId = selectedItemId!;
    final o = object(targetId);

    // Проверяем, нужен ли вообще предмет
    if (o.requiredItemId == null) {
      notify('Здесь предмет использовать не нужно.');
      return false;
    }

    // Проверяем правильность предмета
    if (o.requiredItemId != itemId) {
      notify('Этот предмет здесь не подходит.');
      return false;
    }

    // Предмет использован
    inventory.remove(itemId);
    selectedItemId = null;

    // Место, где был использован предмет, становится неактивным.
    usedObjects.add(targetId);

    // Награда-предмет
    if (o.rewardItemId != null) {
      pickUp(o.rewardItemId!);
    }

    // Награда-улика
    if (o.rewardEvidenceId != null) {
      collectEvidence(o.rewardEvidenceId!);
    }

    // Проверяем открытие новых локаций и события
    unlockByProgress();
    triggerEvents();

    notify(o.useResultMessage ?? 'Предмет использован.');

    return true;
  }

  // =========================
  // ENDING
  // =========================

  bool canEnd(Ending ending) {
    final allEvidenceFound = evidenceFound.length >= evidence.length;
    final allPuzzlesSolved = solvedPuzzles.length >= puzzles.length;

    switch (ending.type) {
      // «Возвращение» доступно только тому, кто действительно закрыл
      // дело: нашёл все улики и решил все головоломки дома.
      case EndingType.truth:
        return allEvidenceFound && allPuzzlesSolved;

      // «Трещина во времени» — можно остановиться раньше, собрав
      // хотя бы часть улик, но не завершив расследование.
      case EndingType.incomplete:
        return evidenceFound.length >= 3 && !allPuzzlesSolved;

      // «Тот, кого нет в архивах» — игрок дошёл до порога и запустил
      // его механизм, но не собрал полную картину улик.
      case EndingType.mystery:
        return solvedPuzzles.contains('threshold_code') && !allEvidenceFound;
    }
  }

  // =========================
  // SAVE
  // =========================

  Future<void> save() async {
    await saveService.save(this);

    notify('Игра сохранена.');
  }

  // =========================
  // LOAD
  // =========================

  Future<bool> load() async {
    final data = await saveService.load();

    if (data == null) {
      return false;
    }

    locationId = data['location'] ?? 'entrance_1927';

    _replace(
      inventory,
      data['inventory'],
    );

    _replace(
      collectedItems,
      data['collectedItems'],
    );

    _replace(
      evidenceFound,
      data['evidence'],
    );

    _replace(
      solvedPuzzles,
      data['puzzles'],
    );

    _replace(
      unlockedLocations,
      data['locations'],
    );

    _replace(
      eventsDone,
      data['events'],
    );

    _replace(
      usedObjects,
      data['usedObjects'],
    );

    unlockByProgress();

    notifyListeners();

    return true;
  }

  // =========================
  // REPLACE SET
  // =========================

  void _replace(
      Set<String> target,
      List<String>? values,
      ) {
    target
      ..clear()
      ..addAll(values ?? const []);
  }

  // =========================
  // SAVE EXISTS
  // =========================

  bool get hasAnySave => true;
}
