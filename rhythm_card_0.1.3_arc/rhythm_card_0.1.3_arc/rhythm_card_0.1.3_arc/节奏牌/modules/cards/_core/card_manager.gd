class_name CardManager
extends RefCounted

## ========== 常量 ==========
const JUDGE_PERFECT: int = 1
const JUDGE_GOOD: int = 2
const JUDGE_MISS: int = 3

## ========== 唯一容器 ==========
## Card.stage 是唯一位置来源，不再维护 _deck/_hand/_discard 副本数组
var _all_cards: Array[Card] = []

## ========== 配置 ==========
var _max_hand_size: int = 10
var _database_path: String = ""

## ========== 数据库 ==========
var _database: Resource
var _data_cache: Dictionary = {}  # card_id → CardData

## ========== 状态 ==========
var _is_initialized: bool = false

## ========== 工具 ==========
var _id_counter: int = 0

func _make_id() -> String:
	_id_counter += 1
	return "card_%09d" % _id_counter

## ========== 生命周期 ==========

func initialize(config_path: String = "") -> void:
	if _is_initialized:
		push_warning("[CardManager] 已初始化，忽略重复调用")
		return

	if config_path != "":
		_database_path = config_path
		load_database(config_path)
	elif _database_path != "":
		load_database(_database_path)

	_is_initialized = true

func is_initialized() -> bool:
	return _is_initialized

## ========== 数据库加载 ==========

func load_database(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("[CardManager] 数据库不存在: " + path)
		return
	_database = load(path)
	_build_initial_deck()
	_shuffle_deck()

func _build_initial_deck() -> void:
	if _database == null:
		push_error("[CardManager] 数据库未加载，无法构建牌堆")
		return

	var all_data: Array[CardData] = _database.get_all_cards()
	for data: CardData in all_data:
		if data == null:
			push_warning("[CardManager] 跳过空卡牌数据")
			continue

		var quantity: int = data.quantity if "quantity" in data else 1
		for i in range(quantity):
			var instance_id := _make_id()
			var card := Card.create(data, instance_id)
			_all_cards.append(card)

## Fisher-Yates 洗牌
func _shuffle_deck() -> void:
	var deck_indices: Array[int] = []
	for i in range(_all_cards.size()):
		if _all_cards[i].stage == Card.Stage.DECK:
			deck_indices.append(i)

	for i in range(deck_indices.size() - 1, 0, -1):
		var j := randi() % (i + 1)
		var idx_i: int = deck_indices[i]
		var idx_j: int = deck_indices[j]
		var tmp: Card = _all_cards[idx_i]
		_all_cards[idx_i] = _all_cards[idx_j]
		_all_cards[idx_j] = tmp

func get_card_data(card_id: String) -> CardData:
	if _data_cache.has(card_id):
		return _data_cache[card_id]
	if _database == null:
		return null
	var data: CardData = _database.get_card(card_id)
	if data != null:
		_data_cache[card_id] = data
	return data

func set_max_hand_size(size: int) -> void:
	_max_hand_size = size

## ========== 核心操作 ==========

## 回合开始：抽牌
func start_turn(cards_to_draw: int) -> void:
	for i in range(cards_to_draw):
		if get_hand().size() >= _max_hand_size:
			break
		draw()

## 回合结束：手牌全弃
func end_turn() -> void:
	for card in get_hand():
		card.stage = Card.Stage.DISCARD

## 抽一张牌（随机抽取）
func draw() -> Card:
	if get_hand().size() >= _max_hand_size:
		return null

	if get_deck().is_empty():
		_refill_deck_from_discard()

	var deck_cards: Array[Card] = get_deck()
	if deck_cards.is_empty():
		return null

	var rand_idx := randi() % deck_cards.size()
	var card: Card = deck_cards[rand_idx]
	card.stage = Card.Stage.HAND
	return card

func _refill_deck_from_discard() -> void:
	for card in get_discard_pile():
		card.stage = Card.Stage.DECK
	_shuffle_deck()

## 出牌
func play_card(card: Card) -> bool:
	if card.stage != Card.Stage.HAND:
		return false
	# stage 保持在 HAND，队列状态由 RhythmPort 维护
	return true

## 充能完成
func complete_card(card: Card) -> void:
	if card.stage == Card.Stage.EFFECT_USED:
		return
	card.stage = Card.Stage.CHARGED

## 弃牌
func discard_card(card: Card) -> void:
	card.stage = Card.Stage.EFFECT_USED

func discard_to_pile(card: Card) -> void:
	card.stage = Card.Stage.DISCARD
	card.reset()

## 重建牌堆
func rebuild_deck_from_discard() -> void:
	for card in get_discard_pile():
		card.stage = Card.Stage.DECK
	_shuffle_deck()

## 出牌取消
func cancel_card(card: Card) -> bool:
	if card.stage != Card.Stage.HAND:
		return false
	card.stage = Card.Stage.DISCARD
	return true

## ========== 核心查询（基于 Card.stage 的派生查询） ==========

func get_cards_by_stage(stage: int) -> Array[Card]:
	var result: Array[Card] = []
	for card in _all_cards:
		if card.stage == stage:
			result.append(card)
	return result

func get_hand() -> Array[Card]:
	return get_cards_by_stage(Card.Stage.HAND)

func get_deck() -> Array[Card]:
	return get_cards_by_stage(Card.Stage.DECK)

func get_discard_pile() -> Array[Card]:
	return get_cards_by_stage(Card.Stage.DISCARD)

func get_charged_cards() -> Array[Card]:
	return get_cards_by_stage(Card.Stage.CHARGED)

func find_card(instance_id: String) -> Card:
	for card in _all_cards:
		if card.instance_id == instance_id:
			return card
	return null

func get_card_count_by_stage(stage: int) -> int:
	var count := 0
	for card in _all_cards:
		if card.stage == stage:
			count += 1
	return count

## ========== 完整卡牌信息 ==========

func get_card_full_info(card: Card) -> Dictionary:
	if card == null or card.data == null:
		return {}
	return {
		"instance_id": card.instance_id,
		"card_id": card.data.card_id,
		"card_name": card.data.card_name,
		"card_type": card.data.card_type,
		"description": card.data.description,
		"stage": Card.Stage.keys()[card.stage],
		"cost": card.data.cost,
		"required_charge": card.data.required_charge,
		"rhythm_keys": card.data.rhythm_keys,
		"combo_tags": card.data.combo_tags,
		"effect_id": card.data.effect_id,
		"texture": card.get_texture()
	}
