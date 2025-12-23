# UI 组件类型推断配置说明

## 问题背景

在 Lua 中使用 `__call` 元方法实现构造函数语法糖时（如 `Label()` 等价于 `Label:new()`），Lua Language Server (LuaLS) 需要额外的类型注解才能正确推断返回类型。

## 解决方案

### 1. 核心机制

在 `Object:extend()` 中，我们为每个类的元表添加了泛型注解：

```lua
setmetatable(subclass, {
    __index = self,
    ---@generic T : Object
    ---@param cls T
    ---@param ... unknown
    ---@return T
    __call = function(cls, ...)
        return cls:new(...)
    end
})
```

这个注解的含义：
- `@generic T : Object`：定义泛型类型参数 `T`，约束为 `Object` 的子类
- `@param cls T`：参数 `cls` 的类型是 `T`（调用时的实际类）
- `@return T`：返回值类型也是 `T`

### 2. 类级别注解

为了让 LuaLS 正确应用泛型推断，每个 UI 类需要添加 `@overload` 注解：

```lua
---@class Label : Widget
---@field text string
---@field color Color
---@field font love.Font|nil
---@overload fun(...):Label  -- ← 关键注解
local Label = Widget:extend()
```

**`@overload` 注解的作用：**
- 明确告诉 LuaLS：调用 `Label(...)` 时返回 `Label` 类型
- 覆盖默认的元表 `__call` 推断
- 支持参数列表（`...` 表示接受任意参数）

### 3. 已配置的类

以下 UI 组件已添加 `@overload` 注解：

- `Widget` (基类)
- `Label`
- `Button`
- `Panel`
- `TextInput`
- `ListView`
- `ProgressBar`
- `Layout`

## 使用效果

### 正确的类型推断示例

```lua
-- ✅ LuaLS 能正确推断 label 的类型为 Label
local label = Label()
    :setText("Hello")      -- 有自动补全提示
    :setColor(1, 1, 1, 1)

-- ✅ 能访问 Label 特有的字段
print(label.text)   -- 类型：string
print(label.color)  -- 类型：Color
print(label.font)   -- 类型：love.Font|nil

-- ✅ 继承的字段也能正确识别
print(label.w)      -- 继承自 Widget
print(label.x)      -- 继承自 Node (通过 getter)
```

### 链式调用中的类型传递

```lua
-- ✅ 每一步都返回正确的类型
local button = Button()        -- 类型：Button
    :setText("Click")          -- 返回 Button，有智能提示
    :setPosition(10, 10)       -- 返回 Button，有智能提示
    :setSize(100, 30)          -- 返回 Button，有智能提示
    :onClick(function() end)   -- Button 特有方法，有提示
```

## 验证方法

### 方法 1：在编辑器中测试

1. 打开 `test_type_inference.lua` 文件
2. 将光标放在 `Label()` 后面输入 `.`
3. 应该看到 `setText`、`setColor`、`setFont` 等方法提示
4. 访问 `label.text` 时应该显示类型为 `string`

### 方法 2：悬停查看类型

1. 将鼠标悬停在变量上：
   ```lua
   local label = Label()
   --    ^^^^^
   ```
2. 应该显示：`label: Label`

### 方法 3：检查诊断信息

```lua
local label = Label()
label.nonExistentField = 123  -- ⚠️ 应该提示字段不存在
```

## 常见问题

### Q1: 为什么需要 `@overload` 注解？

**A:** 虽然 `Object:extend()` 中已有泛型注解，但 LuaLS 在处理具体类时需要明确的类型映射。`@overload` 注解提供了这个映射。

### Q2: 如果不加 `@overload` 会怎样？

**A:** LuaLS 会将 `Label()` 的返回类型推断为 `Object`，导致：
- 无法访问 `Label` 特有字段（如 `text`）
- 链式调用时丢失类型信息
- 自动补全不准确

### Q3: 能否简化注解？

**A:** 可以使用更精确的参数类型，例如：

```lua
---@class Label : Widget
---@overload fun():Label  -- 无参数版本
local Label = Widget:extend()
```

由于当前所有 `init()` 都是无参数的，可以这样写。但使用 `fun(...):Label` 更通用，未来如果需要添加可选参数也不用改注解。

### Q4: 其他类（如 Scene、System）需要加吗？

**A:** 推荐加！任何使用 `Class()` 语法糖的类都应该添加 `@overload` 注解，以获得更好的类型推断。

## 最佳实践

### 新建类时的注解模板

```lua
local BaseClass = require("path.to.BaseClass")

---@class MyClass : BaseClass
---@field myField string
---@overload fun(...):MyClass
local MyClass = BaseClass:extend()

function MyClass:init()
    BaseClass.init(self)
    self.myField = ""
end

return MyClass
```

### 为现有类添加注解

只需在 `@class` 注解后添加一行：

```diff
  ---@class ExistingClass : BaseClass
  ---@field someField number
+ ---@overload fun(...):ExistingClass
  local ExistingClass = BaseClass:extend()
```

## 技术细节

### LuaLS 泛型推断流程

1. 调用 `Label()` 时，LuaLS 查找 `Label` 的元表
2. 发现 `@overload fun(...):Label` 注解
3. 确定返回类型为 `Label`
4. 加载 `Label` 类的字段和方法定义
5. 提供自动补全和类型检查

### 为什么基类也需要注解？

即使 `Widget` 通常不会直接实例化，添加 `@overload` 注解仍有用：
- 提高类型系统完整性
- 在测试或内部代码中可能直接使用 `Widget()`
- 为子类提供更好的类型继承

## 参考资料

- [Lua Language Server 官方文档](https://github.com/LuaLS/lua-language-server/wiki)
- [LuaLS 注解参考](https://github.com/LuaLS/lua-language-server/wiki/Annotations)
- 项目中的 `Engine/Core/Object.lua` - OOP 实现源码
- 项目中的 `test_type_inference.lua` - 类型推断测试用例

## 总结

通过为每个 UI 类添加 `@overload fun(...):ClassName` 注解，我们让 Lua Language Server 能够：

✅ 正确推断 `Label()` 等调用的返回类型  
✅ 在链式调用中保持类型信息  
✅ 提供准确的自动补全和字段提示  
✅ 检测类型错误（如访问不存在的字段）  

这大大提升了开发体验，减少了运行时错误。
