import UIKit

/// 一个 modal 包装的日期选择控件。
///
/// 替代陈旧的 `UWDatePickerView`（2015 年 OC 实现）。设计要点：
///
/// - **纯代码 + frame 布局**：不依赖 xib，不使用 Auto Layout。所有子 view
///   位置在 `layoutSubviews()` 里手算，旋转/不同屏幕尺寸自动适配。
/// - **现代 Swift API**：闭包回调与 `async/await` 双入口。
/// - **可定制主题**：`Theme` 枚举支持 `.system`/`.light`/`.dark`/`.custom(Palette)`。
/// - **回传 `Date` 而非 String**：消费方拿原生类型，自己决定是否格式化。
///
/// ## 用法
///
/// ```swift
/// // closure 风格
/// FGDatePicker.present(in: view) { date in
///     print("user picked: \(date)")
/// }
///
/// // async/await 风格（iOS 16+）
/// if let date = await FGDatePicker.pick(in: view) {
///     print("user picked: \(date)")
/// }
/// ```
public final class FGDatePicker: UIView {

    // MARK: - Public types

    public typealias ConfirmHandler = (Date) -> Void
    public typealias CancelHandler = () -> Void

    // MARK: - Public state

    /// 当前生效的配置。修改后会触发一次 `layoutSubviews` 重排。
    public private(set) var configuration: Configuration

    /// 内嵌的 `UIDatePicker`，若需要细调（如设置 calendar）可直接拿到原生引用。
    public let datePicker: UIDatePicker = {
        let p = UIDatePicker()
        p.translatesAutoresizingMaskIntoConstraints = true   // 我们用 frame 布局
        return p
    }()

    // MARK: - Private subviews

    private let backdropButton = UIButton(type: .custom)
    private let cardView = UIView()
    private let cancelButton = UIButton(type: .system)
    private let confirmButton = UIButton(type: .system)
    private let separatorView = UIView()

    // MARK: - Callbacks

    private var onConfirm: ConfirmHandler?
    private var onCancel: CancelHandler?

    // MARK: - Layout 常量（frame 布局口径）

    private enum LayoutMetrics {
        static let cardHorizontalInset: CGFloat = 16
        static let cardBottomInset: CGFloat = 16    // 距离 safeArea 底部
        static let cardInternalPadding: CGFloat = 12
        static let buttonRowHeight: CGFloat = 48
        static let buttonGap: CGFloat = 12
        static let separatorThickness: CGFloat = 1.0 / UIScreen.main.scale
    }

    // MARK: - Init

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupViews()
        applyConfiguration()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) 不支持——本控件纯代码构造")
    }

    private func setupViews() {
        // 背景半透明遮罩，整个区域可点（dismissOnBackdropTap 控制是否真正响应）
        backdropButton.translatesAutoresizingMaskIntoConstraints = true
        backdropButton.addTarget(self, action: #selector(handleBackdropTap), for: .touchUpInside)
        addSubview(backdropButton)

        // 卡片
        cardView.translatesAutoresizingMaskIntoConstraints = true
        cardView.layer.masksToBounds = true
        addSubview(cardView)

        // UIDatePicker
        cardView.addSubview(datePicker)

        // 分隔线（位于 picker 与 buttons 之间）
        separatorView.translatesAutoresizingMaskIntoConstraints = true
        cardView.addSubview(separatorView)

        // 取消 / 确认按钮
        cancelButton.translatesAutoresizingMaskIntoConstraints = true
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        cancelButton.layer.masksToBounds = true
        cardView.addSubview(cancelButton)

        confirmButton.translatesAutoresizingMaskIntoConstraints = true
        confirmButton.addTarget(self, action: #selector(handleConfirm), for: .touchUpInside)
        confirmButton.layer.masksToBounds = true
        cardView.addSubview(confirmButton)
    }

    // MARK: - Configuration application

    /// 替换当前配置并立即重应用。
    public func update(configuration newValue: Configuration) {
        self.configuration = newValue
        applyConfiguration()
        setNeedsLayout()
    }

    private func applyConfiguration() {
        // UIDatePicker 参数
        datePicker.datePickerMode = configuration.mode
        datePicker.preferredDatePickerStyle = configuration.preferredStyle
        datePicker.date = configuration.initialDate
        datePicker.minimumDate = configuration.minimumDate
        datePicker.maximumDate = configuration.maximumDate
        datePicker.locale = configuration.locale
        datePicker.timeZone = configuration.timeZone

        // 按钮文案
        cancelButton.setTitle(configuration.cancelTitle, for: .normal)
        confirmButton.setTitle(configuration.confirmTitle, for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)

        applyTheme()
    }

    private func applyTheme() {
        let palette = configuration.theme.resolvedPalette(for: traitCollection)

        backdropButton.backgroundColor = palette.backdropColor
        cardView.backgroundColor = palette.cardBackgroundColor
        cardView.layer.cornerRadius = palette.cardCornerRadius

        cancelButton.setTitleColor(palette.cancelTextColor, for: .normal)
        cancelButton.backgroundColor = palette.cancelBackgroundColor
        cancelButton.layer.cornerRadius = palette.buttonCornerRadius

        confirmButton.setTitleColor(palette.confirmTextColor, for: .normal)
        confirmButton.backgroundColor = palette.confirmBackgroundColor
        confirmButton.layer.cornerRadius = palette.buttonCornerRadius

        separatorView.backgroundColor = palette.separatorColor ?? .clear
        separatorView.isHidden = (palette.separatorColor == nil)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle {
            applyTheme()
        }
    }

    // MARK: - Frame layout（核心：所有子 view 位置在这里手算）

    public override func layoutSubviews() {
        super.layoutSubviews()

        // 1. 背景遮罩铺满整个 host
        backdropButton.frame = bounds

        // 2. 卡片宽度
        let cardWidth = bounds.width - LayoutMetrics.cardHorizontalInset * 2
        guard cardWidth > 0 else { return }

        // 3. picker 高度——根据 style 给经验值
        let pickerHeight: CGFloat = {
            switch configuration.preferredStyle {
            case .wheels:
                return 216           // UIDatePicker .wheels 的标准高度
            case .compact, .inline:
                return 250           // .inline 大概 320 高，.compact 较矮；取折中
            case .automatic:
                return 216           // 系统自动选时，参照 wheels 留余量
            @unknown default:
                return 216
            }
        }()

        let cardHeight =
            LayoutMetrics.cardInternalPadding +
            pickerHeight +
            LayoutMetrics.cardInternalPadding +
            LayoutMetrics.separatorThickness +
            LayoutMetrics.cardInternalPadding +
            LayoutMetrics.buttonRowHeight +
            LayoutMetrics.cardInternalPadding

        // 4. 卡片置于底部（贴 safeArea）
        let safeBottom = safeAreaInsets.bottom
        let cardY = bounds.height - cardHeight - safeBottom - LayoutMetrics.cardBottomInset
        cardView.frame = CGRect(
            x: LayoutMetrics.cardHorizontalInset,
            y: cardY,
            width: cardWidth,
            height: cardHeight
        )

        // 5. 卡片内部 layout（坐标系是 cardView.bounds）
        let cardBounds = cardView.bounds
        let innerInset = LayoutMetrics.cardInternalPadding

        // 5a. UIDatePicker 顶部
        datePicker.frame = CGRect(
            x: innerInset,
            y: innerInset,
            width: cardBounds.width - innerInset * 2,
            height: pickerHeight
        )

        // 5b. 分隔线
        let separatorY = datePicker.frame.maxY + innerInset
        separatorView.frame = CGRect(
            x: innerInset,
            y: separatorY,
            width: cardBounds.width - innerInset * 2,
            height: LayoutMetrics.separatorThickness
        )

        // 5c. 按钮行
        let buttonY = separatorView.frame.maxY + innerInset
        let totalButtonsWidth = cardBounds.width - innerInset * 2 - LayoutMetrics.buttonGap
        let eachButtonWidth = totalButtonsWidth / 2

        cancelButton.frame = CGRect(
            x: innerInset,
            y: buttonY,
            width: eachButtonWidth,
            height: LayoutMetrics.buttonRowHeight
        )
        confirmButton.frame = CGRect(
            x: innerInset + eachButtonWidth + LayoutMetrics.buttonGap,
            y: buttonY,
            width: eachButtonWidth,
            height: LayoutMetrics.buttonRowHeight
        )
    }

    // MARK: - Actions

    @objc private func handleBackdropTap() {
        guard configuration.dismissOnBackdropTap else { return }
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
            self?.cleanupHandlers()
        }
    }

    @objc private func handleCancel() {
        dismiss(animated: true) { [weak self] in
            self?.onCancel?()
            self?.cleanupHandlers()
        }
    }

    @objc private func handleConfirm() {
        let picked = datePicker.date
        dismiss(animated: true) { [weak self] in
            self?.onConfirm?(picked)
            self?.cleanupHandlers()
        }
    }

    private func cleanupHandlers() {
        onConfirm = nil
        onCancel = nil
    }

    // MARK: - Presentation

    /// 把控件加进 host 并以"卡片由下而上滑入 + 背景渐显"动画弹出。
    private func show(in host: UIView) {
        frame = host.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.addSubview(self)
        layoutIfNeeded()

        // 动画初值
        backdropButton.alpha = 0
        let cardFinalY = cardView.frame.origin.y
        cardView.frame.origin.y = host.bounds.height

        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            options: [.curveEaseOut],
            animations: { [weak self] in
                self?.backdropButton.alpha = 1
                self?.cardView.frame.origin.y = cardFinalY
            }
        )
    }

    /// 反向动画并从 superview 移除。
    private func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard animated else {
            removeFromSuperview()
            completion?()
            return
        }
        let hostHeight = bounds.height
        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            options: [.curveEaseIn],
            animations: { [weak self] in
                self?.backdropButton.alpha = 0
                self?.cardView.frame.origin.y = hostHeight
            },
            completion: { [weak self] _ in
                self?.removeFromSuperview()
                completion?()
            }
        )
    }

    // MARK: - Public static convenience

    /// 在 `host` 上弹出一个日期选择器，回调用闭包形式。
    @discardableResult
    public static func present(
        in host: UIView,
        configuration: Configuration = .init(),
        onConfirm: @escaping ConfirmHandler,
        onCancel: CancelHandler? = nil
    ) -> FGDatePicker {
        let picker = FGDatePicker(configuration: configuration)
        picker.onConfirm = onConfirm
        picker.onCancel = onCancel
        picker.show(in: host)
        return picker
    }

    /// `async/await` 风格：在 `host` 上弹出，等待用户选择。
    /// - 用户点确认：返回所选 `Date`
    /// - 用户取消（或点击背景）：返回 `nil`
    public static func pick(
        in host: UIView,
        configuration: Configuration = .init()
    ) async -> Date? {
        await withCheckedContinuation { continuation in
            // 用一个标志位防止 confirm/cancel 被重复 resume（理论上不会，dismiss
            // 完成后 cleanupHandlers 会把闭包置 nil；这里再加一道保险）
            var hasResumed = false
            let resume: (Date?) -> Void = { date in
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: date)
            }
            DispatchQueue.main.async {
                _ = present(
                    in: host,
                    configuration: configuration,
                    onConfirm: { date in resume(date) },
                    onCancel: { resume(nil) }
                )
            }
        }
    }
}
