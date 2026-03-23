extends Node
class_name ExampleModule
## 示例模块 - 继承 Node

func initialize() -> void:
	EventBus.listen("game_started", self, "_on_game_started")

func start() -> void:
	EventBus.fire("example_ready")

func stop() -> void:
	pass

func cleanup() -> void:
	EventBus.unlisten("game_started", self)

func _on_game_started(data) -> void:
	print("收到游戏开始事件: ", data)

func do_something() -> void:
	print("执行功能")
	EventBus.fire("something_done")
