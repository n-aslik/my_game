import 'models/models.dart';

// =========================================================================
// ТАЙНА ЗАБРОШЕННОГО ДОМА 2: ДОМ МЕЖДУ ЭПОХАМИ
//
// Прямое продолжение первой части. Механизм алтаря сработал — и вместо
// того чтобы просто заглянуть в прошлое, детектив провалился в сам
// 1927 год, в тот же дом, но за много десятилетий до пожара. Профессор
// Орлов ещё жив и работает над своим аппаратом. Нужно понять, что
// произошло на самом деле, и найти способ вернуться — или остаться.
//
// ЦЕПОЧКА ПРЕДМЕТОВ (каждый расходуется к финалу игры):
//   pocket_watch      -> используется на apparatus_time_slot (расходуется)
//   oil_lamp          -> комбинируется с lamp_oil => lit_lamp
//   lamp_oil          -> комбинируется с oil_lamp  => lit_lamp
//   lit_lamp          -> используется на dark_greenhouse_corner (расходуется,
//                        награда — glass_prism)
//   glass_prism       -> комбинируется с torn_letter => revealed_letter
//   torn_letter       -> комбинируется с glass_prism  => revealed_letter
//   revealed_letter   -> используется на apparatus_letter_slot (расходуется)
//   copper_coil       -> комбинируется с silver_wire => repaired_conductor
//   silver_wire       -> комбинируется с copper_coil => repaired_conductor
//   repaired_conductor-> используется на apparatus_wire_slot (расходуется)
//   brass_key         -> используется на workshop_door (расходуется)
//   medallion         -> используется на threshold_lock (расходуется)
//
// Кроме того, по дому разбросаны фрагменты четырёх головоломок
// (символы, даты, детали аппарата, ноты колоколов) — их нужно найти
// в ходе игры, прежде чем головоломка станет решаемой. Каждый
// фрагмент исчезает из инвентаря, как только головоломка решена.
// =========================================================================

const items = <Item>[
  Item(id: 'pocket_watch', name: 'Карманные часы', description: 'Остановились на без пятнадцати полночь. На крышке гравировка: «Орлов, 1927».', icon: '⌚'),
  Item(id: 'oil_lamp', name: 'Масляная лампа', description: 'Стекло цело, но резервуар пуст.', icon: '🏮', combinable: true),
  Item(id: 'lamp_oil', name: 'Масло для лампы', description: 'Небольшая фляга с маслом.', icon: '🛢️', combinable: true),
  Item(id: 'lit_lamp', name: 'Зажжённая лампа', description: 'Теперь можно осветить самые тёмные углы дома.', icon: '💡'),
  Item(id: 'glass_prism', name: 'Стеклянная призма', description: 'Разлагает свет на спектр — сквозь неё видно то, что скрыто обычным взглядом.', icon: '🔺', combinable: true),
  Item(id: 'torn_letter', name: 'Разорванное письмо', description: 'Часть текста выцвела. Кажется, там что-то написано невидимыми чернилами.', icon: '✉️', combinable: true),
  Item(id: 'revealed_letter', name: 'Проявленное письмо', description: 'Через призму видно: «Аппарат нельзя запускать без всех трёх контуров».', icon: '📜'),
  Item(id: 'copper_coil', name: 'Медная катушка', description: 'Часть обмотки для аппарата.', icon: '🧲', combinable: true),
  Item(id: 'silver_wire', name: 'Серебряная проволока', description: 'Тонкая и почти невесомая. Похожа на нить, которую находят десятилетия спустя.', icon: '➰', combinable: true),
  Item(id: 'repaired_conductor', name: 'Восстановленный контур', description: 'Катушка и проволока вместе образуют рабочий проводник.', icon: '🔧'),
  Item(id: 'brass_key', name: 'Латунный ключ', description: 'Ключ от мастерской профессора.', icon: '🗝️'),
  Item(id: 'medallion', name: 'Медальон профессора', description: 'На обороте те же четыре символа: ◇ △ ☉ □.', icon: '🎖️'),

  // --- Фрагменты головоломки «Рабочий журнал» ---
  Item(id: 'piece_date_1919', name: 'Вырванная страница: «1919»', description: 'Страница из журнала профессора с датой.', icon: '🗓️', puzzleToken: '1919'),
  Item(id: 'piece_date_1922', name: 'Вырванная страница: «1922»', description: 'Ещё одна страница — похоже, из той же тетради.', icon: '🗓️', puzzleToken: '1922'),
  Item(id: 'piece_date_1925', name: 'Вырванная страница: «1925»', description: 'Страница с более поздней записью.', icon: '🗓️', puzzleToken: '1925'),
  Item(id: 'piece_date_1927', name: 'Вырванная страница: «1927»', description: 'Последняя из найденных страниц журнала.', icon: '🗓️', puzzleToken: '1927'),

  // --- Фрагменты головоломки «Символы на воротах мастерской» ---
  Item(id: 'piece_symbol_diamond', name: 'Клеймо с символом ◇', description: 'Металлическое клеймо — такое же, как на воротах мастерской.', icon: '◇', puzzleToken: '◇'),
  Item(id: 'piece_symbol_triangle', name: 'Клеймо с символом △', description: 'Ещё одно клеймо с повторяющимся узором.', icon: '△', puzzleToken: '△'),
  Item(id: 'piece_symbol_sun', name: 'Клеймо с символом ☉', description: 'Клеймо, найденное среди растений оранжереи.', icon: '☉', puzzleToken: '☉'),
  Item(id: 'piece_symbol_square', name: 'Клеймо с символом □', description: 'Последнее из четырёх клейм — найдено прямо в мастерской.', icon: '□', puzzleToken: '□'),

  // --- Фрагменты головоломки «Хронометрический аппарат» ---
  Item(id: 'piece_comp_core', name: 'Табличка «сердечник»', description: 'Табличка с названием центральной детали аппарата.', icon: '🔩', puzzleToken: 'сердечник'),
  Item(id: 'piece_comp_coil', name: 'Табличка «катушка»', description: 'Деталь, отвечающая за передачу энергии по контуру.', icon: '🔩', puzzleToken: 'катушка'),
  Item(id: 'piece_comp_circuit', name: 'Табличка «контур»', description: 'Соединительный узел аппарата.', icon: '🔩', puzzleToken: 'контур'),
  Item(id: 'piece_comp_mirror', name: 'Табличка «зеркало»', description: 'Последняя деталь — то, через что проходит свет аппарата.', icon: '🔩', puzzleToken: 'зеркало'),

  // --- Фрагменты головоломки «Подвальные колокола» ---
  Item(id: 'piece_note_a', name: 'Нотный жетон «A»', description: 'Жетон с нотой от механизма колоколов.', icon: '🎼', puzzleToken: 'A'),
  Item(id: 'piece_note_b', name: 'Нотный жетон «B»', description: 'Ещё один нотный жетон.', icon: '🎼', puzzleToken: 'B'),
  Item(id: 'piece_note_c', name: 'Нотный жетон «C»', description: 'Третий из четырёх нотных жетонов.', icon: '🎼', puzzleToken: 'C'),
  Item(id: 'piece_note_d', name: 'Нотный жетон «D»', description: 'Последний нотный жетон — мелодия колоколов известна полностью.', icon: '🎼', puzzleToken: 'D'),
];

// В этой части все улики выдаются через головоломки и диалог, поэтому
// автоматических улик при подборе предметов нет — но константа оставлена
// для единообразия архитектуры с первой частью и на случай расширения.
const autoEvidenceOnPickup = <String, String>{};

const evidence = <Evidence>[
  Evidence(id: 'notebook', title: 'Рабочий журнал', description: 'Записи профессора о «комнате между комнатами» — том самом месте, куда попадёт детектив спустя десятилетия.', type: EvidenceType.document),
  Evidence(id: 'garden_log', title: 'Дневник оранжереи', description: 'Растения в оранжерее растут и увядают за считаные минуты — рядом с аппаратом время течёт иначе.', type: EvidenceType.testimony),
  Evidence(id: 'blueprint', title: 'Чертёж аппарата', description: 'Схема устройства и четыре символа, отмечающие контрольные точки контура.', type: EvidenceType.symbol),
  Evidence(id: 'core_reading', title: 'Показания сердечника', description: 'Аппарат не открывает портал в другое место — он открывает портал в другое время.', type: EvidenceType.object),
  Evidence(id: 'echo_record', title: 'Запись эха колоколов', description: 'В подвале колокола звонят сами по себе — эхо доносится будто из будущего.', type: EvidenceType.audio),
  Evidence(id: 'confession', title: 'Признание профессора', description: 'Орлов знает, что кто-то однажды придёт из будущего искать ответы — и, кажется, ждёт именно вас.', type: EvidenceType.testimony),
];

const puzzles = <Puzzle>[
  Puzzle(
    id: 'desk', title: 'Стол профессора', description: 'Замок с шифром: 3, 6, 12, ?', hint: 'Каждое число удваивается.',
    type: PuzzleType.numeric, acceptedAnswers: ['24'], rewardItemId: 'brass_key',
    tokens: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'], tokenSeparator: '', allowRepeatTokens: true,
  ),
  Puzzle(
    id: 'ledger', title: 'Рабочий журнал', description: 'Расставьте записи по датам: 1925, 1919, 1927, 1922.', hint: 'Начните с самой ранней записи.',
    type: PuzzleType.sequence, acceptedAnswers: ['1919,1922,1925,1927', '1919 1922 1925 1927'], rewardEvidenceId: 'notebook',
    tokenSeparator: ',', pieceItemIds: ['piece_date_1925', 'piece_date_1919', 'piece_date_1927', 'piece_date_1922'],
  ),
  Puzzle(
    id: 'greenhouse_clock', title: 'Солнечные часы оранжереи', description: 'Тень падает на отметку «без пятнадцати полночь», хотя на улице день.', hint: 'Сверьтесь с гравировкой на карманных часах.',
    type: PuzzleType.logic, acceptedAnswers: ['23:45', '11:45'], rewardEvidenceId: 'garden_log',
    tokens: ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', ':'], tokenSeparator: '', allowRepeatTokens: true,
  ),
  Puzzle(
    id: 'gate_symbols', title: 'Символы на воротах мастерской', description: 'Введите порядок символов на воротах: ◇ △ ☉ □', hint: 'Тот же порядок, что и на медальоне профессора.',
    type: PuzzleType.symbols, acceptedAnswers: ['◇△☉□', '◇ △ ☉ □'], rewardEvidenceId: 'blueprint',
    tokenSeparator: '', pieceItemIds: ['piece_symbol_triangle', 'piece_symbol_sun', 'piece_symbol_square', 'piece_symbol_diamond'],
  ),
  Puzzle(
    id: 'apparatus', title: 'Хронометрический аппарат', description: 'Соберите контур: сердечник → катушка → контур → зеркало.', hint: 'Энергия должна дойти от сердечника до зеркала.',
    type: PuzzleType.electrical, acceptedAnswers: ['сердечник,катушка,контур,зеркало', 'сердечник катушка контур зеркало'], rewardItemId: 'medallion', rewardEvidenceId: 'core_reading',
    tokenSeparator: ',', pieceItemIds: ['piece_comp_mirror', 'piece_comp_core', 'piece_comp_circuit', 'piece_comp_coil'],
  ),
  Puzzle(
    id: 'chimes', title: 'Подвальные колокола', description: 'Повторите звон: B → D → A → C.', hint: 'Повторите последовательность без пробелов.',
    type: PuzzleType.memory, acceptedAnswers: ['BDAC'], rewardEvidenceId: 'echo_record',
    tokenSeparator: '', pieceItemIds: ['piece_note_a', 'piece_note_c', 'piece_note_b', 'piece_note_d'],
  ),
  Puzzle(
    id: 'threshold_code', title: 'Код порога', description: 'Введите четыре символа, что повторяются по всему дому — на воротах, медальоне и в письме.', hint: 'Тот же порядок, что и в мастерской.',
    type: PuzzleType.hiddenMessage, acceptedAnswers: ['◇△☉□'],
    tokens: ['□', '◇', '△', '☉'], tokenSeparator: '', allowRepeatTokens: false,
  ),
];

const combinations = <Combination>[
  Combination('oil_lamp', 'lamp_oil', 'lit_lamp'),
  Combination('torn_letter', 'glass_prism', 'revealed_letter'),
  Combination('copper_coil', 'silver_wire', 'repaired_conductor'),
];

const locations = <Location>[
  Location(id: 'entrance_1927', name: 'Прихожая, 1927', atmosphere: 'Дом полон света и голосов — совсем не похож на руины будущего. Дверь за спиной исчезла.', icon: '🚪', itemIds: ['pocket_watch', 'piece_date_1927', 'piece_symbol_diamond', 'piece_note_a'], objectIds: ['entrance_door_1927'], exits: ['hall_1927']),
  Location(id: 'hall_1927', name: 'Холл, 1927', atmosphere: 'На стенах свежие портреты. Где-то играет граммофон.', icon: '🏛️', itemIds: ['oil_lamp', 'piece_date_1919', 'piece_symbol_triangle', 'piece_comp_mirror'], objectIds: ['study_door', 'workshop_door'], exits: ['entrance_1927', 'study', 'conservatory', 'workshop']),
  Location(id: 'study', name: 'Кабинет профессора', atmosphere: 'Стол завален бумагами. Пахнет чернилами и воском.', icon: '🗂️', itemIds: ['torn_letter', 'piece_date_1922', 'piece_comp_core', 'piece_note_b'], objectIds: ['desk', 'ledger'], exits: ['hall_1927']),
  Location(id: 'conservatory', name: 'Оранжерея', atmosphere: 'Растения здесь цветут и увядают за минуты. Воздух звенит от напряжения.', icon: '🌿', itemIds: ['piece_symbol_sun', 'piece_comp_coil', 'piece_note_c'], objectIds: ['dark_greenhouse_corner', 'sundial'], exits: ['hall_1927']),
  Location(id: 'workshop', name: 'Мастерская', atmosphere: 'Огромный аппарат из меди и стекла занимает весь центр комнаты.', icon: '⚙️', itemIds: ['copper_coil', 'piece_date_1925', 'piece_symbol_square', 'piece_comp_circuit', 'piece_note_d'], objectIds: ['gate_symbols', 'apparatus', 'apparatus_time_slot', 'apparatus_letter_slot', 'apparatus_wire_slot'], exits: ['hall_1927', 'cellar_1927']),
  Location(id: 'cellar_1927', name: 'Подвал, 1927', atmosphere: 'Колокола на стене звонят сами по себе — без ветра, без причины.', icon: '🔔', itemIds: ['lamp_oil', 'silver_wire'], objectIds: ['chimes'], exits: ['workshop', 'threshold']),
  Location(id: 'threshold', name: 'Порог между эпохами', atmosphere: 'Воздух здесь дрожит, как поверхность воды. Сквозь дрожь видно два дома одновременно.', icon: '🌀', itemIds: [], objectIds: ['threshold_code', 'threshold_lock'], exits: ['cellar_1927']),
];

const objects = <GameObject>[
  GameObject(id: 'entrance_door_1927', name: 'Входная дверь', description: 'Дверь, через которую вы вошли, ведёт лишь в туман — обратного пути здесь нет.'),
  GameObject(id: 'study_door', name: 'Дверь кабинета', description: 'Приоткрыта. Слышен скрип пера.'),
  GameObject(
    id: 'workshop_door',
    name: 'Дверь мастерской',
    description: 'Заперта на замок. Профессор никого сюда не пускает.',
    requiredItemId: 'brass_key',
    useResultMessage: 'Латунный ключ подходит. Дверь мастерской со скрипом открывается — внутри гудит аппарат.',
  ),
  GameObject(id: 'desk', name: 'Письменный стол', description: 'На столе кодовый замок для ящика.', puzzleId: 'desk'),
  GameObject(id: 'ledger', name: 'Рабочий журнал', description: 'Страницы перепутаны и не подшиты по датам.', puzzleId: 'ledger'),
  GameObject(
    id: 'dark_greenhouse_corner',
    name: 'Тёмный угол оранжереи',
    description: 'Слишком темно, чтобы разглядеть, что скрыто среди листвы.',
    requiredItemId: 'lit_lamp',
    rewardItemId: 'glass_prism',
    useResultMessage: 'В свете лампы среди листьев обнаруживается забытая стеклянная призма — судя по пыли, пролежала здесь давно.',
  ),
  GameObject(id: 'sundial', name: 'Солнечные часы', description: 'Стрелка отбрасывает тень, которая не соответствует положению солнца.', puzzleId: 'greenhouse_clock'),
  GameObject(id: 'gate_symbols', name: 'Символы на воротах мастерской', description: 'Символы складываются в узор — но какой у них порядок?', puzzleId: 'gate_symbols'),
  GameObject(id: 'apparatus', name: 'Хронометрический аппарат', description: 'Сердце всей мастерской. Почти собран — не хватает нескольких частей.', puzzleId: 'apparatus'),
  GameObject(
    id: 'apparatus_time_slot',
    name: 'Гнездо для часового механизма',
    description: 'Небольшое углубление в панели аппарата, по форме напоминающее карманные часы.',
    requiredItemId: 'pocket_watch',
    useResultMessage: 'Часы точно входят в гнездо. Стрелки на панели аппарата начинают двигаться в обратную сторону.',
  ),
  GameObject(
    id: 'apparatus_letter_slot',
    name: 'Паз для чертежа',
    description: 'Узкая щель, куда, судя по всему, нужно вложить бумагу с формулой.',
    requiredItemId: 'revealed_letter',
    useResultMessage: 'Письмо ложится в паз. Слова профессора «нельзя запускать без всех трёх контуров» на миг вспыхивают на панели.',
  ),
  GameObject(
    id: 'apparatus_wire_slot',
    name: 'Клемма для проводника',
    description: 'Оголённые контакты ждут третий, недостающий контур.',
    requiredItemId: 'repaired_conductor',
    useResultMessage: 'Проводник встаёт на место. Аппарат гудит ровнее — теперь у него есть все три контура.',
  ),
  GameObject(id: 'chimes', name: 'Колокола подвала', description: 'Четыре колокола разного размера, каждый звучит на свой лад.', puzzleId: 'chimes'),
  GameObject(id: 'threshold_code', name: 'Код на пороге', description: 'На самой границе света и тьмы вырезаны символы.', puzzleId: 'threshold_code'),
  GameObject(
    id: 'threshold_lock',
    name: 'Замок порога',
    description: 'Углубление в форме медальона — точно такое же, как носит профессор.',
    requiredItemId: 'medallion',
    useResultMessage: 'Медальон занимает своё место. Порог между эпохами приходит в движение — дальше уже ваш выбор.',
  ),
];

const characters = <Character>[
  Character(id: 'young_professor', name: 'Профессор Орлов', role: 'Автор хронометрического аппарата', description: 'Моложе, чем на записях 1988 года, но с тем же тревожным взглядом.'),
  Character(id: 'young_caretaker', name: 'Марк, юный смотритель', role: 'Помощник по дому', description: 'Тот самый смотритель — только на шестьдесят лет моложе.'),
];

const dialogues = <Dialogue>[
  Dialogue(
    characterId: 'young_professor',
    intro: 'Профессор поднимает взгляд от чертежей, будто ждал вас все эти годы.',
    options: [
      DialogueOption(
        text: 'Спросить об аппарате',
        response: 'Это не портал в другое место, поймите. Это портал в другое время. Ошибка на день — и вы окажетесь не там, где нужно.',
      ),
      DialogueOption(
        text: 'Спросить, ждал ли он гостя',
        response: 'Я записал в журнале: однажды придёт человек из другого времени и задаст правильные вопросы. Похоже, это вы.',
        grantsEvidenceId: 'confession',
      ),
      DialogueOption(
        text: 'Рассказать, что будет с домом',
        response: 'Пожар? Значит, я не успею закончить вовремя... Тогда тем более нужно, чтобы аппарат заработал сегодня.',
        requiredEvidence: 'core_reading',
      ),
    ],
  ),
];

const events = <GameEvent>[
  GameEvent(id: 'desk_tremor', locationId: 'study', message: 'Ящик стола открывается сам, будто кто-то помог изнутри. На дне — свежая царапина: «не открывай раньше времени».', requiredPuzzles: ['desk']),
  GameEvent(id: 'workshop_hum', locationId: 'workshop', message: 'Аппарат на миг вспыхивает синим и произносит вашим собственным голосом: «Ты уже был здесь».', requiredPuzzles: ['gate_symbols']),
  GameEvent(id: 'threshold_vision', locationId: 'threshold', message: 'Сквозь дрожащий воздух на мгновение виден тот же дом — обгоревший, пустой, спустя десятилетия.', requiredEvidence: ['notebook', 'blueprint']),
];

const links = <InvestigationLink>[
  InvestigationLink(fromId: 'confession', toId: 'notebook', explanation: 'Профессор признаётся в том, о чём сам же пишет в журнале.'),
  InvestigationLink(fromId: 'notebook', toId: 'garden_log', explanation: 'Журнал описывает те же временные искажения, что видны в оранжерее.'),
  InvestigationLink(fromId: 'garden_log', toId: 'blueprint', explanation: 'Искажения времени совпадают с контрольными точками на чертеже аппарата.'),
  InvestigationLink(fromId: 'blueprint', toId: 'core_reading', explanation: 'Чертёж объясняет, что именно показывает сердечник аппарата.'),
  InvestigationLink(fromId: 'core_reading', toId: 'echo_record', explanation: 'Показания сердечника совпадают по времени с колокольным эхом из будущего.'),
];

const endings = <Ending>[
  Ending(
    type: EndingType.truth,
    title: 'Возвращение',
    text: 'Вы собрали все доказательства и до конца поняли, как работает аппарат профессора Орлова. С медальоном и всеми контурами на месте вы проходите порог осознанно — и возвращаетесь в свой 1988 год с доказательствами в руках. Пожар, исчезновение профессора, символы на стенах — теперь всё складывается в единую картину. Дело закрыто.',
  ),
  Ending(
    type: EndingType.incomplete,
    title: 'Трещина во времени',
    text: 'Вы узнали часть правды, но аппарат так и не заработал в полную силу. Порог схлопывается сам собой, отбрасывая вас обратно — с обрывками воспоминаний и вопросом, что случилось с профессором на самом деле.',
  ),
  Ending(
    type: EndingType.mystery,
    title: 'Тот, кого нет в архивах',
    text: 'Вы запустили механизм порога, но сделали это слишком рано, не собрав полной картины. Свет поглощает вас — и через мгновение вы стоите рядом с профессором и смотрителем, а где-то щёлкает затвор фотоаппарата. Много лет спустя детектив из будущего найдёт эту фотографию и не узнает на ней себя.',
  ),
];
