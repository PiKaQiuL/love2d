-- Engine/Storage.lua
-- 模块：存档系统
-- 功能：序列化与读取 Lua 表数据到 Love2D 虚拟文件系统
-- 依赖：Engine.Object, love.filesystem
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：写入频率不宜过高；建议结合计时器做定时保存，避免每帧 IO；序列化不支持函数/用户数据。

local Object = require("Engine.Core.Object")

---
---@class Storage : Object
local Storage = Object:extend()

local function serialize(value, indent)
    indent = indent or 0
    local pad = string.rep(" ", indent)
    local t = type(value)
    if t == "number" or t == "boolean" then
        return tostring(value)
    elseif t == "string" then
        return string.format("%q", value)
    elseif t == "table" then
        local parts = {"{"}
        for k, v in pairs(value) do
            local keyStr
            if type(k) == "string" then
                keyStr = string.format("[%q]", k)
            else
                keyStr = "[" .. tostring(k) .. "]"
            end
            parts[#parts + 1] = "\n" .. pad .. "  " .. keyStr .. " = " .. serialize(v, indent + 2) .. ","
        end
        parts[#parts + 1] = "\n" .. pad .. "}"
        return table.concat(parts)
    else
        return "nil"
    end
end

---
---@param name string
---@param data table
---@return boolean|nil, string|nil
function Storage:save(name, data)
    local fname = name .. ".lua"
    local content = "return " .. serialize(data)
    return love.filesystem.write(fname, content)
end

---
---@param name string
---@return table|nil
function Storage:load(name)
    local fname = name .. ".lua"
    if not love.filesystem.getInfo(fname) then return nil end
    local chunk = love.filesystem.load(fname)
    if not chunk then return nil end
    local ok, result = pcall(chunk)
    if ok then
        return result
    else
        print("Storage load error:", result)
        return nil
    end
end

return Storage
