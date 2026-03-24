class_name ClickDrawDriver
extends DrawDriver

var _target_node: Node = null
var _is_active: bool = false  # FIX-6: 管理激活状态

func _init(cards_module: CardsModule) -> void:
	super(cards_module)

func set_target(node: Node) -> void:
	if _target_node != null:
		_stop_listening()
	_target_node = node
	if _target_node != null and _is_active:
		_start_listening()

func start() -> void:
	_is_active = true
	if _target_node != null:
		_start_listening()

func stop() -> void:
	_is_active = false
	_stop_listening()

func cleanup() -> void:
	stop()
	_target_node = null

func _start_listening() -> void:
	if _target_node != null and not _target_node.gui_input.is_connected(_on_gui_input):
		_target_node.gui_input.connect(_on_gui_input)

func _stop_listening() -> void:
	if _target_node != null and _target_node.gui_input.is_connected(_on_gui_input):
		_target_node.gui_input.disconnect(_on_gui_input)

func _on_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_trigger_draw()
