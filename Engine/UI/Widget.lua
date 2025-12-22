-- Engine/UI/Widget.lua
-- 通用控件基类：统一绘制/命中测试/可见性/启用/缩放等

local Node = require("Engine.Core.Node")

---@class Widget : Node
---@field w number
---@field h number
---@field enabled boolean
---@field opacity number
---@field render fun(self:Widget, x:number, y:number)|nil
---@field preRender fun(self:Widget, x:number, y:number)|nil
---@field postRender fun(self:Widget, x:number, y:number)|nil
local Widget = Node:extend()

---
---@param x number|nil
---@param y number|nil
---@param w number|nil
---@param h number|nil
---@param opts table|nil @{ enabled:boolean|nil, opacity:number|nil }
function Widget:init(x, y, w, h, opts)
    opts = opts or {}
    Node.init(self, x or 0, y or 0)
    self.w = w or 0
    self.h = h or 0
    self.enabled = opts.enabled ~= false
    self.opacity = opts.opacity or 1
end

--- 设置组件尺寸
---@param w number|nil
---@param h number|nil
---@return Widget
function Widget:setSize(w, h)
    self.w, self.h = w or self.w, h or self.h
    return self
end

--- 设置组件缩放
---@param sx number|nil
---@param sy number|nil
---@return Widget
function Widget:setScale(sx, sy)
    self.sx = sx or self.sx or 1
    self.sy = sy or self.sy or 1
    return self
end

--- 设置组件可见性
---@param v boolean
---@return Widget
function Widget:setVisible(v)
    self.visible = not not v
    return self
end

--- 设置组件启用状态
---@param e boolean
---@return Widget
function Widget:setEnabled(e)
    self.enabled = not not e
    return self
end

-- 动画便捷接口：在 UI 组件上直接触发补间
-- animOrApp 可传 Animation 系统实例或 App（会使用 app.animation）
--- 触发动画（补间）到指定值
---@param animOrApp Animation|App @Animation 系统实例或 App（含 `animation` 字段）
---@param keyOrSetter string|fun(obj:Widget, value:number) @属性名或设置函数
---@param to number @目标值
---@param duration number @时长（秒）
---@param easing string|fun(t:number):number|nil @缓动函数或名称
---@param opts table|nil @{ from:number|nil, onUpdate:fun(value:number)|nil, onComplete:fun()|nil, repeat:integer|nil, yoyo:boolean|nil }
---@return TweenTrack|nil @返回补间轨道；失败时为 nil
function Widget:animate(animOrApp, keyOrSetter, to, duration, easing, opts)
    local anim = animOrApp
    if anim and anim.animation then anim = anim.animation end
    if not anim or type(anim.animate) ~= "function" then return nil end
    return anim:animate(self, keyOrSetter, to, duration, easing, opts)
end

--- 批量动画到多个目标属性
---@param animOrApp Animation|App @Animation 系统实例或 App
---@param props table<string, number> @属性名到目标值映射
---@param duration number
---@param easing string|fun(t:number):number|nil
---@return Widget
function Widget:animateTo(animOrApp, props, duration, easing)
    local anim = animOrApp
    if anim and anim.animation then anim = anim.animation end
    if not anim or type(anim.to) ~= "function" then return self end
    anim:to(self, props, duration, easing)
    return self
end

--- 停止当前组件的动画
---@param animOrApp Animation|App @Animation 系统实例或 App
---@param key string|nil @可选：仅停止指定属性的轨道
---@return Widget
function Widget:stopAnimations(animOrApp, key)
    local anim = animOrApp
    if anim and anim.animation then anim = anim.animation end
    if not anim or type(anim.stop) ~= "function" then return self end
    anim:stop(self, key)
    return self
end

--- 暂停当前组件的动画
---@param animOrApp Animation|App @Animation 系统实例或 App
---@param key string|nil @可选：仅暂停指定属性的轨道
---@return Widget
function Widget:pauseAnimations(animOrApp, key)
    local anim = animOrApp
    if anim and anim.animation then anim = anim.animation end
    if not anim or type(anim.pause) ~= "function" then return self end
    anim:pause(self, key)
    return self
end

--- 恢复当前组件的动画
---@param animOrApp Animation|App @Animation 系统实例或 App
---@param key string|nil @可选：仅恢复指定属性的轨道
---@return Widget
function Widget:resumeAnimations(animOrApp, key)
    local anim = animOrApp
    if anim and anim.animation then anim = anim.animation end
    if not anim or type(anim.resume) ~= "function" then return self end
    anim:resume(self, key)
    return self
end

--- 简易命中测试：基于位置与尺寸
---@param mx number
---@param my number
---@return boolean
function Widget:hitTest(mx, my)
    if not self.visible then return false end
    local x, y = self:getWorldPosition()
    local w = (self.w or 0) * (self.sx or 1)
    local h = (self.h or 0) * (self.sy or 1)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

--- 统一绘制流程：先渲染自身，再绘制子节点
function Widget:draw()
    if not self.visible then return end
    local x, y = self:getWorldPosition()
    if type(self.preRender) == "function" then self:preRender(x, y) end
    if type(self.render) == "function" then self:render(x, y) end
    for i = 1, #self.children do
        local c = self.children[i]
        if c.draw then c:draw() end
    end
    if type(self.postRender) == "function" then self:postRender(x, y) end
end

return Widget