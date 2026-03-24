class_name CardDatabase
extends Resource

## CardData 集合，供 CardManager 加载
##FIX-1: 提供 get_all_cards() 方法，供 _build_initial_deck() 使用
@export var cards: Array[Resource] = []

func get_card(card_id: String) -> CardData:
	for res in cards:
		if res is CardData and res.card_id == card_id:
			return res
	return null

func get_all_cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for res in cards:
		if res is CardData:
			result.append(res)
	return result
