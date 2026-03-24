class_name SpecialHandler
extends EffectHandler

func _init(p: Dictionary = {}) -> void:
	super("special", p)

func execute(card: Card) -> void:
	var special_id: String = params.get("special_id", "")
	var effect_data: Dictionary = params.get("effect_data", {})
	_dispatch(card, {"special_id": special_id, "effect_data": effect_data})
