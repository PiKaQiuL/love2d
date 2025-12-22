-- Engine/UI/ListView.lua
local Widget = require("Engine.UI.Widget")
local Defaults = require("Engine.UI.Defaults")

---
---@class ListView : Widget
---@field w number
---@field itemHeight number
---@field items string[]
---@field selected integer|nil
---@field onSelect fun(self:ListView, index:integer, value:string)|nil
---@field maxVisible integer
---@field padding number
---@field colors { bg: number[], border: number[], text: number[], hover: number[], selected: number[] }
---@field hoverIndex integer|nil
---@field scrollY number
---@field _drag { active: boolean, grabOffset: number, trackY: number, trackH: number, thumbH: number }
local ListView = Widget:extend()

---
---@param x number
---@param y number
---@param w number
---@param itemHeight number
---@param opts table|nil
function ListView:init(x, y, w, itemHeight, opts)
    opts = opts or {}
    local lw = w or 240
    Widget.init(self, x or 0, y or 0, lw, 0, opts)
    self.w = lw
    self.itemHeight = itemHeight or 18
    self.items = {}
    self.selected = nil
    self.onSelect = opts.onSelect
    self.maxVisible = opts.maxVisible or 10
    self.padding = opts.padding or 4
    self.colors = opts.colors or Defaults.listColors
    self.hoverIndex = nil
    self.scrollY = 0
    self._drag = { active = false, grabOffset = 0, trackY = 0, trackH = 0, thumbH = 0 }
end

--- 在渲染前设置剪裁区域，避免内容溢出
---@param x number
---@param y number
function ListView:preRender(x, y)
    local h = self:getHeight()
    love.graphics.setScissor(x, y, self.w, h)
end

--- 渲染后清除剪裁
function ListView:postRender()
    love.graphics.setScissor()
end

---@return number
function ListView:getHeight()
    local count = math.min(#self.items, self.maxVisible)
    return self.padding * 2 + count * self.itemHeight
end

---@return number
function ListView:getViewportHeight()
    return self.padding * 2 + self.maxVisible * self.itemHeight
end

---@return number
function ListView:getContentHeight()
    return self.padding * 2 + #self.items * self.itemHeight
end

---@return number
function ListView:getScrollMax()
    local vh = self:getViewportHeight()
    local ch = self:getContentHeight()
    return math.max(0, ch - vh)
end

---@param v number
---@param minv number
---@param maxv number
---@return number
local function clamp(v, minv, maxv)
    if v < minv then return minv end
    if v > maxv then return maxv end
    return v
end

---@param y number|nil
function ListView:setScroll(y)
    local maxScroll = self:getScrollMax()
    self.scrollY = clamp(y or 0, 0, maxScroll)
    return self
end

---@param dy number|nil
function ListView:scrollBy(dy)
    self:setScroll((self.scrollY or 0) + (dy or 0))
    return self
end

---
---@param item string|number
function ListView:add(item)
    self.items[#self.items + 1] = tostring(item)
    return self
end

function ListView:clear()
    self.items = {}
    self.selected = nil
    self.hoverIndex = nil
    return self
end

---
---@param mx number
---@param my number
---@return boolean
function ListView:hitTest(mx, my)
    local x, y, w, h = self:getWorldAABB()
    h = self:getHeight() -- 高度按内容高度
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

---
---@param mx number
---@param my number
---@return number|nil
function ListView:indexAt(mx, my)
    local x, y = self:getWorldAABB()
    local startIndex = math.floor((self.scrollY or 0) / self.itemHeight) + 1
    local offsetY = -((self.scrollY or 0) % self.itemHeight)
    local cy = my - y - self.padding - offsetY
    if cy < 0 then return nil end
    local visible = math.min(#self.items - (startIndex - 1), self.maxVisible)
    local i0 = math.floor(cy / self.itemHeight)
    if i0 < 0 or i0 > visible - 1 then return nil end
    return startIndex + i0
end

---@param x number
---@param y number
function ListView:render(x, y)
    local h = self:getHeight()
    love.graphics.setColor(self.colors.bg)
    love.graphics.rectangle("fill", x, y, self.w, h)
    love.graphics.setColor(self.colors.border)
    love.graphics.rectangle("line", x, y, self.w, h)

    local startIndex = math.floor((self.scrollY or 0) / self.itemHeight) + 1
    local offsetY = -((self.scrollY or 0) % self.itemHeight)
    local visible = math.min(#self.items - (startIndex - 1), self.maxVisible)
    for i = 0, visible - 1 do
        local idx = startIndex + i
        local iy = y + self.padding + offsetY + i * self.itemHeight
        if self.selected == idx then
            love.graphics.setColor(self.colors.selected)
            love.graphics.rectangle("fill", x + 1, iy, self.w - 2, self.itemHeight)
        elseif self.hoverIndex == idx then
            love.graphics.setColor(self.colors.hover)
            love.graphics.rectangle("fill", x + 1, iy, self.w - 2, self.itemHeight)
        end
        love.graphics.setColor(self.colors.text)
        love.graphics.print(self.items[idx], x + 6, iy + 2)
    end
    love.graphics.setColor(1,1,1,1)

    -- 绘制滚动条指示器（仅当内容高度大于视窗高度）
    local viewportH = self:getViewportHeight()
    local contentH = self:getContentHeight()
    if contentH > viewportH then
        local trackX = x + self.w - 4
        local trackY = y + 1
        local trackW = 3
        local trackH = viewportH - 2
        local ratio = viewportH / contentH
        local thumbH = math.max(8, trackH * ratio)
        local maxScroll = self:getScrollMax()
        local scrollRatio = maxScroll > 0 and ((self.scrollY or 0) / maxScroll) or 0
        local thumbY = trackY + scrollRatio * (trackH - thumbH)
        love.graphics.setColor(self.colors.border)
        love.graphics.rectangle("fill", trackX, trackY, trackW, trackH)
        love.graphics.setColor(self.colors.hover)
        love.graphics.rectangle("fill", trackX, thumbY, trackW, thumbH)
        love.graphics.setColor(1,1,1,1)

        -- 记录供拖拽使用的度量（仅在渲染时更新一次）
        self._drag.trackY = trackY
        self._drag.trackH = trackH
        self._drag.thumbH = thumbH
    end
end

-- 判断是否点击在滚动条轨道或拇指内
---@param px number
---@param py number
---@param rx number
---@param ry number
---@param rw number
---@param rh number
---@return boolean
local function pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

---comment
---@param mx number
---@param my number
---@param button number
function ListView:mousepressed(mx, my, button)
    if button ~= 1 then return end
    if not self:hitTest(mx, my) then return end
    -- 处理滚动条点击或拖拽
    local x, y = self:getWorldAABB()
    local viewportH = self:getViewportHeight()
    local contentH = self:getContentHeight()
    if contentH > viewportH then
        local trackX = x + self.w - 4
        local trackY = y + 1
        local trackW = 3
        local trackH = viewportH - 2
        local ratio = viewportH / contentH
        local thumbH = math.max(8, trackH * ratio)
        -- 计算当前 thumbY
        local maxScroll = self:getScrollMax()
        local scrollRatio = maxScroll > 0 and ((self.scrollY or 0) / maxScroll) or 0
        local thumbY = trackY + scrollRatio * (trackH - thumbH)

        if pointInRect(mx, my, trackX, thumbY, trackW, thumbH) then
            -- 点在拇指上：开始拖拽
            self._drag.active = true
            self._drag.grabOffset = my - thumbY
            self._drag.trackY = trackY
            self._drag.trackH = trackH
            self._drag.thumbH = thumbH
        elseif pointInRect(mx, my, trackX, trackY, trackW, trackH) then
            -- 点击轨道：跳转位置（居中到点击处）
            local target = (my - trackY - thumbH * 0.5) / (trackH - thumbH)
            target = clamp(target, 0, 1)
            self:setScroll(target * maxScroll)
        end
    end
    -- 列表项点击保留原逻辑
    local i = self:indexAt(mx, my)
    if i then self.selected = i end
end

---@param mx number
---@param my number
function ListView:mousemoved(mx, my)
    -- 拖动滚动拇指
    if self._drag.active then
        local x, y = self:getWorldAABB()
        local viewportH = self:getViewportHeight()
        local contentH = self:getContentHeight()
        local trackY = y + 1
        local trackH = viewportH - 2
        local ratio = viewportH / contentH
        local thumbH = math.max(8, trackH * ratio)
        local maxScroll = self:getScrollMax()
        local pos = (my - trackY - self._drag.grabOffset) / (trackH - thumbH)
        pos = clamp(pos, 0, 1)
        self:setScroll(pos * maxScroll)
        -- 拖动时不更新 hoverIndex，避免误差
        return
    end
    -- 非拖动时维持原有 hover 行为
    if not self:hitTest(mx, my) then self.hoverIndex = nil; return end
    self.hoverIndex = self:indexAt(mx, my)
end

---@param x number
---@param y number
---@param button integer
function ListView:mousereleased(x, y, button)
    if button ~= 1 then return end
    -- 停止拖拽
    if self._drag.active then
        self._drag.active = false
        return
    end
    if not self:hitTest(x, y) then return end
    local i = self:indexAt(x, y)
    if i and i == self.selected and self.onSelect then
        self.onSelect(self, i, self.items[i])
    end
end

---@param dx number
---@param dy number
function ListView:wheelmoved(dx, dy)
    local step = self.itemHeight
    -- dy > 0 向上滚动（减少 scrollY）
    self:scrollBy(-(dy or 0) * step)
end

return ListView
