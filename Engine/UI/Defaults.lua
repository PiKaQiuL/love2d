-- Engine/UI/Defaults.lua
-- 集中 UI 默认样式，减少组件内硬编码
-- 模块：UI 默认样式
-- 功能：提供 UI 组件默认颜色和样式，支持 Color 对象
-- 依赖：Engine.Utils.Color
-- 作者：Team
-- 修改时间：2025-12-23

local Color = require("Engine.Utils.Color")

--
---
---@class Defaults
---@field textColor Color
---@field panel { fill: Color, border: Color, borderWidth: integer }
---@field buttonColors { normal: Color, hover: Color, pressed: Color, disabled: Color, border: Color, text: Color, focus: Color }
---@field inputColors { bg: Color, border: Color, text: Color, placeholder: Color }
---@field listColors { bg: Color, border: Color, text: Color, hover: Color, selected: Color }
---@field layoutColors { bg: Color|nil, border: Color, borderWidth: integer }
---@field progressColors { bg: Color, fill: Color, border: Color }
local Defaults = {}

---@type Color
Defaults.textColor = Color.WHITE

---@type { fill: Color, border: Color, borderWidth: integer }
Defaults.panel = {
    fill = Color(0.1, 0.1, 0.12, 0.9),
    border = Color(1, 1, 1, 0.8),
    borderWidth = 1
}

---@type { normal: Color, hover: Color, pressed: Color, disabled: Color, border: Color, text: Color, focus: Color }
Defaults.buttonColors = {
    normal = Color(0.18, 0.18, 0.22, 1),
    hover = Color(0.22, 0.22, 0.26, 1),
    pressed = Color(0.12, 0.12, 0.16, 1),
    disabled = Color(0.1, 0.1, 0.1, 0.6),
    border = Color(1, 1, 1, 0.9),
    text = Color.WHITE,
    focus = Color(0.9, 0.9, 0.3, 1)
}

---@type { bg: Color, border: Color, text: Color, placeholder: Color }
Defaults.inputColors = {
    bg = Color(0.1, 0.1, 0.1, 1),
    border = Color(1, 1, 1, 0.9),
    text = Color.WHITE,
    placeholder = Color(0.7, 0.7, 0.7, 0.7)
}

---@type { bg: Color, border: Color, text: Color, hover: Color, selected: Color }
Defaults.listColors = {
    bg = Color(0.08, 0.08, 0.08, 1),
    border = Color(1, 1, 1, 0.9),
    text = Color.WHITE,
    hover = Color(0.2, 0.2, 0.2, 0.8),
    selected = Color(0.2, 0.4, 0.2, 0.8)
}

---@type { bg: Color|nil, border: Color, borderWidth: integer }
Defaults.layoutColors = {
    bg = nil,
    border = Color(1, 1, 1, 0.3),
    borderWidth = 1
}

---@type { bg: Color, fill: Color, border: Color }
Defaults.progressColors = {
    bg = Color(0.08, 0.08, 0.08, 1),
    fill = Color(0.6, 0.8, 1.0, 0.9),
    border = Color(1, 1, 1, 0.3)
}

return Defaults
