class_name Card
extends RefCounted

## ========== 静态数据 ==========
var data: CardData

## ========== 身份 ==========
var instance_id: String

## ========== 唯一状态（只管位置，不管节奏） ==========
## 注意：充能计数不再由 Card 管理，由 RhythmPort 管理
## 注意：PLAYING 阶段已移除，卡打出后仍在 HAND 阶段
var stage: Stage = Stage.DECK

## ========== 纹理（实例级覆盖，支持每张卡独立外观） ==========
var _texture: Texture2D = null
var _texture_loaded: bool = false

## ========== 阶段枚举 ==========
enum Stage {
	DECK,       # 在牌堆中
	HAND,       # 在手牌中（打出后在队列中等待，或正在判定）
	CHARGED,    # 充能完成，效果可触发
	EFFECT_USED,# 效果已触发
	DISCARD     # 在弃牌区
}

## ========== 静态工厂 ==========
static func create(data: CardData, instance_id: String) -> Card:
	var card := Card.new()
	card.data = data
	card.instance_id = instance_id
	card.stage = Stage.DECK
	card._texture = null
	card._texture_loaded = false
	return card

## ========== 纹理访问（懒加载，支持实例覆盖） ==========
## 优先级：实例覆盖纹理 > CardData.texture_path > null

func get_texture() -> Texture2D:
	if _texture != null:
		return _texture  # 实例级覆盖
	if _texture_loaded:
		return null      # 已尝试加载但失败

	_texture_loaded = true
	if data == null or data.texture_path == "":
		return null

	if ResourceLoader.exists(data.texture_path):
		_texture = load(data.texture_path)
	return _texture

## 设置实例级覆盖纹理（优先级最高，四个实例可以有不同的外观）
func set_override_texture(tex: Texture2D) -> void:
	_texture = tex

## 清除覆盖纹理，恢复使用 CardData.texture_path
func clear_override_texture() -> void:
	_texture = null
	_texture_loaded = false

## ========== 重置（复用卡牌时） ==========
func reset() -> void:
	stage = Stage.DECK
	_texture = null
	_texture_loaded = false
