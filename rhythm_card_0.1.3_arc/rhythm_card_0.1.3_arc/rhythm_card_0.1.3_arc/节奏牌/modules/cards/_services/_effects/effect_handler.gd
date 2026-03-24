class_name EffectHandler
extends RefCounted

var effect_id: String = ""
var params: Dictionary = {}

func _init(id: String, p: Dictionary = {}) -> void:
	effect_id = id
	params = p

func execute(card: Card) -> void:
	push_error("[EffectHandler] 子类必须重写 execute(): " + effect_id)

func _dispatch(card: Card, result_data: Dictionary) -> void:
	EventBus.fire("cards:effect_triggered", {
		"card": card,
		"effect_id": effect_id,
		"result": result_data,
	})
