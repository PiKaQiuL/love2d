# Setter 函数泛型约束快速参考

## 📌 什么是泛型约束？

为 setter 方法添加泛型约束，使链式调用能正确保持子类类型信息。

```lua
-- ❌ 没有泛型：返回类型丢失为 Widget
---@return Widget
function Widget:setSize(w, h)
    return self
end

-- ✅ 有泛型：返回类型保持为调用者类型
---@generic T : Widget
---@param self T
---@return T
function Widget:setSize(w, h)
    return self
end
```

## 🎯 标准注解模板

```lua
---@generic T : ClassName
---@param self T
---@param arg1 type1|nil
---@param arg2 type2|nil
---@return T
function ClassName:setterMethod(arg1, arg2)
    -- 实现
    return self
end
```

## 📊 已配置的类和方法数量

| 类 | Setter 数量 | 状态 |
|----|-----------|------|
| Node | 10 | ✅ 完成 |
| Widget | 9 | ✅ 完成 |
| Label | 3 | ✅ 完成 |
| Button | 6 | ✅ 完成 |
| Panel | 5 | ✅ 完成 |
| TextInput | 5 | ✅ 完成 |
| ListView | 9 | ✅ 完成 |
| ProgressBar | 5 | ✅ 完成 |
| Layout | 10 | ✅ 完成 |
| **总计** | **62** | **✅** |

## 🔍 验证泛型约束

### 在编辑器中检查

```lua
local label = Label()
    :setText("Hello")
    --^^ 悬停查看：应该显示 label: Label（而不是 Widget）
```

### 测试完整继承链

```lua
-- 标准链式调用模式
local button = Button()
    :setText("Click")          -- Button 方法 → 返回 Button
    :setSize(120, 30)          -- Widget 方法 → 返回 Button ✓
    :setPosition(10, 10)       -- Node 方法 → 返回 Button ✓
    :setPivotCenter()          -- Node 方法 → 返回 Button ✓

-- 每一步都能获得准确的自动补全
```

## 💡 关键概念

### T 的含义

- `T` 是泛型类型参数
- `T : ClassName` 表示 T 被约束为 ClassName 或其子类
- 调用 `ClassName()` 时，T 自动替换为 ClassName

### 示例推导

```lua
-- 调用 Label():setSize()
local label = Label()
    :setSize(100, 30)
    
-- 推导过程：
-- 1. label 的类型是 Label
-- 2. setSize() 来自 Widget，签名为 @return T
-- 3. 在 Label 上下文中，T = Label
-- 4. 因此返回值类型是 Label（而不是 Widget）
```

## 📋 检查清单

使用此清单验证泛型约束的完整性：

- [ ] 所有 setter 方法都有 `@generic T : ClassName` 注解
- [ ] 所有 setter 方法都有 `@param self T` 注解
- [ ] 所有 setter 方法的返回类型都是 `@return T`
- [ ] `@generic T : ClassName` 中的 ClassName 与所在类一致
- [ ] 没有 setter 方法返回具体的类型（如 `@return Widget`）

## 🛠️ 添加新 Setter 时的步骤

1. **确认继承链**：新 setter 在哪个类中？
   ```lua
   ---@class MyButton : Button
   ```

2. **编写泛型注解**
   ```lua
   ---@generic T : MyButton
   ---@param self T
   ---@param value type
   ---@return T
   function MyButton:setMyProperty(value)
   ```

3. **实现方法体**
   ```lua
       self.myProperty = value
       return self
   end
   ```

4. **测试链式调用**
   ```lua
   local btn = MyButton()
       :setText("text")
       :setMyProperty("value")
   ```

## ❗ 常见错误

### ❌ 错误：返回固定类型
```lua
---@return Button
function Button:setText(text)
    return self  -- 当 Button 被子类继承时，类型丢失
end
```

### ✅ 正确：使用泛型
```lua
---@generic T : Button
---@param self T
---@return T
function Button:setText(text)
    return self  -- 自动保持子类类型
end
```

### ❌ 错误：遗漏 `@param self T`
```lua
---@generic T : Button
---@return T
function Button:setText(text)  -- 缺少 @param self T
```

### ✅ 正确：完整注解
```lua
---@generic T : Button
---@param self T
---@return T
function Button:setText(text)
```

## 📚 相关文档

- `Docs/Generic-Chaining-Implementation.md` - 完整实现说明
- `Docs/Type-Inference-Setup.md` - 类型推断配置
- `Docs/Type-Inference-Quick-Ref.md` - 类型推断快速参考

## ✨ 效果展示

### 链式调用自动类型保持

```lua
-- 简洁的链式 API
local ui = Panel()
    :setSize(300, 200)
    :setFill({0.1, 0.1, 0.1})
    :setPosition(100, 100)
    :add(
        Label()
            :setText("Hello World")
            :setColor(1, 1, 1)
            :setPosition(10, 10)
    )
    :add(
        Button()
            :setText("Click Me")
            :setSize(100, 30)
            :setPosition(10, 50)
            :setOnClick(function() print("Clicked!") end)
    )

-- 每一步都有完整的类型信息和自动补全 ✨
```

---

**总结：** 通过泛型约束，我们实现了 Lua 中罕见的**完全类型安全的链式调用**，让每个方法都能推断正确的返回类型，即使在深层继承链中也不例外。
