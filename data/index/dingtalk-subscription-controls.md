# CET-6 钉钉订阅控制与配置入口

## 目标

在不改动对外发送链路的前提下，先把 CET-6 钉钉订阅的**内部控制机制**与**内容/频率配置入口**固定下来，避免后续只能靠手工改脚本或临时记忆维护。

本文件只定义：
1. 订阅状态怎么表示
2. 可以执行哪些控制动作
3. 内容类型与频率怎么配置
4. 这些配置如何回写到 `dingtalk-state.json`

---

## 一、订阅状态机

### 可用状态

- `active`：订阅启用，允许按既定频率继续推送
- `paused`：订阅暂停，不发送新内容，但保留历史与配置
- `stopped`：订阅已停止；后续若恢复，需显式切回 `active`

### 状态切换规则

- `active -> paused`：用于临时停发，但不丢失当前配置
- `paused -> active`：恢复原订阅
- `active/paused -> stopped`：明确停用
- `stopped -> active`：重新启用；默认沿用最近一次有效配置

---

## 二、控制动作入口

后续内部统一只认以下 3 类控制动作：

### 1. 启动订阅

动作名：`start`

效果：
- 若当前为 `paused` 或 `stopped`，切回 `active`
- 记录 `lastControlAction = start`
- 更新 `lastControlAt`

### 2. 暂停订阅

动作名：`pause`

效果：
- 当前状态切为 `paused`
- 保留现有内容与频率配置
- 记录 `lastControlAction = pause`
- 更新 `lastControlAt`

### 3. 恢复订阅

动作名：`resume`

效果：
- 仅在 `paused` 或 `stopped` 后使用
- 状态切为 `active`
- 沿用最近一次有效配置
- 记录 `lastControlAction = resume`
- 更新 `lastControlAt`

> 注：若后续确实需要“彻底停用”，统一走 `stopped` 状态，但当前 Todo 主线先固定 `start / pause / resume` 这三个最小闭环动作。

---

## 三、内容类型配置入口

### `contentTypes`

用于决定当前订阅允许发送哪些 CET-6 内容。建议先支持以下布尔开关：

- `vocab`：词汇/短语
- `sentence`：例句/中英互译句子
- `translation`：翻译题素材
- `writing`：写作素材
- `reminder`：正式学习提醒
- `review`：复盘/追缴类内容

### 默认建议

当前阶段默认：
- `vocab: true`
- `sentence: true`
- `translation: true`
- `writing: true`
- `reminder: false`
- `review: false`

原因：
- 目前已观察到词汇/句子类推送在跑
- 正式提醒与追缴提醒仍受作息窗口和真实反馈依赖，暂不自动放开

---

## 四、频率配置入口

### `schedule`

用于表达“多久发一次”与“允许什么时间段发”。

建议最小字段：

- `mode`：`interval` 或 `fixed`
- `intervalMinutes`：间隔推送分钟数
- `activeHours.start`：允许发送起始时间（本地时区）
- `activeHours.end`：允许发送结束时间（本地时区）
- `maxPerDay`：每日最多发送条数

### 当前默认值

- `mode: interval`
- `intervalMinutes: 10`
- `activeHours.start: 12:20`
- `activeHours.end: 22:30`
- `maxPerDay: 24`

说明：
- 这里先对齐当前已观察到的词汇/句子推送节奏
- 若后续加入正式提醒，不应与高频素材推送混在同一条配置里硬编码

---

## 五、`dingtalk-state.json` 建议结构

```json
{
  "subscription": {
    "status": "active",
    "lastControlAction": "start",
    "lastControlAt": "2026-03-15T14:24:00+08:00"
  },
  "contentTypes": {
    "vocab": true,
    "sentence": true,
    "translation": true,
    "writing": true,
    "reminder": false,
    "review": false
  },
  "schedule": {
    "mode": "interval",
    "intervalMinutes": 10,
    "activeHours": {
      "start": "12:20",
      "end": "22:30"
    },
    "maxPerDay": 24
  },
  "recent": []
}
```

---

## 六、回写规则

- 控制动作发生时：优先回写 `subscription`
- 内容类型调整时：只改 `contentTypes`
- 频率调整时：只改 `schedule`
- 推送历史继续写入 `recent` 或 `dingtalk-task.log`
- 不把“推送成功”误写成“订阅配置已优化完成”

---

## 七、当前结论

本轮先把钉钉订阅的**状态控制**与**配置字段**固定为内部标准件：
- 控制动作：`start / pause / resume`
- 配置入口：`contentTypes / schedule`
- 状态落点：`dingtalk-state.json`

这样后续即使继续优化提醒策略，也不会再回到“只有发送日志，没有订阅控制面”的状态。
