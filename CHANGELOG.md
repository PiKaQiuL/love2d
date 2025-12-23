# 更新日志

## 2025-12-23 v2

### UI组件初始化统一优化

#### 重大变更 ⚠️

**所有UI组件的init函数现在都不接受参数，必须使用链式调用来初始化！**

这是一个破坏性更新，但使得API更加统一和优雅。

#### 修改内容

所有UI组件的init函数改为无参数：

1. **Widget** - 基类改为无参数初始化
2. **Button** - 必须通过链式调用设置文本、位置、尺寸等
3. **Panel** - 必须通过链式调用设置位置、尺寸、样式等  
4. **Label** - 必须通过链式调用设置文本、位置、颜色等
5. **TextInput** - 必须通过链式调用设置位置、尺寸、占位符等
6. **ListView** - 必须通过链式调用设置位置、宽度、项高度等
7. **ProgressBar** - 必须通过链式调用设置位置、尺寸、范围等
8. **Layout** - 必须通过链式调用设置位置、尺寸、方向等

#### 代码对比

**旧写法（已废弃）**:
```lua
local button = Button("Click", 10, 10, 120, 30)
local panel = Panel(10, 10, 300, 200)
local label = Label("Hello", 10, 10)
local input = TextInput(10, 10, 200, 28)
```

**新写法（必须使用）**:
```lua
local button = Button()
    :setText("Click")
    :setPosition(10, 10)
    :setSize(120, 30)

local panel = Panel()
    :setPosition(10, 10)
    :setSize(300, 200)

local label = Label()
    :setText("Hello")
    :setPosition(10, 10)

local input = TextInput()
    :setPosition(10, 10)
    :setSize(200, 28)
```

#### 优势

1. **API完全统一** - 所有组件使用相同的创建模式
2. **更加灵活** - 可以按需设置属性
3. **可读性更强** - 每个属性的设置一目了然
4. **避免参数混淆** - 不会因为参数顺序错误导致问题

#### 场景更新

所有示例场景已更新为新的写法：
- MainScene - 使用无参数初始化+链式调用
- ButtonTestScene - 使用无参数初始化+链式调用
- VecAnimTestScene - 使用无参数初始化+链式调用
- ChainTestScene - 完整演示无参数初始化+链式调用

#### 文档更新

- 更新 `Docs/UI-Chain-Calling.md` - 完全重写，强调必须使用新API
- 更新 `Docs/UI-Quick-Reference.md` - 更新为新的调用方式

#### 迁移要求

**所有现有代码必须迁移！** 旧的参数化构造函数已不再工作。

#### 测试

- ✅ 所有UI组件类型检查通过
- ✅ 所有示例场景运行正常
- ✅ 链式调用功能验证完成

---

## 2025-12-23

### UI组件链式调用优化

#### 优化内容

统一优化了所有UI组件,使其支持链式调用API,提升代码可读性和开发效率。

#### 修改的组件

1. **Button（按钮组件）**
   - 新增 `setText()` - 设置按钮文本
   - 新增 `setSize()` - 设置按钮尺寸
   - 新增 `setColors()` - 设置颜色集
   - 新增 `setBorderWidth()` - 设置边框宽度
   - 新增 `setOnClick()` - 设置点击回调
   - 优化 `setDisabled()` - 返回self支持链式调用
   - 优化 `setFocus()` - 返回self支持链式调用

2. **Panel（面板组件）**
   - 新增 `setFill()` - 设置填充色
   - 新增 `setBorder()` - 设置边框颜色
   - 新增 `setBorderWidth()` - 设置边框宽度
   - 新增 `setPadding()` - 设置内边距
   - 优化 `setSize()` - 返回self支持链式调用

3. **Label（标签组件）**
   - 已有的 `setText()`, `setColor()`, `setFont()` 均支持链式调用

4. **TextInput（输入框组件）**
   - 修复 `init()` 方法参数缺失问题
   - 新增 `setPlaceholder()` - 设置占位符
   - 新增 `setColors()` - 设置颜色集
   - 新增 `setSize()` - 设置尺寸
   - 新增 `setFocused()` - 设置聚焦状态
   - 优化 `setText()` - 返回self支持链式调用

5. **ListView（列表视图组件）**
   - 新增 `setOnSelect()` - 设置选中回调
   - 新增 `setColors()` - 设置颜色集
   - 新增 `setMaxVisible()` - 设置最大可见项数
   - 新增 `setItemHeight()` - 设置列表项高度
   - 新增 `setWidth()` - 设置列表宽度
   - 优化 `add()` - 返回self支持链式调用
   - 优化 `clear()` - 返回self支持链式调用
   - 优化 `setScroll()` - 返回self支持链式调用
   - 优化 `scrollBy()` - 返回self支持链式调用

6. **ProgressBar（进度条组件）**
   - 新增 `setSize()` - 设置进度条尺寸
   - 新增 `setBorderWidth()` - 设置边框宽度
   - 优化 `setRange()` - 返回self支持链式调用
   - 优化 `setValue()` - 返回self支持链式调用
   - 优化 `setColors()` - 返回self支持链式调用

7. **Layout（布局容器）**
   - 已有的所有setter方法均支持链式调用
   - `setDirection()`, `setSpacing()`, `setPadding()`, `setAlign()`, `setJustify()`, `setWrap()`, `setClip()`, `setGaps()`, `setAutoSize()`, `setSize()`

#### 基础类优化

- **Widget** - 更新 `init()` 方法支持位置和尺寸参数
- **Node** - 更新 `init()` 方法支持位置参数

#### 示例场景更新

1. **MainScene** - 更新为使用链式调用
2. **ButtonTestScene** - 更新为使用链式调用
3. **VecAnimTestScene** - 更新为使用链式调用
4. **ChainTestScene** - 新增,展示所有组件的链式调用用法

#### 文档更新

- 新增 `Docs/UI-Chain-Calling.md` - 详细的链式调用使用指南
- 更新 `README.md` - 添加最新更新说明
- 新增 `CHANGELOG.md` - 本更新日志

#### 优势

1. **代码更简洁** - 减少临时变量,配置集中
2. **可读性强** - 配置意图清晰,易于维护
3. **灵活组合** - 可根据条件动态添加配置
4. **向后兼容** - 旧的构造函数传参方式仍然有效

#### 迁移建议

现有代码无需强制迁移,但建议在新代码中使用链式调用风格:

```lua
-- 推荐写法
local button = Button("Submit", 10, 10, 140, 32)
    :setOnClick(handleSubmit)
    :setColors(customColors)
    :setBorderWidth(2)
```

#### 测试

- ✅ 所有UI组件类型检查通过
- ✅ 示例场景运行正常
- ✅ 链式调用功能验证完成
