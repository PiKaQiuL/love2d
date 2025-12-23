# 类型推断快速参考

## ✅ 已完成的配置

所有 UI 组件已添加 `@overload` 注解以支持正确的类型推断：

| 组件 | 类型注解 | 链式调用示例 |
|------|---------|-------------|
| `Label` | `---@overload fun(...):Label` | `Label():setText("Hi"):setColor(1,1,1)` |
| `Button` | `---@overload fun(...):Button` | `Button():setText("OK"):setSize(100,30)` |
| `Panel` | `---@overload fun(...):Panel` | `Panel():setSize(200,100):setFill({...})` |
| `TextInput` | `---@overload fun(...):TextInput` | `TextInput():setPlaceholder("..."):setSize(180,28)` |
| `ListView` | `---@overload fun(...):ListView` | `ListView():setWidth(200):setItemHeight(20)` |
| `ProgressBar` | `---@overload fun(...):ProgressBar` | `ProgressBar():setRange(0,100):setValue(50)` |
| `Layout` | `---@overload fun(...):Layout` | `Layout():setDirection("vertical"):setSpacing(8)` |
| `Widget` | `---@overload fun(...):Widget` | 基类（一般不直接实例化） |

## 🎯 核心注解模式

```lua
---@class ClassName : ParentClass
---@field someField string
---@overload fun(...):ClassName  ← 关键：让 ClassName() 返回正确类型
local ClassName = ParentClass:extend()
```

## 🔍 验证方法

### 在编辑器中测试
```lua
local label = Label()  -- 悬停查看类型：应显示 "label: Label"
label.  -- 输入点号，应显示 setText/setColor/text/color 等提示
```

### 运行测试文件
```bash
# 测试类型推断（无需运行，仅供 LuaLS 分析）
# 在编辑器中打开此文件查看类型提示
love . test_type_inference.lua
```

## 📚 详细文档

- **完整说明**: `Docs/Type-Inference-Setup.md`
- **测试用例**: `test_type_inference.lua`
- **OOP 实现**: `Engine/Core/Object.lua`

## 💡 要点

1. **`@overload` 的作用**: 告诉 LuaLS 调用 `Class()` 时返回 `Class` 类型
2. **泛型机制**: `Object:extend()` 中的泛型注解自动传递类型
3. **链式调用**: 每个 setter 返回 `self`，保持类型不变
4. **参数灵活性**: `fun(...):Type` 接受任意参数（当前所有 init 都是无参数）

## ⚠️ 注意事项

- LuaLS 可能需要重启才能识别新注解
- 继承的方法（如 `setVisible`）可能显示警告，但运行时正常工作
- 如果类型推断不工作，检查 `.luarc.json` 配置（如果有）
