-- Engine/UI/Style.lua
-- 主题与样式：为控件应用统一风格
-- 模块：主题与样式
-- 功能：集中维护控件配色，批量应用到节点树
-- 依赖：Engine.Object, Engine.UI.Button, Engine.UI.Panel, Engine.UI.Label, Engine.UI.TextInput, Engine.UI.ListView
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：applyTree 会遍历整棵节点树；在控件大量变更时考虑只对变化部分应用或延后统一应用。

local Object = require("Engine.Core.Object")
local Button = require("Engine.UI.Button")
local Panel = require("Engine.UI.Panel")
local Label = require("Engine.UI.Label")
local TextInput = require("Engine.UI.TextInput")
local ListView = require("Engine.UI.ListView")
local Layout = require("Engine.UI.Layout")

---
---@class ThemePanel
---@field bg Color
---@field border Color
---@field borderWidth integer

---@class ThemeText
---@field color Color

---@class ThemeButton
---@field normal Color
---@field hover Color
---@field pressed Color
---@field disabled Color
---@field border Color
---@field text Color
---@field focus Color

---@class ThemeInput
---@field bg Color
---@field border Color
---@field text Color
---@field placeholder Color

---@class ThemeList
---@field bg Color
---@field border Color
---@field text Color
---@field hover Color
---@field selected Color

---@class ThemeLayout
---@field bg Color|nil
---@field border Color
---@field borderWidth integer

---@class Theme
---@field panel ThemePanel
---@field text ThemeText
---@field button ThemeButton
---@field input ThemeInput
---@field list ThemeList
---@field layout ThemeLayout

---@class Style : Object
---@field theme Theme
local Style = Object:extend()

---
---@param theme Theme|nil
function Style:init(theme)
    self.theme = theme or {
        panel = { bg = {0.1,0.1,0.12,0.9}, border = {1,1,1,0.8}, borderWidth = 1 },
        text = { color = {1,1,1,1} },
        button = {
            normal = {0.18,0.18,0.22,1},
            hover = {0.22,0.22,0.26,1},
            pressed = {0.12,0.12,0.16,1},
            disabled = {0.1,0.1,0.1,0.6},
            border = {1,1,1,0.9},
            text = {1,1,1,1},
            focus = {0.9,0.9,0.3,1}
        },
        input = {
            bg = {0.1,0.1,0.1,1},
            border = {1,1,1,0.9},
            text = {1,1,1,1},
            placeholder = {0.7,0.7,0.7,0.7}
        },
        list = {
            bg = {0.08,0.08,0.08,1},
            border = {1,1,1,0.9},
            text = {1,1,1,1},
            hover = {0.2,0.2,0.2,0.8},
            selected = {0.2,0.4,0.2,0.8}
        },
        layout = {
            bg = nil,
            border = {1,1,1,0.3},
            borderWidth = 1
        }
    }
end

---
---@param theme Theme|nil
function Style:setTheme(theme)
    self.theme = theme or self.theme
end

---@return Theme
function Style:getTheme()
    return self.theme
end

---@param btn Button
function Style:applyButton(btn)
    if not btn or not btn.is or not btn:is(Button) then return end
    btn.colors = {
        normal = self.theme.button.normal,
        hover = self.theme.button.hover,
        pressed = self.theme.button.pressed,
        disabled = self.theme.button.disabled,
        border = self.theme.button.border,
        text = self.theme.button.text,
        focus = self.theme.button.focus
    }
end

---@param panel Panel
function Style:applyPanel(panel)
    if not panel or not panel.is or not panel:is(Panel) then return end
    panel.fill = self.theme.panel.bg
    panel.border = self.theme.panel.border
    panel.borderWidth = self.theme.panel.borderWidth or 1
end

---@param label Label
function Style:applyLabel(label)
    if not label or not label.is or not label:is(Label) then return end
    label.color = self.theme.text.color
end

---@param input TextInput
function Style:applyTextInput(input)
    if not input or not input.is or not input:is(TextInput) then return end
    input.colors = {
        bg = self.theme.input.bg,
        border = self.theme.input.border,
        text = self.theme.input.text,
        placeholder = self.theme.input.placeholder
    }
end

---@param list ListView
function Style:applyListView(list)
    if not list or not list.is or not list:is(ListView) then return end
    list.colors = {
        bg = self.theme.list.bg,
        border = self.theme.list.border,
        text = self.theme.list.text,
        hover = self.theme.list.hover,
        selected = self.theme.list.selected
    }
end

---@param layout Layout
function Style:applyLayout(layout)
    if not layout or not layout.is or not layout:is(Layout) then return end
    layout.bg = self.theme.layout.bg
    layout.border = self.theme.layout.border
    layout.borderWidth = self.theme.layout.borderWidth or 1
end

-- 批量应用：遍历节点树，对已知控件应用主题
---@param root any
---@param fn fun(node:any)
local function traverse(root, fn)
    if not root then return end
    fn(root)
    if root.children then
        for i = 1, #root.children do
            traverse(root.children[i], fn)
        end
    end
end

---@param root any
function Style:applyTree(root)
    local t = self
    traverse(root, function(node)
        if node.is then
            if node:is(Button) then t:applyButton(node)
            elseif node:is(Panel) then t:applyPanel(node)
            elseif node:is(Label) then t:applyLabel(node)
            elseif node:is(TextInput) then t:applyTextInput(node)
            elseif node:is(ListView) then t:applyListView(node)
            elseif node:is(Layout) then t:applyLayout(node)
            end
        end
    end)
end

return Style
