class_name EffectRegistry
extends RefCounted

var _handlers: Dictionary = {}  # effect_id → EffectHandler

func register(handler: EffectHandler) -> void:
	_handlers[handler.effect_id] = handler

func execute(card: Card) -> void:
	var effect_id: String = card.data.effect_id
	var handler: EffectHandler = _handlers.get(effect_id, null)
	if handler == null:
		push_warning("[EffectRegistry] 未注册效果处理器: " + effect_id)
		return
	handler.execute(card)

func has_handler(effect_id: String) -> bool:
	return _handlers.has(effect_id)
