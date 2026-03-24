class_name KeyDrawDriver
extends DrawDriver

var _key: int = KEY_SPACE

func _init(cards_module: CardsModule, key: int = KEY_SPACE) -> void:
	super(cards_module)
	_key = key

func start() -> void:
	if not EventBus.has_listener("input:key_pressed", self, "_on_key_pressed"):
		EventBus.listen("input:key_pressed", self, "_on_key_pressed")

func stop() -> void:
	EventBus.unlisten("input:key_pressed", self)

func cleanup() -> void:
	stop()

func _on_key_pressed(data: Dictionary) -> void:
	if data.get("key") == _key:
		_trigger_draw()
