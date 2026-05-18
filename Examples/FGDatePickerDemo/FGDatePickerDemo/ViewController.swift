import UIKit
import FGDatePicker

/// FGDatePicker 演示 ViewController。
///
/// 提供 4 个入口按钮，对照展示 API：
///
/// 1. 默认配置（dateAndTime + wheels + system theme）
/// 2. 仅日期 + dark theme
/// 3. async/await 风格
/// 4. 自定义 min/max + 自定义 palette
///
/// 用 frame 布局——遵守 [[feedback-ios-frame-layout]] 偏好（不用 Auto Layout）。
final class ViewController: UIViewController {

    private let titleLabel = UILabel()
    private let resultLabel = UILabel()

    private let basicButton = UIButton(type: .system)
    private let darkButton = UIButton(type: .system)
    private let asyncButton = UIButton(type: .system)
    private let customButton = UIButton(type: .system)

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        titleLabel.text = "FGDatePicker"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)

        resultLabel.text = "尚未选择日期"
        resultLabel.font = .systemFont(ofSize: 14, weight: .regular)
        resultLabel.textColor = .secondaryLabel
        resultLabel.textAlignment = .center
        resultLabel.numberOfLines = 0
        view.addSubview(resultLabel)

        configureButton(basicButton, title: "1) 默认配置（system + wheels + dateAndTime）",
                        action: #selector(showBasic))
        configureButton(darkButton, title: "2) 仅日期 + dark theme",
                        action: #selector(showDarkDateOnly))
        configureButton(asyncButton, title: "3) async/await 风格",
                        action: #selector(showAsync))
        configureButton(customButton, title: "4) 自定义 min/max + custom palette",
                        action: #selector(showCustom))
    }

    // MARK: - Layout（纯 frame）

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let safe = view.safeAreaInsets
        let width = view.bounds.width

        titleLabel.frame = CGRect(
            x: 16, y: safe.top + 16,
            width: width - 32, height: 36
        )

        resultLabel.frame = CGRect(
            x: 16, y: titleLabel.frame.maxY + 12,
            width: width - 32, height: 60
        )

        let buttons = [basicButton, darkButton, asyncButton, customButton]
        var y = resultLabel.frame.maxY + 24
        for button in buttons {
            button.frame = CGRect(
                x: 16, y: y,
                width: width - 32, height: 52
            )
            y += 60
        }
    }

    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = .init(top: 8, left: 12, bottom: 8, right: 12)
        button.addTarget(self, action: action, for: .touchUpInside)
        view.addSubview(button)
    }

    // MARK: - Actions

    @objc private func showBasic() {
        FGDatePicker.present(in: view) { [weak self] date in
            self?.applyResult(prefix: "(closure 默认)", date: date)
        }
    }

    @objc private func showDarkDateOnly() {
        var config = FGDatePicker.Configuration()
        config.mode = .date
        config.theme = .dark
        FGDatePicker.present(
            in: view,
            configuration: config,
            onConfirm: { [weak self] date in
                self?.applyResult(prefix: "(closure dark + .date)", date: date)
            },
            onCancel: { [weak self] in
                self?.resultLabel.text = "已取消（dark 模式）"
            }
        )
    }

    @objc private func showAsync() {
        Task { [weak self] in
            guard let self else { return }
            if let picked = await FGDatePicker.pick(in: view) {
                applyResult(prefix: "(async/await)", date: picked)
            } else {
                resultLabel.text = "已取消（async/await）"
            }
        }
    }

    @objc private func showCustom() {
        var config = FGDatePicker.Configuration()
        config.mode = .dateAndTime

        // 限制可选范围在今天前后 7 天
        let now = Date()
        config.initialDate = now
        config.minimumDate = now.addingTimeInterval(-7 * 24 * 3600)
        config.maximumDate = now.addingTimeInterval(7 * 24 * 3600)
        config.confirmTitle = "Pick"
        config.cancelTitle = "Skip"

        // 自定义粉紫 palette
        var palette = FGDatePicker.Palette.light
        palette.cardCornerRadius = 22
        palette.confirmBackgroundColor = UIColor(red: 0.95, green: 0.40, blue: 0.65, alpha: 1)
        palette.confirmTextColor = .white
        palette.cancelBackgroundColor = UIColor(white: 0.95, alpha: 1)
        palette.buttonCornerRadius = 18
        config.theme = .custom(palette)

        FGDatePicker.present(
            in: view,
            configuration: config,
            onConfirm: { [weak self] date in
                self?.applyResult(prefix: "(custom palette ±7 天)", date: date)
            }
        )
    }

    private func applyResult(prefix: String, date: Date) {
        let formatted = dateFormatter.string(from: date)
        resultLabel.text = "\(prefix)\n选择：\(formatted)"
    }
}
