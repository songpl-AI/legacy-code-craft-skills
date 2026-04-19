# 命名约定规范

## UI 节点命名

| 前缀 | 类型 | 示例 |
|------|------|------|
| `Btn_` | Button | `Btn_Close`, `Btn_Claim` |
| `Txt_` | TextMeshPro | `Txt_Title`, `Txt_Count` |
| `Img_` | Image | `Img_Avatar`, `Img_Progress` |
| `Panel_` | 面板容器 | `Panel_Main`, `Panel_Item` |
| `Node_` | 空节点 | `Node_List` |

## 循环节点后缀

- `_00`, `_01`, ..., `_08`
- 示例：`Img_Dot_00`, `Item_00`

## 高亮/变体后缀

- `_glod` - 金色/高亮
- `_normal` - 普通状态
- 示例：`Img_Dot_00_glod`

## 函数命名

```lua
-- 事件处理：On + 动作 + Click/Event
function {{CLASS_NAME}}:OnCloseClick()
function {{CLASS_NAME}}:OnEventName()

-- HTTP 请求：Request + 功能
function {{CLASS_NAME}}:RequestBoost()
function {{CLASS_NAME}}:FetchLevelConfig()

-- UI 刷新：Refresh + 目标
function {{CLASS_NAME}}:RefreshProgress()
function {{CLASS_NAME}}:RefreshAll()

-- 初始化：Init + 目标
function {{CLASS_NAME}}:InitUI()
function {{CLASS_NAME}}:InitLabels()
```

## 变量命名

```lua
-- 驼峰命名
local mapId = 123
local userList = {}

-- UI 组件：self. + 节点名（去掉下划线）
self.btnClose -- 对应 Btn_Close
self.txtTitle -- 对应 Txt_Title
```

## 事件命名

- 全大写下划线
- 示例：`HOME_ROOM_JUMP`, `PINDIAN_LEVEL_AWARD_SHOW`

## TAG 命名

```lua
local TAG = "[模块功能名]"
```
