import UIKit

extension FGDatePicker {

    /// 控件视觉主题。提供 `.system` / `.light` / `.dark` 三种内置预设，
    /// 也可用 `.custom` 完全自定义所有颜色与圆角。
    public enum Theme {

        /// 跟随系统外观（基于 `UITraitCollection.userInterfaceStyle`）。
        case system

        /// 强制亮色风格。
        case light

        /// 强制暗色风格。
        case dark

        /// 完全自定义。
        case custom(Palette)

        /// 把当前主题（结合视图当前 traitCollection）解析为可直接消费的 `Palette`。
        func resolvedPalette(for traitCollection: UITraitCollection) -> Palette {
            switch self {
            case .system:
                return traitCollection.userInterfaceStyle == .dark ? .dark : .light
            case .light:
                return .light
            case .dark:
                return .dark
            case .custom(let palette):
                return palette
            }
        }
    }

    /// 描述完整一组视觉参数；可直接构造也可在内置 light/dark 基础上 override。
    public struct Palette {

        /// 半透明背景颜色（铺满全屏，做"模态遮罩"）。
        public var backdropColor: UIColor

        /// 卡片背景。
        public var cardBackgroundColor: UIColor

        /// 卡片圆角。
        public var cardCornerRadius: CGFloat

        /// 确认按钮文字颜色。
        public var confirmTextColor: UIColor

        /// 确认按钮背景色（设为 `.clear` 即只有文字、无填充）。
        public var confirmBackgroundColor: UIColor

        /// 取消按钮文字颜色。
        public var cancelTextColor: UIColor

        /// 取消按钮背景色。
        public var cancelBackgroundColor: UIColor

        /// 卡片底部按钮圆角。
        public var buttonCornerRadius: CGFloat

        /// 卡片与确认/取消按钮之间的分隔线颜色（`nil` 不画分隔线）。
        public var separatorColor: UIColor?

        public init(
            backdropColor: UIColor,
            cardBackgroundColor: UIColor,
            cardCornerRadius: CGFloat = 14,
            confirmTextColor: UIColor,
            confirmBackgroundColor: UIColor,
            cancelTextColor: UIColor,
            cancelBackgroundColor: UIColor,
            buttonCornerRadius: CGFloat = 10,
            separatorColor: UIColor? = nil
        ) {
            self.backdropColor = backdropColor
            self.cardBackgroundColor = cardBackgroundColor
            self.cardCornerRadius = cardCornerRadius
            self.confirmTextColor = confirmTextColor
            self.confirmBackgroundColor = confirmBackgroundColor
            self.cancelTextColor = cancelTextColor
            self.cancelBackgroundColor = cancelBackgroundColor
            self.buttonCornerRadius = buttonCornerRadius
            self.separatorColor = separatorColor
        }

        /// 内置亮色预设（白底 + 系统蓝确认 + 灰取消）。
        public static let light = Palette(
            backdropColor: UIColor.black.withAlphaComponent(0.35),
            cardBackgroundColor: .white,
            cardCornerRadius: 14,
            confirmTextColor: .white,
            confirmBackgroundColor: .systemBlue,
            cancelTextColor: .label,
            cancelBackgroundColor: UIColor(white: 0.92, alpha: 1.0),
            buttonCornerRadius: 10,
            separatorColor: UIColor(white: 0.85, alpha: 1.0)
        )

        /// 内置暗色预设（深灰底 + 系统蓝确认 + 浅灰取消）。
        public static let dark = Palette(
            backdropColor: UIColor.black.withAlphaComponent(0.55),
            cardBackgroundColor: UIColor(white: 0.16, alpha: 1.0),
            cardCornerRadius: 14,
            confirmTextColor: .white,
            confirmBackgroundColor: .systemBlue,
            cancelTextColor: .white,
            cancelBackgroundColor: UIColor(white: 0.28, alpha: 1.0),
            buttonCornerRadius: 10,
            separatorColor: UIColor(white: 0.30, alpha: 1.0)
        )
    }
}
