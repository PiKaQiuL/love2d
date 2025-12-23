-- 测试 Object 的 getter/setter 功能
local Object = require("Engine.Core.Object")
local Vector2 = require("Engine.Utils.Vector2")

print("=== Object Getter/Setter 测试 ===\n")

-- 测试 1: 直接赋值方式定义 getter/setter (类似 Node 的用法)
print("测试 1: 直接赋值方式定义 getter/setter")
local Person = Object:extend()

Person.__getter.fullName = function(self)
    return (self._firstName or "") .. " " .. (self._lastName or "")
end

Person.__setter.fullName = function(self, value)
    local parts = {}
    for part in string.gmatch(value, "%S+") do
        table.insert(parts, part)
    end
    self._firstName = parts[1] or ""
    self._lastName = parts[2] or ""
    return nil -- 不缓存
end

local p1 = Person()
p1.fullName = "John Doe"
print("设置 fullName = 'John Doe'")
print("  _firstName:", p1._firstName)
print("  _lastName:", p1._lastName)
print("  fullName:", p1.fullName)
print()

-- 测试 2: 带缓存的 getter
print("测试 2: 带缓存的 getter")
local Counter = Object:extend()

Counter.__getter.expensive = function(self)
    print("  [计算 expensive 值...]")
    return (self._base or 0) * 100, true -- 返回值和缓存标志
end

local c1 = Counter()
c1._base = 5
print("首次访问 expensive:")
print("  expensive:", c1.expensive)
print("第二次访问 expensive (应该使用缓存):")
print("  expensive:", c1.expensive)
print()

-- 测试 3: 类似 Node 的 Vector2 属性访问
print("测试 3: 类似 Node 的 Vector2 属性访问")
local MyNode = Object:extend()

MyNode.__getter.x = function(self)
    return self.pos.x
end
MyNode.__getter.y = function(self)
    return self.pos.y
end

MyNode.__setter.x = function(self, value)
    self.pos.x = value
end
MyNode.__setter.y = function(self, value)
    self.pos.y = value
end

function MyNode:init(x, y)
    self.pos = Vector2(x or 0, y or 0)
end

local node = MyNode(10, 20)
print("创建节点 MyNode(10, 20)")
print("  node.x:", node.x)
print("  node.y:", node.y)
print("  node.pos:", node.pos.x, node.pos.y)

node.x = 100
print("设置 node.x = 100")
print("  node.x:", node.x)
print("  node.pos.x:", node.pos.x)
print()

-- 测试 4: 继承中的 getter/setter
print("测试 4: 继承中的 getter/setter")
local Animal = Object:extend()
Animal.__getter.info = function(self)
    return "Animal: " .. (self.name or "unnamed")
end

local Dog = Animal:extend()
Dog.__getter.sound = function(self)
    return "Woof!"
end

local dog1 = Dog()
dog1.name = "Buddy"
print("  info:", dog1.info)
print("  sound:", dog1.sound)
print()

print("=== 所有测试完成 ===")
