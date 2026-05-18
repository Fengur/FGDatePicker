import UIKit

extension FGDatePicker {

    /// 控件运行时所有可调参数。所有字段都有合理默认值，
    /// 一行 `Configuration()` 即可拿到"开箱即用"配置。
    public struct Configuration {

        /// 内嵌 `UIDatePicker.Mode`：date / time / dateAndTime / countDownTimer。
        public var mode: UIDatePicker.Mode = .dateAndTime

        /// 弹出时 picker 的默认日期。
        public var initialDate: Date = .init()

        /// 可选的最早可选日期。`nil` 表示不限。
        public var minimumDate: Date?

        /// 可选的最晚可选日期。`nil` 表示不限。
        public var maximumDate: Date?

        /// `UIDatePicker` 的语言/地区设置。`nil` 走系统默认。
        public var locale: Locale?

        /// `UIDatePicker` 的时区。`nil` 走系统默认。
        public var timeZone: TimeZone?

        /// `UIDatePicker` 的视觉风格——`.wheels`（经典转轮）或 `.compact`（弹气泡）等。
        /// 默认 `.wheels`，对老式弹层 modal 视觉一致性最好。
        public var preferredStyle: UIDatePickerStyle = .wheels

        /// 确认按钮文字。
        public var confirmTitle: String = "确定"

        /// 取消按钮文字。
        public var cancelTitle: String = "取消"

        /// 主题（颜色 + 圆角等视觉参数）。见 `FGDatePicker.Theme`。
        public var theme: Theme = .system

        /// 点击半透明背景区域是否关闭弹层。默认 `true`。
        public var dismissOnBackdropTap: Bool = true

        /// 弹出/关闭动画时长。默认 0.28s（iOS 系统模态偏好的速度）。
        public var animationDuration: TimeInterval = 0.28

        public init() {}
    }
}
