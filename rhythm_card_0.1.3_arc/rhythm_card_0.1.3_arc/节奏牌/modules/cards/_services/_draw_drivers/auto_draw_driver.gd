class_name AutoDrawDriver
extends DrawDriver

var _timer: Timer
var _interval: float = 2.0

func _init(cards_module: CardsModule, interval: float = 2.0) -> void:
	super(cards_module)
	_interval = interval
	_timer = Timer.new()
	_timer.one_shot = false

func start() -> void:
	_cards_module.add_child(_timer)
	if not _timer.timeout.is_connected(_on_timer):
		_timer.timeout.connect(_on_timer)
	_timer.start(_interval)

func stop() -> void:
	if _timer.timeout.is_connected(_on_timer):
		_timer.timeout.disconnect(_on_timer)
	_timer.stop()

func cleanup() -> void:
	stop()
	if is_instance_valid(_timer):
		_timer.queue_free()
	_timer = null

func _on_timer() -> void:
	_trigger_draw()
