# FGDatePicker
> [English](README.md) | 中文

iOS 上**轻量、纯代码、零依赖**的日期选择弹窗组件，对系统 `UIDatePicker` 做
modal 风格包装：

- 半透明遮罩 + 居中卡片（slide-up 进场动画）
- 配置可定制：mode / locale / 时区 / 最早最晚日期 / 按钮文案 / 主题色
- closure 与 `async/await` 双 API
- 跟随系统 `light/dark`，也可强制单一外观
- iOS 16+，纯 Swift，**不依赖 SnapKit / Auto Layout**——内部全用 frame
  布局 + `layoutSubviews` 重排

> 这个仓库是 2015 年 OC 老项目 `UWDatePicker` 的彻底翻新。原版 OC 实现已经
> 整体替换，xib / delegate `String` 回传 / 颜色硬编码等过时做法全部丢弃。

## 安装

### Swift Package Manager（推荐）

`Xcode → File → Add Packages...` 输入：

```
https://github.com/Fengur/FGDatePicker
```

或者在自己的 `Package.swift` 里：

```swift
.package(url: "https://github.com/Fengur/FGDatePicker", from: "1.0.0")
```

### CocoaPods

```ruby
pod 'FGDatePicker', '~> 1.0'
```

### 手动

直接拖 `Sources/FGDatePicker/` 下的三个 `.swift` 文件进项目即可，零依赖。

## 30 秒上手

```swift
import FGDatePicker

// closure 风格
FGDatePicker.present(in: view) { date in
    print("user picked: \(date)")
}

// async/await 风格
Task {
    if let date = await FGDatePicker.pick(in: view) {
        print("user picked: \(date)")
    }
}
```

## 完整 API

```swift
public final class FGDatePicker: UIView {

    // MARK: 主入口

    /// closure 风格：弹出后通过 onConfirm/onCancel 回调
    @discardableResult
    public static func present(
        in host: UIView,
        configuration: Configuration = .init(),
        onConfirm: @escaping (Date) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> FGDatePicker

    /// async/await 风格：confirm 返回 Date，cancel 或点击背景返回 nil
    public static func pick(
        in host: UIView,
        configuration: Configuration = .init()
    ) async -> Date?

    // MARK: 直接构造

    public init(configuration: Configuration = .init())

    /// 替换当前配置
    public func update(configuration newValue: Configuration)

    /// 暴露内嵌的 UIDatePicker，需要细调（设置 calendar 等）时直接用
    public let datePicker: UIDatePicker
}
```

### Configuration

```swift
public struct Configuration {
    public var mode: UIDatePicker.Mode = .dateAndTime
    public var initialDate: Date = .init()
    public var minimumDate: Date?
    public var maximumDate: Date?
    public var locale: Locale?
    public var timeZone: TimeZone?
    public var preferredStyle: UIDatePickerStyle = .wheels
    public var confirmTitle: String = "确定"
    public var cancelTitle: String = "取消"
    public var theme: Theme = .system
    public var dismissOnBackdropTap: Bool = true
    public var animationDuration: TimeInterval = 0.28
}
```

### Theme

```swift
public enum Theme {
    case system     // 跟随系统
    case light      // 强制亮色
    case dark       // 强制暗色
    case custom(Palette)  // 完全自定义
}
```

`Palette` 控制 backdrop 颜色、卡片背景、圆角、按钮颜色与圆角、分隔线颜色。

## 使用例：自定义主题 + 限定日期范围

```swift
var config = FGDatePicker.Configuration()
config.mode = .date
config.initialDate = Date()
config.minimumDate = Date()
config.maximumDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
config.confirmTitle = "确认"

var palette = FGDatePicker.Palette.light
palette.cardCornerRadius = 22
palette.confirmBackgroundColor = UIColor.systemPink
palette.buttonCornerRadius = 18
config.theme = .custom(palette)

FGDatePicker.present(in: view, configuration: config) { date in
    print(date)
}
```

## 跑一下 Demo

```bash
cd Examples/FGDatePickerDemo
xcodegen generate                       # 生成 .xcodeproj（需要 brew install xcodegen）
open FGDatePickerDemo.xcodeproj
# Xcode 内选 iPhone 17 Pro 模拟器，⌘R 跑
```

Demo 里有 4 个按钮，分别演示：

1. 默认配置（dateAndTime + wheels + system theme）
2. 仅日期 + dark 主题
3. async/await 风格
4. 自定义 min/max + 自定义 palette（粉色按钮）

## 测试

```bash
xcodebuild test \
  -scheme FGDatePicker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -skipPackagePluginValidation
```

10 个单元测试覆盖 Configuration 默认值、Theme 解析、控件构造、layout 几何
关系。

## 路线图

- [x] v1.0：核心 modal 选择 + closure / async API + 主题
- [ ] v1.1：日期区间选择（同时选 start + end）
- [ ] v1.2：内嵌（inline）模式——直接放进自己的 view 而不是 modal
- [ ] v1.3：Combine publisher API
- [ ] v1.4：自定义动画（spring / 自定义 transition）

## 设计取舍记录

**为什么用 frame 布局而不是 Auto Layout / SnapKit**：项目作者偏好直接对
布局精确控制，frame 布局对这种容器组件足够清晰；旋转/不同屏幕尺寸通过
`layoutSubviews()` 重新计算覆盖。

**为什么不写 SwiftUI 版本**：SwiftUI 已经有原生 `DatePicker`，包装意义
不大；本库针对的是 UIKit 项目里需要 modal 形式呈现 UIDatePicker 的场景。

## License

MIT —— 见 [LICENSE](./LICENSE)。
