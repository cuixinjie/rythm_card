class_name AttackHandler
extends EffectHandler

func _init(p: Dictionary = {}) -> void:
	super("attack", p)

func execute(card: Card) -> void:
	var damage: int = params.get("damage", 10)
	var target: String = params.get("target", "enemy")
	_dispatch(card, {"damage": damage, "target": target})
