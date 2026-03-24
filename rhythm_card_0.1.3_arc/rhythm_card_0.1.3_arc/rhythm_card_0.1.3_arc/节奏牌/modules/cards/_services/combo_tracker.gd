class_name ComboTracker
extends RefCounted

var _recent: Array[Card] = []
var _window_size: int
var _definitions: Array[Dictionary] = []

func _init(window_size: int) -> void:
	_window_size = window_size
	_subscribe_events()

func cleanup() -> void:
	_unsubscribe_events()

func load_definitions(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_warning("[ComboTracker] 连携定义文件不存在: " + path)
		return
	var res: Resource = load(path)
	if res == null:
		return
	_definitions = res.get("combos", [])

func _subscribe_events() -> void:
	EventBus.listen("cards:card_charged", self, "_on_card_charged")

func _unsubscribe_events() -> void:
	EventBus.unlisten("cards:card_charged", self)

func record(card: Card) -> void:
	_recent.append(card)
	if _recent.size() > _window_size:
		_recent.pop_front()
	_check_combo(card)

func _check_combo(latest: Card) -> void:
	for def in _definitions:
		var required_tags: Array[String] = def.get("tags", [])
		if required_tags.is_empty():
			continue
		if latest.data.combo_tags.has_all(required_tags):
			_trigger_combo(def)

func _trigger_combo(def: Dictionary) -> void:
	EventBus.fire("combo:detected", {
		"combo_id": def.get("id", ""),
		"bonus": def.get("bonus", {}),
	})
