extends Node
class_name ExampleModule
## 示例模块 - 继承 Node
## 用于展示模块的标准结构，可作为新模块的模板

func initialize() -> void:
	EventBus.listen("game_started", self, "_on_game_started")

func start() -> void:
	EventBus.fire("example_ready")

func stop() -> void:
	# 停止时暂无需要清理的资源，保留为空以便未来扩展
	pass

func cleanup() -> void:
	EventBus.unlisten("game_started", self)

func _on_game_started(data) -> void:
	if OS.is_debug_build():
		print("[ExampleModule] 收到游戏开始事件: ", data)

func do_something() -> void:
	# TODO: 实现具体功能
	EventBus.fire("something_done")
