-- Engine/UI/Defaults.lua
-- 集中 UI 默认样式，减少组件内硬编码

--
---
---@class Defaults
---@field textColor number[]
---@field panel { fill: number[], border: number[], borderWidth: integer }
---@field buttonColors { normal: number[], hover: number[], pressed: number[], disabled: number[], border: number[], text: number[], focus: number[] }
---@field inputColors { bg: number[], border: number[], text: number[], placeholder: number[] }
---@field listColors { bg: number[], border: number[], text: number[], hover: number[], selected: number[] }
---@field layoutColors { bg: number[]|nil, border: number[], borderWidth: integer }
local Defaults = {}

---@type number[]
Defaults.textColor = {1, 1, 1, 1}

---@type { fill: number[], border: number[], borderWidth: integer }
Defaults.panel = {
    fill = {0.1, 0.1, 0.12, 0.9},
    border = {1, 1, 1, 0.8},
    borderWidth = 1
}

---@type { normal: number[], hover: number[], pressed: number[], disabled: number[], border: number[], text: number[], focus: number[] }
Defaults.buttonColors = {
    normal = {0.18, 0.18, 0.22, 1},
    hover = {0.22, 0.22, 0.26, 1},
    pressed = {0.12, 0.12, 0.16, 1},
    disabled = {0.1, 0.1, 0.1, 0.6},
    border = {1, 1, 1, 0.9},
    text = {1, 1, 1, 1},
    focus = {0.9, 0.9, 0.3, 1}
}

---@type { bg: number[], border: number[], text: number[], placeholder: number[] }
Defaults.inputColors = {
    bg = {0.1, 0.1, 0.1, 1},
    border = {1, 1, 1, 0.9},
    text = {1, 1, 1, 1},
    placeholder = {0.7, 0.7, 0.7, 0.7}
}

---@type { bg: number[], border: number[], text: number[], hover: number[], selected: number[] }
Defaults.listColors = {
    bg = {0.08, 0.08, 0.08, 1},
    border = {1, 1, 1, 0.9},
    text = {1, 1, 1, 1},
    hover = {0.2, 0.2, 0.2, 0.8},
    selected = {0.2, 0.4, 0.2, 0.8}
}

---@type { bg: number[]|nil, border: number[], borderWidth: integer }
Defaults.layoutColors = {
    bg = nil,
    border = {1, 1, 1, 0.3},
    borderWidth = 1
}

return Defaults
