-- Game/Systems/ResourceSystem.lua
-- 简易资源系统：按速率产生资源

local System = require("Engine.Core.System")

---
---@class Resource
---@field amount number
---@field rate number
---@field display string

---@class ResourceSystem : System
---@field resources table<string, Resource>
local ResourceSystem = System:extend()

function ResourceSystem:init()
    self.resources = {}
end

---@param name string
---@param opts table|nil @{ amount:number|nil, rate:number|nil, display:string|nil }
function ResourceSystem:addResource(name, opts)
    opts = opts or {}
    self.resources[name] = {
        amount = opts.amount or 0,
        rate = opts.rate or 0, -- 每秒产出
        display = opts.display or name
    }
end

---@param name string
---@return Resource|nil
function ResourceSystem:get(name)
    return self.resources[name]
end

---@param dt number
function ResourceSystem:update(dt)
    for _, r in pairs(self.resources) do
        r.amount = r.amount + r.rate * dt
    end
end

function ResourceSystem:draw()
    local y = 10
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Resources", 10, y)
    y = y + 18
    for _, r in pairs(self.resources) do
        local txt = string.format("%s: %.2f (+%.2f/s)", r.display, r.amount, r.rate)
        love.graphics.print(txt, 10, y)
        y = y + 16
    end
end

return ResourceSystem
