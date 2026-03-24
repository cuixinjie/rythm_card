class_name DefenseHandler
extends EffectHandler

func _init(p: Dictionary = {}) -> void:
	super("defense", p)

func execute(card: Card) -> void:
	var shield: int = params.get("shield", 10)
	var duration: int = params.get("duration", 1)
	_dispatch(card, {"shield": shield, "duration": duration})
