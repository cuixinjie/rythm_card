class_name DebuffHandler
extends EffectHandler

func _init(p: Dictionary = {}) -> void:
	super("debuff", p)

func execute(card: Card) -> void:
	var debuff_type: String = params.get("type", "weakness")
	var value: int = params.get("value", 1)
	var duration: int = params.get("duration", 1)
	_dispatch(card, {"type": debuff_type, "value": value, "duration": duration})
