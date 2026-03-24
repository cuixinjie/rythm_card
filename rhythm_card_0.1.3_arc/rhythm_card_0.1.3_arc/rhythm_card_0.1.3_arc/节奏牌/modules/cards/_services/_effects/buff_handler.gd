class_name BuffHandler
extends EffectHandler

func _init(p: Dictionary = {}) -> void:
	super("buff", p)

func execute(card: Card) -> void:
	var buff_type: String = params.get("type", "strength")
	var value: int = params.get("value", 1)
	var duration: int = params.get("duration", 1)
	_dispatch(card, {"type": buff_type, "value": value, "duration": duration})
