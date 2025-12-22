-- Engine/Systems/Animation.lua
-- 动画系统：简易补间（tween）轨道管理，支持暂停/恢复/停止
-- 依赖：Engine.Core.System

local System = require("Engine.Core.System")

---@alias EasingFn fun(t:number):number
---@alias AnimTarget Widget|Scene|table

--- 缓动函数集合
---@type table<string, EasingFn>
local Easing = {
    linear = function(t) return t end,
    quadIn = function(t) return t * t end,
    quadOut = function(t) t = 1 - t; return 1 - t * t end,
    quadInOut = function(t)
        if t < 0.5 then return 2 * t * t else return 1 - 2 * (1 - t) * (1 - t) end
    end,
    cubicInOut = function(t)
        if t < 0.5 then return 4 * t * t * t else return 1 - 4 * (1 - t) * (1 - t) * (1 - t) end
    end
}

---@class TweenTrack
---@field target AnimTarget
---@field key string|nil
---@field setter fun(obj:AnimTarget, value:number)|nil
---@field from number
---@field to number
---@field duration number
---@field time number
---@field easing EasingFn
---@field paused boolean
---@field onUpdate fun(value:number)|nil
---@field onComplete fun()|nil
---@field repeatTimes number  重复次数；-1 表示无限
---@field yoyo boolean       往返（到达终点后交换 from/to）
local TweenTrack = {}
TweenTrack.__index = TweenTrack

function TweenTrack:pause() self.paused = true; return self end
function TweenTrack:resume() self.paused = false; return self end
function TweenTrack:stop() self._stopped = true; return self end


---@class Animation : System
---@field tracks TweenTrack[]
---@field easing table<string, EasingFn>
---@field animation Animation @self 引用自身，方便传递给组件
local Animation = System:extend()

--- 初始化动画系统
---@param ... any
function Animation:init(...)
    self.tracks = {}
    self.easing = Easing
end

--- 创建并添加一个补间轨道
---@param target AnimTarget 目标对象
---@param keyOrSetter string|fun(obj:AnimTarget, value:number) 属性名或设置函数
---@param to number 目标值
---@param duration number 持续时长（秒）
---@param easing string|EasingFn|nil 缓动函数或名称
---@param opts table|nil @{ from:number|nil, onUpdate:fun(value:number)|nil, onComplete:fun()|nil, repeat:integer|nil, yoyo:boolean|nil }
---@return TweenTrack
function Animation:animate(target, keyOrSetter, to, duration, easing, opts)
    opts = opts or {}
    local setter, key
    if type(keyOrSetter) == "function" then setter = keyOrSetter else key = keyOrSetter end
    local from
    if opts.from ~= nil then from = opts.from
    elseif key and target ~= nil and type(target[key]) == "number" then from = target[key]
    else from = 0 end
    local easeFn = (type(easing) == "function") and easing or (self.easing[tostring(easing or "linear")] or self.easing.linear)
    local track = setmetatable({
        target = target,
        key = key,
        setter = setter,
        from = from,
        to = to,
        duration = math.max(0.0001, duration or 0.0001),
        time = 0,
        easing = easeFn,
        paused = false,
        onUpdate = opts.onUpdate,
        onComplete = opts.onComplete,
        repeatTimes = (opts["repeat"] == -1) and math.huge or (tonumber(opts["repeat"]) or 0),
        yoyo = opts.yoyo == true
    }, TweenTrack)
    self.tracks[#self.tracks + 1] = track
    return track
end

--- 同步多个属性到指定终值（自动使用当前值为起点）
---@param target AnimTarget
---@param props table<string, number>
---@param duration number
---@param easing string|EasingFn|nil
---@return Animation
function Animation:to(target, props, duration, easing)
    for k, v in pairs(props or {}) do
        self:animate(target, k, v, duration, easing)
    end
    return self
end

--- 更新所有动画轨道
---@param dt number 帧间隔（秒）
function Animation:update(dt)
    if dt <= 0 then return end
    if #self.tracks == 0 then return end
    local i = 1
    while i <= #self.tracks do
        local tr = self.tracks[i]
        if tr._stopped then
            table.remove(self.tracks, i)
        elseif tr.paused then
            i = i + 1
        else
            tr.time = tr.time + dt
            local t = tr.time / tr.duration
            if t >= 1 then t = 1 end
            local k = tr.easing(t)
            local value = tr.from + (tr.to - tr.from) * k
            if tr.setter then tr.setter(tr.target, value)
            elseif tr.key then tr.target[tr.key] = value end
            if tr.onUpdate then tr.onUpdate(value) end
            if t >= 1 then
                -- 处理重复/往返
                if tr.repeatTimes and tr.repeatTimes > 0 or tr.repeatTimes == math.huge then
                    -- 下一轮
                    tr.time = 0
                    if tr.yoyo then
                        tr.from, tr.to = tr.to, tr.from
                    else
                        -- 非 yoyo：保持 from 为当前终点，下一轮仍向同一终点（可根据需要重置）
                        tr.from = tr.to
                    end
                    if tr.repeatTimes ~= math.huge then tr.repeatTimes = tr.repeatTimes - 1 end
                    i = i + 1
                else
                    if tr.onComplete then tr.onComplete() end
                    if self.app and self.app.emit then
                        self.app:emit("animation:done", tr.target, tr.key, tr.to)
                    end
                    table.remove(self.tracks, i)
                end
            else
                i = i + 1
            end
        end
    end
end

--- 清空所有轨道
---@return Animation
function Animation:clear()
    self.tracks = {}
    return self
end

--- 停止指定目标（可选按 key 过滤）的所有轨道
---@param target AnimTarget
---@param key string|nil
---@return Animation
function Animation:stop(target, key)
    if not target then return self end
    for i = #self.tracks, 1, -1 do
        local tr = self.tracks[i]
        if tr.target == target and (key == nil or tr.key == key) then
            table.remove(self.tracks, i)
        end
    end
    return self
end

--- 暂停指定目标（可选按 key 过滤）的所有轨道
---@param target AnimTarget
---@param key string|nil
---@return Animation
function Animation:pause(target, key)
    if not target then return self end
    for i = 1, #self.tracks do
        local tr = self.tracks[i]
        if tr.target == target and (key == nil or tr.key == key) then
            tr.paused = true
        end
    end
    return self
end

--- 恢复指定目标（可选按 key 过滤）的所有轨道
---@param target AnimTarget
---@param key string|nil
---@return Animation
function Animation:resume(target, key)
    if not target then return self end
    for i = 1, #self.tracks do
        local tr = self.tracks[i]
        if tr.target == target and (key == nil or tr.key == key) then
            tr.paused = false
        end
    end
    return self
end

return Animation
