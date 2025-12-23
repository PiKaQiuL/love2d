-- Engine/UI/TextInput.lua
local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")

--- 输入框配色
---@class TextInputColors
---@field bg Color
---@field border Color
---@field text Color
---@field placeholder Color

--- 创建 TextInput 时的可选参数
---@class TextInputOptions
---@field placeholder string|nil
---@field colors TextInputColors|nil



---@class TextInput : Widget
---@field w number
---@field h number
---@field text string
---@field caret integer
---@field focused boolean
---@field placeholder string
---@field colors TextInputColors
---@overload fun(...):self
local TextInput = Widget:extend()


function TextInput:init()
    Widget.init(self)
    self.w = 180
    self.h = 28
    self.text = ""
    self.caret = 0
    self.focused = false
    self.placeholder = ""
    self.colors = Defaults.inputColors
end

---
---@generic T : TextInput
---@param self T
---@param t string|nil
---@return T
function TextInput:setText(t)
    ---@cast self TextInput
    self.text = tostring(t or "")
    self.caret = #self.text
    return self
end

---
---@return string
function TextInput:getText()
    return self.text
end

--- 设置占位符文本
---@generic T : TextInput
---@param self T
---@param placeholder string
---@return T
function TextInput:setPlaceholder(placeholder)
    self.placeholder = tostring(placeholder or "")
    return self
end

--- 设置输入框颜色集
---@generic T : TextInput
---@param self T
---@param colors TextInputColors
---@return T
function TextInput:setColors(colors)
    if colors then
        self.colors = colors
    end
    return self
end

--- 设置输入框尺寸
---@generic T : TextInput
---@param self T
---@param w number|nil
---@param h number|nil
---@return T
function TextInput:setSize(w, h)
    self.w = w or self.w
    self.h = h or self.h
    return self
end

--- 设置聚焦状态
---@generic T : TextInput
---@param self T
---@param focused boolean
---@return T
function TextInput:setFocused(focused)
    self.focused = not not focused
    return self
end

---
---@param mx number
---@param my number
---@return boolean
function TextInput:hitTest(mx, my)
    local x, y, w, h = self:getWorldAABB()
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

---
---@param x number
---@param y number
---@param button integer
function TextInput:mousepressed(x, y, button)
    if button ~= 1 then return end
    local focus = self:hitTest(x, y)
    if focus ~= self.focused then
        self.focused = focus
        if love.keyboard and love.keyboard.hasTextInput and love.keyboard.setTextInput then
            if self.focused and love.keyboard.hasTextInput() == false then
                local wx, wy = self:getWorldPosition()
                love.keyboard.setTextInput(true, wx, wy, self.w, self.h)
            elseif not self.focused and love.keyboard.hasTextInput() == true then
                love.keyboard.setTextInput(false)
            end
        end
    end
end

---
---@param key string
function TextInput:keypressed(key)
    if not self.focused then return end
    if key == "backspace" then
        if self.caret > 0 then
            self.text = string.sub(self.text, 1, self.caret - 1) .. string.sub(self.text, self.caret + 1)
            self.caret = math.max(0, self.caret - 1)
        end
    elseif key == "left" then
        self.caret = math.max(0, self.caret - 1)
    elseif key == "right" then
        self.caret = math.min(#self.text, self.caret + 1)
    end
end

---
---@param t string
function TextInput:textinput(t)
    if not self.focused then return end
    local left = string.sub(self.text, 1, self.caret)
    local right = string.sub(self.text, self.caret + 1)
    self.text = left .. t .. right
    self.caret = self.caret + #t
end

-- 可选：触摸直接聚焦（移动端）
---@param id number
---@param x number
---@param y number
function TextInput:touchpressed(id, x, y)
    local focus = self:hitTest(x, y)
    if focus ~= self.focused then
        self.focused = focus
        if love.keyboard and love.keyboard.hasTextInput and love.keyboard.setTextInput then
            if self.focused and love.keyboard.hasTextInput() == false then
                local wx, wy = self:getWorldPosition()
                love.keyboard.setTextInput(true, wx, wy, self.w, self.h)
            elseif not self.focused and love.keyboard.hasTextInput() == true then
                love.keyboard.setTextInput(false)
            end
        end
    end
end

---comment
---@param x number
---@param y number
function TextInput:render(x, y)
    love.graphics.setColor(self.colors.bg)
    love.graphics.rectangle("fill", x, y, self.w, self.h)
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle("line", x, y, self.w, self.h)

    local showPlaceholder = (self.text == "" and not self.focused and self.placeholder ~= "")
    love.graphics.setColor(showPlaceholder and self.colors.placeholder or self.colors.text)
    local pad = 6
    love.graphics.print(showPlaceholder and self.placeholder or self.text, x + pad, y + (self.h - 14) / 2)

    if self.focused then
        local t = love.timer.getTime()
        if math.floor(t * 1.2) % 2 == 0 then
            local caretX = x + pad + love.graphics.getFont():getWidth(string.sub(self.text, 1, self.caret))
            love.graphics.setColor(self.colors.text)
            love.graphics.line(caretX, y + 5, caretX, y + self.h - 5)
        end
    end
    love.graphics.setColor(1,1,1,1)
end

return TextInput
