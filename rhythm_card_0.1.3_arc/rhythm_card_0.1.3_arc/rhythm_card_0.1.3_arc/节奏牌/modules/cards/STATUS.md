# 卡牌模块 — 项目状态

> 最后更新: 2026-03-21 by AI:Cursor

## 当前进度

卡牌系统已完成 v3.1 架构设计（微内核架构）。代码实现尚未开始。

### 架构设计
- `发牌系统架构书v3.1` — ✅ 完成（微内核架构版）
- `发牌系统架构书v3.0` — 保留（历史参考）
- `发牌系统架构书v2.0` — 保留（历史参考）

### 进行中
- 实现 `_core/card_manager.gd` — CardManager 内核

### 待开始（基于 v3.1）
- 实现 `data/configs/card_database.tres` — 卡牌数据 Resource
- 实现 `data/configs/combo_definitions.tres` — 连携定义配置
- 实现 `_core/card_data.gd` — CardData Resource 类
- 实现 `_core/card.gd` — Card 实体类
- 实现 `cards_module.gd` — 模块入口
- 实现 `_services/rhythm_port.gd` — 节奏轴端口
- 实现 `_services/combo_tracker.gd` — 连携追踪
- 实现 `_services/_effects/` — 5 个效果处理器
- 实现 `contracts/cards-rhythm.contract.md` — 事件契约
- 实现 `scenes/test/test_cards.tscn` — 测试场景

## 架构备忘（v3.1 微内核）

- **核心理念**: 一个类管状态（CardManager），一个类管数据（Card + CardData），业务逻辑全是事件驱动的服务
- **核心层仅 3 个类**: CardManager + Card + CardData
- **Card.stage 唯一来源**: 移除 `_deck/_hand/_discard` 数组，`get_cards_by_stage()` 派生查询
- **发牌驱动**: `DrawDriver` 接口 + 3 种实现（AutoDrawDriver / KeyDrawDriver / ClickDrawDriver），运行时热插拔
- **效果触发**: `EffectRegistry` 管理 effect_id → Handler 映射，`_on_card_charged()` 中调用
- **rhythm context_id**: `RhythmPort` 监听 `rhythm:context_started` 回填，O(1) 查找表
- **事件驱动**: 所有服务间无直接调用，通过 EventBus 解耦
- **总文件数**: ~16 个脚本 + 2 个数据 + 1 个契约

## 下一步建议

1. 实现 `data/configs/card_database.tres` — 卡牌数据 Resource（需含 `get_all_cards()` 方法）
2. 实现 `data/configs/combo_definitions.tres` — 连携定义配置
3. 实现 `_core/card_data.gd` — CardData Resource 类（含 `quantity` 字段）
4. 实现 `_core/card.gd` — Card 实体类（含 `Card.create()` 工厂方法）
5. ~~实现 `_core/card_manager.gd` — CardManager 内核（含 `_build_initial_deck()`、`get_cards_by_stage()`、`_playing_by_context`）~~ ✅ 完成
6. 实现 `cards_module.gd` — 模块入口（含 `EffectRegistry` 注入）
7. 实现 `_services/draw_driver.gd` + 3 个驱动 — 发牌器
8. 实现 `_services/rhythm_port.gd` — 含 `rhythm:context_started` 监听
9. 实现 `_services/combo_tracker.gd` — 连携追踪
10. 实现 `_services/_effects/effect_registry.gd` — 效果注册表
11. 实现 `_services/_effects/` — 5 个效果处理器
12. 实现 `contracts/cards-rhythm.contract.md` — 事件契约（含 `rhythm:context_started`）
13. 实现 `scenes/test/test_cards.tscn` — 测试场景
