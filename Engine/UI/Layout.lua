-- Engine/UI/Layout.lua
-- 简易布局容器：垂直/水平堆叠，支持间距、内边距与对齐
-- 模块：布局容器
-- 功能：组织子控件的排列与对齐，减少绝对坐标硬编码
-- 依赖：Engine.Node, Engine.Enums
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：relayout() 会遍历并定位所有子节点，尽量在批量添加后统一调用，避免每次 add 都强制重排；大量子项时考虑分区或分页。

local Node = require("Engine.Core.Node")
local Enums = require("Engine.Core.Enums")

---
---@class Layout : Node
---@field direction string
---@field spacing number
---@field gapX number
---@field gapY number
---@field padding number|table
---@field padL number
---@field padT number
---@field padR number
---@field padB number
---@field align string
---@field justify string
---@field wrap boolean
---@field clip boolean
---@field autoSize boolean
---@field w number
---@field h number
---@field bg number[]|nil
---@field border number[]|nil
---@field borderWidth number
---@field _layout table<any, { margin: { l: number, t: number, r: number, b: number } }>
local Layout = Node:extend()

-- opts: { direction = "vertical"|"horizontal", spacing = number, padding = number|{l,t,r,b}, align = "start"|"center"|"end", bg = {r,g,b,a}, border = {r,g,b,a}, borderWidth = number }
---
---@param x number
---@param y number
---@param w number
---@param h number
---@param opts table|nil
function Layout:init(x, y, w, h, opts)
    opts = opts or {}
    Node.init(self, x or 0, y or 0)
    self.direction = opts.direction or Enums.LayoutDirection.vertical
    self.spacing = opts.spacing or 6
    self.gapX = opts.gapX or self.spacing
    self.gapY = opts.gapY or self.spacing
    self.padding = opts.padding or 6
    if type(self.padding) ~= "table" then
        self.padL, self.padT, self.padR, self.padB = self.padding, self.padding, self.padding, self.padding
    else
        self.padL = self.padding.l or 0
        self.padT = self.padding.t or 0
        self.padR = self.padding.r or 0
        self.padB = self.padding.b or 0
    end
    self.align = opts.align or Enums.Align.start -- cross-axis alignment
    self.justify = opts.justify or Enums.Align.start -- main-axis distribution: start|center|end|space-between
    self.w = w or 300
    self.h = h or 200
    self.bg = opts.bg
    self.border = opts.border
    self.borderWidth = opts.borderWidth or 1
    self.wrap = opts.wrap or false
    self.clip = opts.clip or false
    self.autoSize = opts.autoSize or false

    -- 存储子项的布局选项（如 margin）
    self._layout = {}
end

--- 设置方向
---@param dir string 方向（vertical|horizontal）
function Layout:setDirection(dir)
    self.direction = dir or self.direction
    self:relayout()
    return self
end

--- 设置子项间距
---@param s number 间距
function Layout:setSpacing(s)
    self.spacing = s or self.spacing
    self.gapX = self.gapX or self.spacing
    self.gapY = self.gapY or self.spacing
    self:relayout()
    return self
end

--- 设置内边距
---@param p number|table 统一值或 {l,t,r,b}
function Layout:setPadding(p)
    self.padding = p or self.padding
    if type(self.padding) ~= "table" then
        self.padL, self.padT, self.padR, self.padB = self.padding, self.padding, self.padding, self.padding
    else
        self.padL = self.padding.l or 0
        self.padT = self.padding.t or 0
        self.padR = self.padding.r or 0
        self.padB = self.padding.b or 0
    end
    self:relayout()
    return self
end

--- 设置对齐方式
---@param a string 对齐（start|center|end）
function Layout:setAlign(a)
    self.align = a or self.align
    self:relayout()
    return self
end

--- 设置主轴分布
---@param j string
function Layout:setJustify(j)
    self.justify = j or self.justify
    self:relayout()
    return self
end

--- 设置是否换行
---@param wrap boolean
function Layout:setWrap(wrap)
    self.wrap = not not wrap
    self:relayout()
    return self
end

--- 设置剪裁
---@param clip boolean
function Layout:setClip(clip)
    self.clip = not not clip
    return self
end

--- 设置双轴间距
---@param gx number|nil
---@param gy number|nil
function Layout:setGaps(gx, gy)
    self.gapX = gx or self.gapX
    self.gapY = gy or self.gapY
    self:relayout()
    return self
end

--- 设置自动尺寸
---@param v boolean
function Layout:setAutoSize(v)
    self.autoSize = not not v
    self:relayout()
    return self
end

--- 设置容器尺寸
---@param w number 宽度
---@param h number 高度
function Layout:setSize(w, h)
    self.w, self.h = w or self.w, h or self.h
    self:relayout()
    return self
end

-- 为子节点添加并记录布局项（支持 margin）
--- 添加子节点并可设置外边距
---@param child Node 子节点
---@param opts table 选项：margin
function Layout:add(child, opts)
    Node.add(self, child)
    local m = opts and opts.margin
    if type(m) ~= "table" then
        local mv = tonumber(m) or 0
        m = { l = mv, t = mv, r = mv, b = mv }
    else
        m.l = m.l or 0; m.t = m.t or 0; m.r = m.r or 0; m.b = m.b or 0
    end
    self._layout[child] = { margin = m }
    self:relayout()
    return self
end

function Layout:remove(child)
    self._layout[child] = nil
    Node.remove(self, child)
    return self
end

-- 尝试测量子项尺寸
--- 尺寸测量（尽力基于控件自身属性）
---@param child any
---@return number, number
local function measure(child)
    -- 优先使用显式尺寸字段
    local w = child.w or 0
    local h = child.h or 0

    -- 特例：Label 使用字体测量
    if child.text and (w == 0 or h == 0) then
        local font = child.font or love.graphics.getFont()
        local fw = font:getWidth(child.text)
        local fh = font:getHeight()
        w = (w == 0) and (fw + 4) or w
        h = (h == 0) and fh or h
    end
    -- 特例：ListView 有 getHeight()
    if child.getHeight and h == 0 then
        h = child:getHeight()
    end
    return w, h
end

---@return nil
function Layout:relayout()
    local innerW = self.w - self.padL - self.padR
    local innerH = self.h - self.padT - self.padB
    local x0, y0 = self.padL, self.padT

    if self.direction == Enums.LayoutDirection.vertical then
        -- 计算总高度用于 justify
        local totalH = 0
        for i = 1, #self.children do
            local cw, ch = measure(self.children[i])
            local m = (self._layout[self.children[i]] and self._layout[self.children[i]].margin) or {l=0,t=0,r=0,b=0}
            totalH = totalH + ch + m.t + m.b
            if i < #self.children then totalH = totalH + self.gapY end
        end
        local extra = math.max(0, innerH - totalH)
        local gapY = self.gapY
        local startY = y0
        if self.justify == Enums.Align.center then
            startY = y0 + extra * 0.5
        elseif self.justify == Enums.Align["end"] then
            startY = y0 + extra
        elseif self.justify == Enums.Align["space-between"] and #self.children > 1 then
            gapY = self.gapY + (extra / (#self.children - 1))
        end

        local cursorY = startY
        for i = 1, #self.children do
            local c = self.children[i]
            local cw, ch = measure(c)
            local opt = self._layout[c] or { margin = {l=0,t=0,r=0,b=0} }
            local m = opt.margin
            local cx
            if self.align == Enums.Align.center then
                cx = x0 + (innerW - cw) * 0.5
            elseif self.align == Enums.Align["end"] then
                cx = x0 + (innerW - cw)
            else
                cx = x0
            end
            c:setPosition(cx + m.l, cursorY + m.t)
            cursorY = cursorY + ch + m.t + m.b + gapY
        end
    else -- horizontal
        local totalW = 0
        for i = 1, #self.children do
            local cw, ch = measure(self.children[i])
            local m = (self._layout[self.children[i]] and self._layout[self.children[i]].margin) or {l=0,t=0,r=0,b=0}
            totalW = totalW + cw + m.l + m.r
            if i < #self.children then totalW = totalW + self.gapX end
        end
        local extra = math.max(0, innerW - totalW)
        local gapX = self.gapX
        local startX = x0
        if self.justify == Enums.Align.center then
            startX = x0 + extra * 0.5
        elseif self.justify == Enums.Align["end"] then
            startX = x0 + extra
        elseif self.justify == Enums.Align["space-between"] and #self.children > 1 then
            gapX = self.gapX + (extra / (#self.children - 1))
        end

        local cursorX = startX
        local cursorY = y0
        if not self.wrap then
            for i = 1, #self.children do
                local c = self.children[i]
                local cw, ch = measure(c)
                local opt = self._layout[c] or { margin = {l=0,t=0,r=0,b=0} }
                local m = opt.margin
                local cy
                if self.align == Enums.Align.center then
                    cy = y0 + (innerH - ch) * 0.5
                elseif self.align == Enums.Align["end"] then
                    cy = y0 + (innerH - ch)
                else
                    cy = y0
                end
                c:setPosition(cursorX + m.l, cy + m.t)
                cursorX = cursorX + cw + m.l + m.r + gapX
            end
        else
            -- 简易换行：行满则换到下一行
            local lineH = 0
            for i = 1, #self.children do
                local c = self.children[i]
                local cw, ch = measure(c)
                local opt = self._layout[c] or { margin = {l=0,t=0,r=0,b=0} }
                local m = opt.margin
                if (cursorX + cw + m.l + m.r - x0) > innerW and i > 1 then
                    cursorX = startX
                    cursorY = cursorY + lineH + self.gapY
                    lineH = 0
                end
                local cy
                if self.align == Enums.Align.center then
                    cy = cursorY + (innerH - ch) * 0.5 -- 简化：整容器居中；可按行计算进一步优化
                elseif self.align == Enums.Align["end"] then
                    cy = cursorY + (innerH - ch)
                else
                    cy = cursorY
                end
                c:setPosition(cursorX + m.l, cy + m.t)
                cursorX = cursorX + cw + m.l + m.r + gapX
                if ch + m.t + m.b > lineH then lineH = ch + m.t + m.b end
            end
        end
    end

    if self.autoSize then
        -- 根据子项估算自身尺寸（简单加总）
        local maxX, maxY = 0, 0
        for i = 1, #self.children do
            local c = self.children[i]
            local cw, ch = measure(c)
            local opt = self._layout[c] or { margin = {l=0,t=0,r=0,b=0} }
            local m = opt.margin
            if self.direction == Enums.LayoutDirection.horizontal then
                maxX = maxX + cw + m.l + m.r + (i < #self.children and self.gapX or 0)
                maxY = math.max(maxY, ch + m.t + m.b)
            else
                maxY = maxY + ch + m.t + m.b + (i < #self.children and self.gapY or 0)
                maxX = math.max(maxX, cw + m.l + m.r)
            end
        end
        self.w = maxX + self.padL + self.padR
        self.h = maxY + self.padT + self.padB
    end
end

---@param x number
---@param y number
function Layout:preRender(x, y)
    if self.clip then love.graphics.setScissor(x, y, self.w, self.h) end
end

---@return nil
function Layout:postRender()
    if self.clip then love.graphics.setScissor() end
end

---@return nil
function Layout:draw()
    if not self.visible then return end
    local x, y = self:getWorldAABB()
    if type(self.preRender) == "function" then self:preRender(x, y) end
    if self.bg then
        love.graphics.setColor(self.bg)
        love.graphics.rectangle("fill", x, y, self.w, self.h)
    end
    if self.border then
        love.graphics.setColor(self.border)
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", x, y, self.w, self.h)
        love.graphics.setColor(1,1,1,1)
    end
    for i = 1, #self.children do
        local c = self.children[i]
        if c.draw then c:draw() end
    end
    if type(self.postRender) == "function" then self:postRender() end
end

return Layout
