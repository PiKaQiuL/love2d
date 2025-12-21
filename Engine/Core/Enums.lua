-- Engine/Enums.lua
-- 常用枚举集中定义，减少字符串/数字硬编码
--
-- 枚举集合：
-- - ButtonState: string 按钮状态（normal/hover/pressed/disabled）
-- - MouseButton: number 鼠标键（left=1/right=2/middle=3）
-- - LayoutDirection: string 布局方向（vertical/horizontal）
-- - Align: string 对齐方式（start/center/end）

---@alias ButtonState "normal"|"hover"|"pressed"|"disabled"
---@alias MouseButton 1|2|3
---@alias LayoutDirection "vertical"|"horizontal"
---@alias Align "start"|"center"|"end"

---@class Enums
---@field ButtonState table<string, ButtonState>
---@field MouseButton table<string, MouseButton>
---@field LayoutDirection table<string, LayoutDirection>
---@field Align table<string, Align>

local Enums = {}

---@type { normal: ButtonState, hover: ButtonState, pressed: ButtonState, disabled: ButtonState }
Enums.ButtonState = {
  normal = "normal",
  hover = "hover",
  pressed = "pressed",
  disabled = "disabled"
}

---@type { left: MouseButton, right: MouseButton, middle: MouseButton }
Enums.MouseButton = {
  left = 1,
  right = 2,
  middle = 3
}

---@type { vertical: LayoutDirection, horizontal: LayoutDirection }
Enums.LayoutDirection = {
  vertical = "vertical",
  horizontal = "horizontal"
}

---@type { start: Align, center: Align, ["end"]: Align }
Enums.Align = {
  start = "start",
  center = "center",
  ["end"] = "end"
}

return Enums
