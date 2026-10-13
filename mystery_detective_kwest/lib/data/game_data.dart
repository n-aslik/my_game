import 'models/models.dart';

// =========================================================================
// ПРЕДМЕТЫ
//
// Полная цепочка (каждый предмет обязательно расходуется к финалу игры):
//   old_photo      -> комбинируется со strange_lens => hidden_photo
//   flashlight     -> комбинируется с battery       => working_flashlight
//   battery        -> комбинируется с flashlight     => working_flashlight
//   strange_lens   -> комбинируется с old_photo       => hidden_photo
//   working_flashlight -> используется на lab_door (расходуется)
//   hidden_photo   -> используется на symbols_reference (расходуется)
//   old_key        -> используется на front_door (расходуется)
//   metal_plate    -> используется на altar_groove (расходуется)
//   candle         -> используется на altar_wax (расходуется)
//   silver_thread  -> используется на altar_thread (расходуется)
//
// Кроме того, по дому разбросаны фрагменты четырёх головоломок
// (символы, даты, детали схемы, ноты) — их нужно найти в ходе игры,
// прежде чем головоломка станет решаемой. Каждый фрагмент исчезает
// из инвентаря, как только соответствующая головоломка решена.
// =========================================================================

const items = <Item>[
  Item(id: 'old_photo', name: 'Старая фотография', description: 'Дом и четыре человека. На обороте дата 1927.', icon: '📷', combinable: true),
  Item(id: 'flashlight', name: 'Старый фонарь', description: 'Корпус цел, но батарейки нет.', icon: '🔦', combinable: true),
  Item(id: 'battery', name: 'Батарейка', description: 'Две рабочие батарейки.', icon: '🔋', combinable: true),
  Item(id: 'working_flashlight', name: 'Рабочий фонарь', description: 'Теперь можно исследовать тёмные места.', icon: '💡'),
  Item(id: 'strange_lens', name: 'Странная линза', description: 'Позволяет увидеть детали, которых не видно обычным глазом.', icon: '🔍', combinable: true),
  Item(id: 'hidden_photo', name: 'Фотография со скрытым символом', description: 'На обороте: ◇ △ ☉ □. Разглядеть их можно только через линзу.', icon: '🖼️'),
  Item(id: 'old_key', name: 'Ржавый ключ', description: 'Подходит к неизвестному замку.', icon: '🔑'),
  Item(id: 'metal_plate', name: 'Металлическая пластина', description: 'На ней четыре символа и следы креплений — похоже, часть механизма.', icon: '⚙️'),
  Item(id: 'candle', name: 'Чёрная свеча', description: 'Пламя почти не реагирует на ветер.', icon: '🕯️'),
  Item(id: 'silver_thread', name: 'Серебряная нить', description: 'Нить, найденная рядом с алтарём. Почти невесома.', icon: '🧵'),

  // --- Фрагменты головоломки «Символы на стене» ---
  Item(id: 'piece_symbol_diamond', name: 'Жетон с символом ◇', description: 'Небольшой металлический жетон. Похоже, часть кода, разбросанного по дому.', icon: '◇', puzzleToken: '◇'),
  Item(id: 'piece_symbol_triangle', name: 'Жетон с символом △', description: 'Такой же жетон, но с другим знаком.', icon: '△', puzzleToken: '△'),
  Item(id: 'piece_symbol_square', name: 'Жетон с символом □', description: 'Ещё один фрагмент символа со стены лаборатории.', icon: '□', puzzleToken: '□'),
  Item(id: 'piece_symbol_sun', name: 'Жетон с символом ☉', description: 'Последний из четырёх жетонов с повторяющимся узором.', icon: '☉', puzzleToken: '☉'),

  // --- Фрагменты головоломки «Хронология» ---
  Item(id: 'piece_date_1921', name: 'Клочок бумаги: «1921»', description: 'Обрывок страницы с датой.', icon: '🗓️', puzzleToken: '1921'),
  Item(id: 'piece_date_1927', name: 'Клочок бумаги: «1927»', description: 'Ещё один обрывок с датой — похоже, из той же тетради.', icon: '🗓️', puzzleToken: '1927'),
  Item(id: 'piece_date_1934', name: 'Клочок бумаги: «1934»', description: 'Дата, вырванная из хроники событий дома.', icon: '🗓️', puzzleToken: '1934'),
  Item(id: 'piece_date_1941', name: 'Клочок бумаги: «1941»', description: 'Последний обрывок — самая поздняя из найденных дат.', icon: '🗓️', puzzleToken: '1941'),

  // --- Фрагменты головоломки «Электрическая схема» ---
  Item(id: 'piece_comp_generator', name: 'Табличка «генератор»', description: 'Металлическая табличка с названием узла электрической схемы.', icon: '🔌', puzzleToken: 'генератор'),
  Item(id: 'piece_comp_switch', name: 'Табличка «выключатель»', description: 'Такая же табличка, но для другого узла схемы.', icon: '🔌', puzzleToken: 'выключатель'),
  Item(id: 'piece_comp_fuse', name: 'Табличка «предохранитель»', description: 'Деталь, судя по всему, защищающая цепь от перегрузки.', icon: '🔌', puzzleToken: 'предохранитель'),
  Item(id: 'piece_comp_lamp', name: 'Табличка «лампа»', description: 'Последняя деталь схемы — конечный потребитель энергии.', icon: '🔌', puzzleToken: 'лампа'),

  // --- Фрагменты головоломки «Музыкальная шкатулка» ---
  Item(id: 'piece_note_a', name: 'Нотный жетон «A»', description: 'Маленький жетон с нотой — явно от музыкальной шкатулки.', icon: '🎵', puzzleToken: 'A'),
  Item(id: 'piece_note_b', name: 'Нотный жетон «B»', description: 'Ещё один жетон с нотой.', icon: '🎵', puzzleToken: 'B'),
  Item(id: 'piece_note_c', name: 'Нотный жетон «C»', description: 'Третий из четырёх нотных жетонов.', icon: '🎵', puzzleToken: 'C'),
  Item(id: 'piece_note_d', name: 'Нотный жетон «D»', description: 'Последний нотный жетон — теперь мелодия шкатулки известна полностью.', icon: '🎵', puzzleToken: 'D'),
];

// Предметы, подбор которых автоматически даёт улику (не нужно решать
// отдельную головоломку ради очевидной находки).
const autoEvidenceOnPickup = <String, String>{
  'old_photo': 'photo',
};

const evidence = <Evidence>[
  Evidence(id: 'photo', title: 'Фотография 1927 года', description: 'На фотографии стоит человек, которого нет ни в одном архиве.', type: EvidenceType.photograph),
  Evidence(id: 'diary', title: 'Дневник профессора', description: 'Профессор писал о «комнате между комнатами».', type: EvidenceType.document),
  Evidence(id: 'symbol', title: 'Четыре символа', description: '◇ △ ☉ □ повторяются в разных местах дома.', type: EvidenceType.symbol),
  Evidence(id: 'lab_report', title: 'Лабораторный отчёт', description: 'Исследования продолжались после официального закрытия лаборатории.', type: EvidenceType.document),
  Evidence(id: 'audio', title: 'Аудиозапись', description: 'На записи слышен голос исчезнувшего профессора.', type: EvidenceType.audio),
  Evidence(id: 'witness', title: 'Свидетельство смотрителя', description: 'Смотритель видел свет в подвале спустя десятилетия после пожара.', type: EvidenceType.testimony),
];

const puzzles = <Puzzle>[
  Puzzle(
    id: 'safe', title: 'Код сейфа', description: '12 → 24 → 48 → ?', hint: 'Каждое число умножается на два.',
    type: PuzzleType.numeric, acceptedAnswers: ['96'], rewardItemId: 'old_key',
    tokens: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'], tokenSeparator: '', allowRepeatTokens: true,
  ),
  Puzzle(
    id: 'clock', title: 'Остановившиеся часы', description: 'В дневнике сказано: «четверть четвёртого».', hint: 'Четверть часа после трёх.',
    type: PuzzleType.logic, acceptedAnswers: ['03:15', '3:15'], rewardEvidenceId: 'diary',
    tokens: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':'], tokenSeparator: '', allowRepeatTokens: true,
  ),
  Puzzle(
    id: 'symbols', title: 'Символы на стене', description: 'Введите порядок: ◇ △ ☉ □', hint: 'Порядок показан на скрытой фотографии — используйте её на стене.',
    type: PuzzleType.symbols, acceptedAnswers: ['◇△☉□', '◇ △ ☉ □'], rewardItemId: 'metal_plate', rewardEvidenceId: 'symbol',
    tokenSeparator: '', pieceItemIds: ['piece_symbol_diamond', 'piece_symbol_triangle', 'piece_symbol_sun', 'piece_symbol_square'],
  ),
  Puzzle(
    id: 'books', title: 'Хронология', description: 'Расположите даты: 1941, 1921, 1934, 1927.', hint: 'Сначала самое раннее событие.',
    type: PuzzleType.sequence, acceptedAnswers: ['1921,1927,1934,1941', '1921 1927 1934 1941'], rewardEvidenceId: 'lab_report',
    tokenSeparator: ',', pieceItemIds: ['piece_date_1941', 'piece_date_1921', 'piece_date_1934', 'piece_date_1927'],
  ),
  Puzzle(
    id: 'electric', title: 'Электрическая схема', description: 'Соберите цепь: генератор → выключатель → предохранитель → лампа.', hint: 'Энергия идёт от источника к потребителю.',
    type: PuzzleType.electrical, acceptedAnswers: ['генератор,выключатель,предохранитель,лампа', 'генератор выключатель предохранитель лампа'], rewardEvidenceId: 'audio',
    tokenSeparator: ',', pieceItemIds: ['piece_comp_lamp', 'piece_comp_generator', 'piece_comp_fuse', 'piece_comp_switch'],
  ),
  Puzzle(
    id: 'music', title: 'Музыкальная шкатулка', description: 'Повторите: A → C → B → D.', hint: 'Повторите последовательность без пробелов.',
    type: PuzzleType.memory, acceptedAnswers: ['ACBD'],
    tokenSeparator: '', pieceItemIds: ['piece_note_d', 'piece_note_a', 'piece_note_c', 'piece_note_b'],
  ),
  Puzzle(
    id: 'secret', title: 'Секретный механизм', description: 'Введите четыре символа, которые повторяются по всему дому.', hint: 'Их порядок найден на фотографии.',
    type: PuzzleType.hiddenMessage, acceptedAnswers: ['◇△☉□'], rewardItemId: 'candle',
    tokens: ['△', '□', '◇', '☉'], tokenSeparator: '', allowRepeatTokens: false,
  ),
];

const combinations = <Combination>[
  Combination('flashlight', 'battery', 'working_flashlight'),
  Combination('old_photo', 'strange_lens', 'hidden_photo'),
];

const locations = <Location>[
  Location(id: 'entrance', name: 'Главный вход', atmosphere: 'Дождь стучит по окнам. Дом кажется заброшенным.', icon: '🚪', itemIds: ['old_photo', 'piece_symbol_diamond', 'piece_note_a', 'piece_date_1927'], objectIds: ['front_door'], exits: ['hall']),
  Location(id: 'hall', name: 'Холл', atmosphere: 'Портреты следят за каждым движением.', icon: '🏚️', itemIds: ['flashlight', 'piece_symbol_triangle', 'piece_note_b', 'piece_comp_lamp'], objectIds: ['library_door', 'kitchen_door'], exits: ['entrance', 'library', 'kitchen']),
  Location(id: 'library', name: 'Библиотека', atmosphere: 'Пыль, запах бумаги и старый сейф.', icon: '📚', itemIds: ['strange_lens', 'piece_date_1921', 'piece_comp_switch', 'piece_note_c'], objectIds: ['safe', 'books'], exits: ['hall', 'basement']),
  Location(id: 'kitchen', name: 'Кухня', atmosphere: 'Из пустой комнаты доносится тихий стук.', icon: '🍽️', itemIds: ['piece_symbol_square', 'piece_comp_fuse', 'piece_date_1934'], objectIds: ['clock'], exits: ['hall']),
  Location(id: 'basement', name: 'Подвал', atmosphere: 'Холодно. Где-то работает старый механизм.', icon: '🕳️', itemIds: ['battery', 'piece_symbol_sun', 'piece_note_d', 'piece_comp_generator', 'piece_date_1941'], objectIds: ['generator', 'lab_door'], exits: ['library', 'laboratory']),
  Location(id: 'laboratory', name: 'Лаборатория', atmosphere: 'На стенах одинаковые символы. Здесь кто-то недавно был.', icon: '⚗️', objectIds: ['symbols', 'symbols_reference', 'music'], exits: ['basement', 'secret']),
  Location(id: 'secret', name: 'Комната между комнатами', atmosphere: 'Комната не должна существовать. Воздух здесь неподвижен.', icon: '🌀', itemIds: ['silver_thread'], objectIds: ['altar', 'altar_groove', 'altar_wax', 'altar_thread'], exits: ['laboratory']),
];

const objects = <GameObject>[
  GameObject(
    id: 'front_door',
    name: 'Главная дверь',
    description: 'Заперта изнутри. Странно.',
    requiredItemId: 'old_key',
    useResultMessage: 'Ключ поворачивается в замке. Дверь была заперта изнутри — кто-то не хотел, чтобы отсюда вышли... или чтобы кто-то вошёл.',
  ),
  GameObject(id: 'library_door', name: 'Дверь библиотеки', description: 'Дверь открыта.'),
  GameObject(id: 'kitchen_door', name: 'Дверь кухни', description: 'За ней слышен слабый стук.'),
  GameObject(id: 'safe', name: 'Старый сейф', description: 'На панели четыре цифры.', puzzleId: 'safe'),
  GameObject(id: 'books', name: 'Книжная полка', description: 'Даты на корешках образуют странную последовательность.', puzzleId: 'books'),
  GameObject(id: 'clock', name: 'Старые часы', description: 'Стрелки остановились.', puzzleId: 'clock'),
  GameObject(id: 'generator', name: 'Генератор', description: 'Можно восстановить питание.', puzzleId: 'electric'),
  GameObject(
    id: 'lab_door',
    name: 'Дверь лаборатории',
    description: 'Слишком темно, чтобы найти замок.',
    requiredItemId: 'working_flashlight',
    useResultMessage: 'Луч фонаря скользит по стене и наконец находит замочную скважину. Дверь со скрипом поддаётся.',
  ),
  GameObject(id: 'symbols', name: 'Стена с символами', description: 'Символы образуют механизм.', puzzleId: 'symbols'),
  GameObject(
    id: 'symbols_reference',
    name: 'Скрытый символ на фотографии',
    description: 'Через линзу на обороте фотографии виден порядок символов.',
    requiredItemId: 'hidden_photo',
    useResultMessage: 'Вы прикладываете фотографию к стене. Порядок символов на ней совпадает с механизмом: ◇ → △ → ☉ → □.',
  ),
  GameObject(id: 'music', name: 'Музыкальная шкатулка', description: 'Внутри ещё работает механизм.', puzzleId: 'music'),
  GameObject(id: 'altar', name: 'Каменный алтарь', description: 'Четыре углубления совпадают с символами.', puzzleId: 'secret'),
  GameObject(
    id: 'altar_groove',
    name: 'Углубление алтаря',
    description: 'Одно из четырёх углублений по форме напоминает металлическую пластину.',
    requiredItemId: 'metal_plate',
    useResultMessage: 'Пластина точно входит в углубление алтаря и с щелчком фиксируется на месте.',
  ),
  GameObject(
    id: 'altar_wax',
    name: 'Чаша для свечи',
    description: 'Рядом с алтарём — небольшая каменная чаша, как будто ждущая пламя.',
    requiredItemId: 'candle',
    useResultMessage: 'Вы ставите чёрную свечу в чашу. Пламя вспыхивает само, хотя вы его не зажигали, и не колышется вовсе.',
  ),
  GameObject(
    id: 'altar_thread',
    name: 'Нити механизма',
    description: 'От алтаря тянутся тонкие бороздки — будто для нити.',
    requiredItemId: 'silver_thread',
    useResultMessage: 'Серебряная нить ложится в бороздки, соединяя края алтаря. Механизм в последний раз вздрагивает и замирает окончательно.',
  ),
];

const characters = <Character>[
  Character(id: 'caretaker', name: 'Смотритель Марк', role: 'Смотритель дома', description: 'Старик, который слишком много знает о доме.'),
  Character(id: 'professor', name: 'Профессор Орлов', role: 'Исчезнувший исследователь', description: 'Учёный, проводивший эксперименты в доме.'),
  Character(id: 'unknown', name: 'Неизвестный', role: 'Фигура с фотографии', description: 'Человек, чьё имя отсутствует во всех документах.'),
];

const dialogues = <Dialogue>[
  Dialogue(
    characterId: 'caretaker',
    intro: 'Смотритель долго смотрит на вас, затем на фотографию.',
    options: [
      DialogueOption(
        text: 'Спросить о доме',
        response: 'Этот дом пустует почти сорок лет. Но свет в подвале иногда включается сам — я видел это своими глазами уже после того пожара.',
        grantsEvidenceId: 'witness',
      ),
      DialogueOption(text: 'Спросить о профессоре', response: 'Не произносите его имя ночью. После его исчезновения дом изменился.'),
      DialogueOption(text: 'Показать скрытую фотографию', response: 'Этого человека не должно быть на фотографии. Я видел его однажды... в 1988 году.', requiredEvidence: 'symbol'),
    ],
  ),
];

const events = <GameEvent>[
  GameEvent(id: 'library_return', locationId: 'library', message: 'Книга сама падает с полки. На её месте появляется выцарапанная дата 1941.', requiredPuzzles: ['safe']),
  GameEvent(id: 'lab_voice', locationId: 'laboratory', message: 'В пустой лаборатории звучит голос: «Ты слишком поздно».', requiredPuzzles: ['music']),
  GameEvent(id: 'room_shift', locationId: 'secret', message: 'Стены комнаты на секунду исчезают. Вы видите тот же дом, но в 1927 году.', requiredEvidence: ['diary', 'symbol']),
];

const links = <InvestigationLink>[
  InvestigationLink(fromId: 'photo', toId: 'symbol', explanation: 'Символ найден на скрытой стороне фотографии.'),
  InvestigationLink(fromId: 'symbol', toId: 'diary', explanation: 'В дневнике профессор использовал те же символы.'),
  InvestigationLink(fromId: 'diary', toId: 'lab_report', explanation: 'Дневник указывает на лабораторию.'),
  InvestigationLink(fromId: 'lab_report', toId: 'audio', explanation: 'Отчёт и запись подтверждают продолжение экспериментов.'),
  InvestigationLink(fromId: 'witness', toId: 'audio', explanation: 'Свидетель слышал свет и звук из подвала — то же место, что и на записи.'),
];

const endings = <Ending>[
  Ending(type: EndingType.truth, title: 'Правда', text: 'Вы собрали все доказательства и разгадали каждый механизм дома. Эксперимент профессора был связан не с вызовом духов, а с попыткой открыть пространство между моментами времени. Теперь вы понимаете, почему люди исчезали — и почему дом не отпускает тех, кто подходит слишком близко к разгадке.'),
  Ending(type: EndingType.incomplete, title: 'Незаконченная история', text: 'Вы раскрыли часть тайны, но доказательств недостаточно, чтобы понять всё. Комната между комнатами исчезает, оставляя вопрос: куда делся профессор?'),
  Ending(type: EndingType.mystery, title: 'За гранью', text: 'Вы запустили механизм алтаря, но сделали последний шаг, так и не собрав полной картины. В зеркале появляется ваша собственная фигура, стоящая в доме задолго до вашего рождения.'),
];
