-- Engine/Utils/Json.lua
-- 统一 JSON 编解码适配：优先使用插件 dkjson

---
---@class Json
---@field encode fun(value:any, opts?:table):string|nil, string|nil
---@field decode fun(str:string, pos?:integer|nil, null?:any):any, string|nil
local Json = {}

local ok, dkjson = pcall(require, "Engine.plugin.dkjson.dkjson")
if not ok then
    ok, dkjson = pcall(require, "dkjson")
end

if ok and dkjson then
    ---@param value any
    ---@param opts table|nil @{ indent:string|nil, keyorder:string[]|nil }
    function Json.encode(value, opts)
        local s, err = dkjson.encode(value,
            { indent = opts and opts.indent or nil, keyorder = opts and opts.keyorder or nil })
        if not s then return nil, err end
        return s
    end

    ---@param str string
    ---@param pos integer|nil
    ---@param null any|nil
    function Json.decode(str, pos, null)
        local obj, _, err = dkjson.decode(str, pos, null)
        if err then return nil, err end
        return obj
    end
else
    -- 极简降级：不是严格 JSON，仅作兜底，建议安装 dkjson
    function Json.encode()
        return nil, "dkjson not found; please include Engine/plugin/dkjson/dkjson.lua"
    end

    function Json.decode()
        return nil, "dkjson not found; please include Engine/plugin/dkjson/dkjson.lua"
    end
end

return Json
