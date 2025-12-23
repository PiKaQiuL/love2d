# Getter/Setter 使用指南

## 概述

`Object` 类支持通过 `__getter` 和 `__setter` 表定义属性的 getter 和 setter 函数,实现类似属性访问的语法糖。

## 基础用法

### 定义 Getter

```lua
local MyClass = Object:extend()

-- 直接赋值到 __getter 表
MyClass.__getter.propertyName = function(self)
    return self._internalValue
end
```

### 定义 Setter

```lua
MyClass.__setter.propertyName = function(self, value)
    self._internalValue = value
    -- 返回 nil 表示不缓存结果
end
```

### 使用属性

```lua
local obj = MyClass()
obj.propertyName = 100  -- 调用 setter
print(obj.propertyName) -- 调用 getter
```

## Getter 缓存机制

Getter 函数可以返回两个值:`value` 和 `needCache`。

```lua
MyClass.__getter.expensiveProperty = function(self)
    local result = doExpensiveCalculation(self)
    return result, true  -- 第二个参数为 true 表示缓存结果
end
```

当 `needCache` 为 `true` 时:
- 第一次访问会调用 getter 函数并缓存结果
- 后续访问直接返回缓存的值,不再调用 getter 函数

## Setter 返回值

Setter 函数的返回值决定是否缓存:

```lua
-- 不缓存(副作用型)
MyClass.__setter.x = function(self, value)
    self.pos.x = value
    -- 返回 nil,不缓存
end

-- 缓存处理后的值
MyClass.__setter.normalizedValue = function(self, value)
    if value < 0 then value = 0 end
    if value > 1 then value = 1 end
    return value  -- 返回非 nil 值会被缓存
end
```

## 实际案例: Node 类

参考 `Engine/Core/Node.lua` 的实现:

```lua
local Node = Object:extend()

-- 定义 x, y 属性的 getter,使其返回内部 Vector2 的值
Node.__getter.x = function(self)
    return self.pos.x
end

Node.__getter.y = function(self)
    return self.pos.y
end

-- 定义 setter(可选)
Node.__setter.x = function(self, value)
    self.pos.x = value
end

Node.__setter.y = function(self, value)
    self.pos.y = value
end

function Node:init(x, y)
    self.pos = Vector2(x or 0, y or 0)
end

-- 使用
local node = Node(10, 20)
print(node.x)  -- 输出 10 (调用 getter)
node.x = 100   -- 调用 setter
```

## 继承行为

子类会自动继承父类的 getter 和 setter:

```lua
local Animal = Object:extend()
Animal.__getter.info = function(self)
    return "Animal: " .. (self.name or "unnamed")
end

local Dog = Animal:extend()
Dog.__getter.sound = function(self)
    return "Woof!"
end

local dog = Dog()
dog.name = "Buddy"
print(dog.info)   -- "Animal: Buddy" (继承自 Animal)
print(dog.sound)  -- "Woof!" (Dog 自己的)
```

子类可以覆盖父类的 getter/setter:

```lua
Dog.__getter.info = function(self)
    return "Dog: " .. (self.name or "unnamed")
end
```

## 注意事项

1. **性能考虑**: Getter/Setter 会在每次属性访问时调用,频繁访问的属性考虑使用缓存机制
2. **命名约定**: 内部存储字段建议使用下划线前缀(如 `_value`)以区分公开属性
3. **调试**: 如果属性访问出现意外行为,检查是否定义了对应的 getter/setter
4. **类型提示**: 在类注释中声明公开属性以获得更好的 IDE 支持

## 完整示例

```lua
local Person = Object:extend()

-- Getter: 计算属性
Person.__getter.fullName = function(self)
    return (self._firstName or "") .. " " .. (self._lastName or "")
end

-- Setter: 拆分并存储
Person.__setter.fullName = function(self, value)
    local parts = {}
    for part in string.gmatch(value, "%S+") do
        table.insert(parts, part)
    end
    self._firstName = parts[1] or ""
    self._lastName = parts[2] or ""
    -- 返回 nil,不缓存 fullName 本身
end

-- Getter: 带验证的年龄
Person.__getter.age = function(self)
    return self._age or 0
end

Person.__setter.age = function(self, value)
    if type(value) ~= "number" or value < 0 then
        value = 0
    end
    self._age = value
end

-- 使用
local person = Person()
person.fullName = "John Doe"
person.age = 30

print(person.fullName)  -- "John Doe"
print(person._firstName) -- "John"
print(person._lastName)  -- "Doe"
print(person.age)        -- 30

person.age = -5
print(person.age)        -- 0 (被限制为非负数)
```

## 参考

- `Engine/Core/Object.lua` - 基础实现
- `Engine/Core/Node.lua` - 实际应用示例
- `test_object_getter_setter.lua` - 测试用例
