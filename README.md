# FGDatePicker
> English | [中文](README_CN.md)

A **lightweight, code-only, zero-dependency** date picker modal for iOS, wrapping the system `UIDatePicker` in a modal-style presentation:

- Semi-transparent backdrop + centered card (slide-up entry animation)
- Configurable: mode / locale / time zone / min & max dates / button titles / theme color
- Both `closure` and `async/await` APIs
- Follows system `light/dark` mode; can also force a single appearance
- iOS 16+, pure Swift, **no SnapKit / Auto Layout** — layout is entirely frame-based + `layoutSubviews` recalculation

> This repo is a complete rewrite of `UWDatePicker`, a 2015 Objective-C project. The original OC implementation has been replaced wholesale; xib files, delegate-based `String` callbacks, and hardcoded colors have all been dropped.

## Installation

### Swift Package Manager (recommended)

In Xcode: `File → Add Packages...` and enter:

```
https://github.com/Fengur/FGDatePicker
```

Or in your own `Package.swift`:

```swift
.package(url: "https://github.com/Fengur/FGDatePicker", from: "1.0.0")
```

### CocoaPods

```ruby
pod 'FGDatePicker', '~> 1.0'
```

### Manual

Drag the three `.swift` files from `Sources/FGDatePicker/` into your project. Zero dependencies.

## 30-Second Quick Start

```swift
import FGDatePicker

// Closure style
FGDatePicker.present(in: view) { date in
    print("user picked: \(date)")
}

// async/await style
Task {
    if let date = await FGDatePicker.pick(in: view) {
        print("user picked: \(date)")
    }
}
```

## Full API

```swift
public final class FGDatePicker: UIView {

    // MARK: Primary entry points

    /// Closure style: present the picker; result delivered via onConfirm/onCancel
    @discardableResult
    public static func present(
        in host: UIView,
        configuration: Configuration = .init(),
        onConfirm: @escaping (Date) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> FGDatePicker

    /// async/await style: confirm returns Date, cancel or backdrop tap returns nil
    public static func pick(
        in host: UIView,
        configuration: Configuration = .init()
    ) async -> Date?

    // MARK: Direct construction

    public init(configuration: Configuration = .init())

    /// Replace the current configuration
    public func update(configuration newValue: Configuration)

    /// Exposes the embedded UIDatePicker for fine-grained access (e.g. setting calendar)
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
    case system     // follows system appearance
    case light      // force light mode
    case dark       // force dark mode
    case custom(Palette)  // fully custom
}
```

`Palette` controls backdrop color, card background, corner radius, button color & corner radius, and separator color.

## Example: Custom Theme + Date Range

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

## Running the Demo

```bash
cd Examples/FGDatePickerDemo
xcodegen generate                       # generate .xcodeproj (requires: brew install xcodegen)
open FGDatePickerDemo.xcodeproj
# Select iPhone 17 Pro Simulator in Xcode, press ⌘R
```

The demo has 4 buttons demonstrating:

1. Default configuration (dateAndTime + wheels + system theme)
2. Date-only + dark theme
3. async/await style
4. Custom min/max + custom palette (pink button)

## Tests

```bash
xcodebuild test \
  -scheme FGDatePicker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro,OS=latest' \
  -skipPackagePluginValidation
```

10 unit tests covering Configuration defaults, Theme resolution, control construction, and layout geometry.

## Roadmap

- [x] v1.0: core modal picker + closure / async API + theming
- [ ] v1.1: date range selection (pick start + end simultaneously)
- [ ] v1.2: inline mode — embed directly in a view instead of modal
- [ ] v1.3: Combine publisher API
- [ ] v1.4: custom animations (spring / custom transition)

## Design Notes

**Why frame layout instead of Auto Layout / SnapKit**: the author prefers direct, precise layout control; frame layout is clear enough for a container component like this. Rotation and different screen sizes are handled by recalculating in `layoutSubviews()`.

**Why no SwiftUI version**: SwiftUI already has a native `DatePicker`; wrapping it adds little value. This library targets UIKit projects that need to present `UIDatePicker` in a modal style.

## License

MIT — see [LICENSE](./LICENSE).
