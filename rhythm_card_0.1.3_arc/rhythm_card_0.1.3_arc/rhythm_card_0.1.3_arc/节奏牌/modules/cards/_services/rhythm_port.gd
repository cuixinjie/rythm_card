class_name RhythmPort
extends RefCounted

## ========== 依赖 ==========
var _cards_module: CardsModule

## ========== 队列状态 ==========
## 玩家打出的卡牌，按出牌顺序排队的 FIFO 队列
var _card_queue: Array[Card] = []

## ========== 当前判定状态 ==========
## 同一时刻只有一张卡在节奏轴上判定
var _current_card: Card = null
var _current_charge: int = 0
var _is_rhythm_busy: bool = false  ## 是否有卡正在节奏轴上

## ========== 命中计数器 ==========
## 连续命中数，决定是否从队列取下一张卡
var _consecutive_hits: int = 0

## ========== 常量 ==========
const CONSECUTIVE_HITS_THRESHOLD: int = 1  ## 每命中 1 次就从队列取下一张（可配置）

func _init(cards_module: CardsModule) -> void:
	_cards_module = cards_module
	_subscribe_events()

func cleanup() -> void:
	_unsubscribe_events()
	_card_queue.clear()
	_current_card = null
	_is_rhythm_busy = false
	_consecutive_hits = 0

## ========== 事件订阅 ==========
## rhythm_axis 发出的所有事件，RhythmPort 全部接收并处理
## rhythm_axis 完全不知道 cards 模块的存在

func _subscribe_events() -> void:
	EventBus.listen("rhythm:beat_judged", self, "_on_beat_judged")
	EventBus.listen("rhythm:sequence_completed", self, "_on_sequence_completed")

func _unsubscribe_events() -> void:
	EventBus.unlisten("rhythm:beat_judged", self)
	EventBus.unlisten("rhythm:sequence_completed", self)

## ========== 公共接口（供 CardsModule 调用） ==========

## 玩家打出卡牌时调用，将卡牌加入队列
func enqueue_card(card: Card) -> void:
	_card_queue.append(card)
	EventBus.fire("rhythm:queue_updated", {
		"queue_size": _card_queue.size()
	})
	## 如果当前没有卡在判定，立即取出下一张
	if not _is_rhythm_busy:
		_start_next_card()

## 清空队列（回合结束时调用）
func clear_queue() -> void:
	_card_queue.clear()
	EventBus.fire("rhythm:queue_cleared", {})

## 获取当前队列（供 UI 显示）
func get_queue() -> Array[Card]:
	return _card_queue.duplicate()

func get_current_card() -> Card:
	return _current_card

func is_busy() -> bool:
	return _is_rhythm_busy

## ========== 私有：队列推进 ==========

func _start_next_card() -> void:
	if _card_queue.is_empty():
		_is_rhythm_busy = false
		return

	_current_card = _card_queue.pop_front()
	_current_charge = 0
	_is_rhythm_busy = true
	_consecutive_hits = 0

	EventBus.fire("rhythm:card_started", {
		"card_instance_id": _current_card.instance_id,
		"card_id": _current_card.data.card_id,
		"required_charge": _current_card.data.required_charge,
	})

## ========== rhythm:beat_judged ==========
## rhythm_axis 发出的节拍判定结果
## RhythmPort 负责：
##   1. 计算充能
##   2. 维护 _consecutive_hits（连续命中数）
##   3. 维护 _current_charge（当前卡牌的充能计数）
##   4. 判断是否充能完成

func _on_beat_judged(data: Dictionary) -> void:
	if not _is_rhythm_busy or _current_card == null:
		return

	var result: int = data.get("result", 0)
	var delta: float = data.get("delta", 0.0)

	if result == JUDGE_PERFECT or result == JUDGE_GOOD:
		_consecutive_hits += 1
		_current_charge += 1
	elif result == JUDGE_MISS:
		_consecutive_hits = 0

	EventBus.fire("cards:charge_updated", {
		"card": _current_card,
		"consecutive_hits": _consecutive_hits,
		"current_charge": _current_charge,
		"required_charge": _current_card.data.required_charge,
		"is_completed": _current_charge >= _current_card.data.required_charge,
	})

	if _current_charge >= _current_card.data.required_charge:
		_finish_current_card()

func _finish_current_card() -> void:
	if _current_card == null:
		return

	var card: Card = _current_card
	_current_card = null
	_is_rhythm_busy = false
	_consecutive_hits = 0
	_current_charge = 0

	## 通知 cards 模块：这张卡充能完成，触发效果
	_cards_module._on_card_charged(card)

	## 发完效果后，自动取队列下一张
	_start_next_card()

## ========== rhythm:sequence_completed ==========
## rhythm_axis 发出的节拍序列完成事件
## 某些节奏轴设计：每个节拍序列对应一组 beat，完成后发出此事件
## RhythmPort 收到后，检查是否需要从队列取下一张

func _on_sequence_completed(data: Dictionary) -> void:
	## 如果当前卡还在判定，等待 beat_judged 自然结束
	## 如果当前卡已完成，_start_next_card 已在 _finish_current_card 中调用过
	pass
