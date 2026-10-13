enum EvidenceType { document, photograph, object, audio, testimony, symbol }

enum PuzzleType {
  numeric,
  sequence,
  symbols,
  memory,
  logic,
  electrical,
  hiddenMessage,
}

enum EndingType { truth, incomplete, mystery }

class Item {
  final String id;
  final String name;
  final String description;
  final String icon;
  final bool combinable;

  // Если предмет — это фрагмент шифра головоломки (находится в доме
  // по ходу игры), здесь хранится символ/слово, которое он добавляет
  // в набор вставляемых вариантов на экране головоломки.
  final String? puzzleToken;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.combinable = false,
    this.puzzleToken,
  });
}

class Evidence {
  final String id;
  final String title;
  final String description;
  final EvidenceType type;

  const Evidence({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
  });
}

class Puzzle {
  final String id;
  final String title;
  final String description;
  final String hint;
  final PuzzleType type;
  final List<String> acceptedAnswers;
  final String? rewardItemId;
  final String? rewardEvidenceId;

  // Варианты, которые игрок вставляет тапом вместо того, чтобы печатать
  // ответ. Порядок в списке — это порядок отображения кнопок (для
  // паззлов на упорядочивание он намеренно перемешан).
  final List<String> tokens;

  // Чем соединяются вставленные токены при сборке ответа:
  // '' для символов/букв, ',' для последовательностей дат и слов.
  final String tokenSeparator;

  // true — токен можно вставлять повторно (например, цифровая клавиатура);
  // false — каждый токен используется один раз и пропадает после вставки.
  final bool allowRepeatTokens;

  // Если непусто — токены этой головоломки не выдаются сразу
  // целиком, а становятся доступны по мере того, как игрок находит
  // соответствующие предметы-фрагменты в доме (их id перечислены
  // здесь). Поле tokens в этом случае не используется.
  final List<String> pieceItemIds;

  const Puzzle({
    required this.id,
    required this.title,
    required this.description,
    required this.hint,
    required this.type,
    required this.acceptedAnswers,
    this.rewardItemId,
    this.rewardEvidenceId,
    this.tokens = const [],
    this.tokenSeparator = '',
    this.allowRepeatTokens = false,
    this.pieceItemIds = const [],
  });

  bool accepts(String answer) {
    final normalized = answer.trim().toLowerCase().replaceAll(' ', '');
    return acceptedAnswers.any(
      (a) => a.toLowerCase().replaceAll(' ', '') == normalized,
    );
  }
}

class Combination {
  final String a;
  final String b;
  final String result;

  const Combination(this.a, this.b, this.result);

  bool matches(String x, String y) {
    return (x == a && y == b) ||
        (x == b && y == a);
  }
}

class GameObject {
  final String id;
  final String name;
  final String description;
  final String? puzzleId;
  final String? requiredItemId;
  final String? rewardItemId;
  final String? rewardEvidenceId;
  final String? useResultMessage;

  const GameObject({
    required this.id,
    required this.name,
    required this.description,
    this.puzzleId,
    this.requiredItemId,
    this.rewardItemId,
    this.rewardEvidenceId,
    this.useResultMessage,
  });
}

class Location {
  final String id;
  final String name;
  final String atmosphere;
  final String icon;
  final List<String> itemIds;
  final List<String> objectIds;
  final List<String> exits;

  const Location({
    required this.id,
    required this.name,
    required this.atmosphere,
    required this.icon,
    this.itemIds = const [],
    this.objectIds = const [],
    this.exits = const [],
  });
}

class Character {
  final String id;
  final String name;
  final String role;
  final String description;

  const Character({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
  });
}

class DialogueOption {
  final String text;
  final String response;
  final String? requiredEvidence;
  final String? requiredItem;
  final String? grantsEvidenceId;

  const DialogueOption({
    required this.text,
    required this.response,
    this.requiredEvidence,
    this.requiredItem,
    this.grantsEvidenceId,
  });

  bool available(Set<String> evidence, Set<String> inventory) =>
      (requiredEvidence == null || evidence.contains(requiredEvidence)) &&
      (requiredItem == null || inventory.contains(requiredItem));
}

class Dialogue {
  final String characterId;
  final String intro;
  final List<DialogueOption> options;

  const Dialogue({
    required this.characterId,
    required this.intro,
    required this.options,
  });
}

class GameEvent {
  final String id;
  final String locationId;
  final String message;
  final List<String> requiredPuzzles;
  final List<String> requiredEvidence;

  const GameEvent({
    required this.id,
    required this.locationId,
    required this.message,
    this.requiredPuzzles = const [],
    this.requiredEvidence = const [],
  });
}

class InvestigationLink {
  final String fromId;
  final String toId;
  final String explanation;

  const InvestigationLink({
    required this.fromId,
    required this.toId,
    required this.explanation,
  });
}

class Ending {
  final EndingType type;
  final String title;
  final String text;

  const Ending({
    required this.type,
    required this.title,
    required this.text,
  });
}
