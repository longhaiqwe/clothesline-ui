# 模板接入

## 文件边界

模板位于 `assets/swiftui-appkit/`。脚手架复制时排除 `.build` 与 `dist`，不依赖原始 AI 用量看板。

| 文件 | 职责 |
| --- | --- |
| `ScreenEdge.swift` | 边缘枚举、可见区域布局、物理边缘命中、跨菜单栏／Dock 的保活区域、悬停计时 |
| `RailState.swift` | 显示状态、固定、位置锁定、尺寸、持久化顺序；不含业务数据 |
| `RailPresentation.swift` | 系统材质、点击命中区域、摆动与减少动态效果支持 |
| `RailDecoration.swift` | 四方向绳子和木夹；可替换装饰 |
| `ClotheslineView.swift` | 泛型容器、固定尺寸滚动、控制栏、通用 `HangingCard` |
| `RailWindowController.swift` | NSPanel、状态菜单、边缘轮询、吸附、多屏回退、详情窗口 |
| `FileDropHostingView.swift` | 可选的原生文件接收与拖放检测 |
| `Demo.swift` | 三种业务卡片示例和产品配置 |
| `Main.swift` | 应用启动、组件装配和退出清理 |
| `PreviewRenderer.swift` | 离线视觉检查入口 |

## 接入已有工程

复制前检查现有类型名，避免 `ScreenEdge`、`RailState` 等冲突。复制七个通用源文件：ScreenEdge、RailState、RailPresentation、RailDecoration、ClotheslineView、RailWindowController、FileDropHostingView。排除示例 Demo、Main 和 PreviewRenderer。

在现有 AppDelegate 中强持有控制器，启动时创建，退出时调用 `stop()`。若应用已有菜单栏入口，可以从控制器中移除 `statusItem` 相关代码，将 reveal/hide、固定和位置动作接到原菜单。不要创建第二套应用入口或重复状态栏图标。

```swift
struct TaskItem: Identifiable {
    let id: UUID       // 从业务记录恢复，刷新时保持稳定
    let title: String
    let progress: Double
}

// 在 @MainActor 上执行；controller 由应用持有。
let state = RailState(defaults: .standard)
let controller = RailWindowController(state: state, title: "任务晾台", symbol: "checklist") {
    ClotheslineView(state: state, items: tasks, title: { $0.title }) { item, compact in
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title).font(.headline)
            ProgressView(value: item.progress)
        }
        .padding(compact ? 14 : 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
```

示例 `tasks` 是调用方数组。实时数据应由一个 SwiftUI 根视图使用 `@ObservedObject` 观察业务模型，再把 `model.items` 传给容器；不要把初始化时的数组拷贝当成实时绑定。整个 RailState 在主线程更新。

## 尺寸、排列与组

默认标准卡 264×220、迷你卡 224×156；竖向面板宽度为卡宽＋72，横向高度为卡高＋102。夹子额外占 18 点，控制条预留约 50～56 点。数值是起点，可以用 `RailMetrics(standard:compact:spacing:)` 覆盖。

每张卡片都得到固定尺寸，不依赖内容把视口撑大。长文本截断并通过详情展开；大字体或较复杂内容要增加尺寸。`card` 闭包第二参数为 compact。不要固定 `.environment(\.colorScheme, .light)` 后假定系统深色仍然正确。

排序是相邻换位：沿主轴拖动夹子超过卡片尺寸的 35% 即前移／后移一位。业务数据不写入 RailState；这里只保存 UUID 顺序。新记录追加到已知记录后面，已删除记录不显示。UUID 必须唯一。

分组不是模板中的已完成功能。若业务需要平台／项目组，使用一个稳定组 ID 作为容器 item，把组内卡片交给自定义内容布局；复杂变宽组需要相应扩展布局和拖拽阈值。不要直接带回来源项目中的 Provider 或账户类型。

## 产品配置与打包

脚手架同时填写 `DemoConfig`（Swift 显示名、开发用偏好标识、菜单 symbol）和 `app-config.json`（打包显示名、bundle ID）。手动更名时两个位置保持一致。二进制 target 名称无需随产品名改变。打包应用使用 `UserDefaults.standard`；不要用自己的 bundle ID 调用 `UserDefaults(suiteName:)`，该调用会失败。未打包调试时使用 bundle ID 加 `.development` 后缀的独立域。

`build_app.py` 调用本机 Swift 工具链，生成当前 CPU 架构的 `.app` 并校验 ad-hoc 签名。它不做 Developer ID 签名、公证、通用二进制、自动更新或正式应用图标；分发需求要按实际产品补齐。模板没有网络、登录或系统隐私权限。

把真实业务数据放在产品自己命名的存储里。示例按钮状态是视图内临时状态；样例内容没有文件读取、剪贴板访问或后台任务调度能力。

## 文件暂存类产品

控制器的 `onFileDrop: (([URL]) -> Void)?` 默认为 nil。提供回调才启用文件拖入；原生宿主读取 `.fileURL`，反馈 `.copy`。业务层在回调里异步保存文件，并通过 ObservableObject 更新卡片。`state.isDropTarget` 表示有效文件正悬停在面板上。

普通鼠标按住时暂停自动显隐；新的文件拖动则允许边缘悬停展开，同时让整个面板接受拖放。FileDragTracker 根据 drag pasteboard changeCount 判断新拖动，防止上一次拖放的粘贴板残留误触发。

向其他应用拖出时，使用 `NSDraggingItem(pasteboardWriter: fileURL as NSURL)`，在 `NSDraggingSource` 返回 `.copy`。只向 pasteboard 写路径字符串不等于文件拖放。原生拖动区域应在卡片内容里，夹子继续承担排序。文件 promise 类型、网页链接、文件夹处理是另外的产品能力，不能默认为已支持。

`additionalMenuItems` 可注入业务菜单项；`suspendForDialog()` 和 `resumeAfterDialog()` 可在 NSOpenPanel 期间暂时收起高层级面板并暂停悬停，防止遮住文件选择器。回调需由产品负责配对调用。

“稍后阅读”是第一个文件暂存复用案例，业务层增加了托管副本、SHA-256 去重、原生文件拖出、缩略图、Quick Look 预览、已读状态和移除。核心文件可以保持相同；这些业务逻辑不并入通用模板。
