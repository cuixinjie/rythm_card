class_name DrawDriver
extends RefCounted

var _cards_module: CardsModule

func _init(cards_module: CardsModule) -> void:
	_cards_module = cards_module

func start() -> void:
	pass

func stop() -> void:
	pass

func cleanup() -> void:
	pass

func _trigger_draw() -> void:
	_cards_module.request_draw()
