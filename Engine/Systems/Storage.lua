-- Engine/Storage.lua
-- 模块：存档系统
-- 功能：序列化与读取 Lua 表数据到 Love2D 虚拟文件系统
-- 依赖：Engine.Object, love.filesystem
-- 作者：Team
-- 修改时间：2025-12-21
--
-- 性能提示：写入频率不宜过高；建议结合计时器做定时保存，避免每帧 IO；序列化不支持函数/用户数据。

local Object = require("Engine.Core.Object")
local Json = require("Engine.Utils.Json")
local Config = require("Engine.Core.Config")

---
---@class Storage : Object
local Storage = Object:extend()

function Storage:init()
    self.defaultFormat = (Config and Config.Storage and Config.Storage.format) or "lua"
end

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

--- 使用 JSON 保存
---@param name string @不带扩展名
---@param data table
---@param pretty boolean|nil @是否缩进
---@return boolean|nil, string|nil
function Storage:saveJson(name, data, pretty)
    local fname = name .. ".json"
    local opts = pretty and { indent = "  " } or nil
    local s, err = Json.encode(data, opts)
    if not s then return nil, err end
    return love.filesystem.write(fname, s)
end

--- 使用 JSON 读取
---@param name string @不带扩展名
---@return table|nil, string|nil
function Storage:loadJson(name)
    local fname = name .. ".json"
    local info = love.filesystem.getInfo(fname)
    if not info then return nil end
    local s, err = love.filesystem.read(fname)
---@diagnostic disable-next-line: return-type-mismatch
    if not s then return nil, err end
    local obj, derr = Json.decode(s)
    if not obj then return nil, derr end
    return obj
end


--- 自动选择保存（遵循 Config.Storage.format 或实例默认值）
---@param name string
---@param data table
---@param opts table|nil @{ format: "lua"|"json", pretty: boolean|nil }
---@return boolean|nil, string|nil
function Storage:saveData(name, data, opts)
    local fmt = (opts and opts.format) or self.defaultFormat or "lua"
    if fmt == "json" then
        return self:saveJson(name, data, opts and opts.pretty)
    else
        return self:save(name, data)
    end
end

--- 自动选择读取（遵循 Config.Storage.format 或实例默认值）
---@param name string
---@param opts table|nil @{ format: "lua"|"json" }
---@return table|nil, string|nil
function Storage:loadData(name, opts)
    local fmt = (opts and opts.format) or self.defaultFormat or "lua"
    if fmt == "json" then
        return self:loadJson(name)
    else
        return self:load(name), nil
    end
end

--- 运行时切换实例默认格式
---@param fmt "lua"|"json"
function Storage:setDefaultFormat(fmt)
    if fmt == "lua" or fmt == "json" then
        self.defaultFormat = fmt
    end
end


return Storage