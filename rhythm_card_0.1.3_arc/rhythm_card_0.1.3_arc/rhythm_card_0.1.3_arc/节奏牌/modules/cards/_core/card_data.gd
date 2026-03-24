class_name CardData
extends Resource

## 身份
@export var card_id: String = ""
@export var card_name: String = ""
@export var card_type: String = ""  # "attack" / "defense" / "buff" / "debuff" / "special"
@export var description: String = ""

## 数量（FIX-1: 初始牌堆中该卡牌的数量）
@export var quantity: int = 1

## 节奏轴
@export var required_charge: int = 3  # 充能次数
@export var rhythm_keys: Array[int] = []  # 按键序列，如 [KEY_A, KEY_S, KEY_D]
@export var rhythm_timeout: float = 1.0  # 顺序按键超时（秒）

## 连携
@export var combo_points: int = 0
@export var combo_tags: Array[String] = []  # 连携标签，用于 ComboTracker 检测

## 效果
@export var effect_id: String = ""  # EffectHandler 的 effect_id
@export var effect_params: Dictionary = {}  # 效果参数字典

## 表现
@export var texture_path: String = ""
@export var cost: int = 0  # 打出消耗
