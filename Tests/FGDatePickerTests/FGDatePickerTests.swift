import XCTest
@testable import FGDatePicker
#if canImport(UIKit)
import UIKit

/// FGDatePicker 单元测试——只覆盖纯逻辑层（Configuration / Theme），
/// UI 真正交互效果靠 Demo 项目和 UI 测试来验证。
final class FGDatePickerTests: XCTestCase {

    // MARK: - Configuration defaults

    func test_configuration_default_values() {
        let config = FGDatePicker.Configuration()
        XCTAssertEqual(config.mode, .dateAndTime)
        XCTAssertNil(config.minimumDate)
        XCTAssertNil(config.maximumDate)
        XCTAssertNil(config.locale)
        XCTAssertNil(config.timeZone)
        XCTAssertEqual(config.preferredStyle, .wheels)
        XCTAssertEqual(config.confirmTitle, "确定")
        XCTAssertEqual(config.cancelTitle, "取消")
        XCTAssertTrue(config.dismissOnBackdropTap)
        XCTAssertEqual(config.animationDuration, 0.28, accuracy: 0.001)
    }

    // MARK: - Theme palette resolution

    func test_theme_system_resolves_to_light_in_light_mode() {
        let theme: FGDatePicker.Theme = .system
        let traits = UITraitCollection(userInterfaceStyle: .light)
        let palette = theme.resolvedPalette(for: traits)
        // light palette 的 backdrop alpha 是 0.35
        XCTAssertEqual(palette.backdropColor.cgColor.alpha, 0.35, accuracy: 0.001)
    }

    func test_theme_system_resolves_to_dark_in_dark_mode() {
        let theme: FGDatePicker.Theme = .system
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        let palette = theme.resolvedPalette(for: traits)
        // dark palette 的 backdrop alpha 是 0.55
        XCTAssertEqual(palette.backdropColor.cgColor.alpha, 0.55, accuracy: 0.001)
    }

    func test_theme_explicit_light_ignores_system_dark() {
        let theme: FGDatePicker.Theme = .light
        let darkTraits = UITraitCollection(userInterfaceStyle: .dark)
        let palette = theme.resolvedPalette(for: darkTraits)
        XCTAssertEqual(palette.backdropColor.cgColor.alpha, 0.35, accuracy: 0.001)
    }

    func test_theme_explicit_dark_ignores_system_light() {
        let theme: FGDatePicker.Theme = .dark
        let lightTraits = UITraitCollection(userInterfaceStyle: .light)
        let palette = theme.resolvedPalette(for: lightTraits)
        XCTAssertEqual(palette.backdropColor.cgColor.alpha, 0.55, accuracy: 0.001)
    }

    func test_theme_custom_palette_passes_through() {
        var custom = FGDatePicker.Palette.light
        custom.cardCornerRadius = 99
        let theme: FGDatePicker.Theme = .custom(custom)
        let resolved = theme.resolvedPalette(for: UITraitCollection())
        XCTAssertEqual(resolved.cardCornerRadius, 99)
    }

    // MARK: - View construction smoke tests

    @MainActor
    func test_picker_can_be_constructed_with_default_config() {
        let picker = FGDatePicker(configuration: .init())
        XCTAssertEqual(picker.configuration.mode, .dateAndTime)
        XCTAssertEqual(picker.datePicker.datePickerMode, .dateAndTime)
    }

    @MainActor
    func test_picker_applies_initial_date() {
        var config = FGDatePicker.Configuration()
        let target = Date(timeIntervalSince1970: 1_700_000_000)
        config.initialDate = target
        let picker = FGDatePicker(configuration: config)
        XCTAssertEqual(picker.datePicker.date.timeIntervalSince1970, target.timeIntervalSince1970, accuracy: 1.0)
    }

    @MainActor
    func test_picker_update_replaces_configuration() {
        let picker = FGDatePicker(configuration: .init())
        var newConfig = FGDatePicker.Configuration()
        newConfig.confirmTitle = "OK"
        newConfig.cancelTitle = "Nope"
        picker.update(configuration: newConfig)
        XCTAssertEqual(picker.configuration.confirmTitle, "OK")
        XCTAssertEqual(picker.configuration.cancelTitle, "Nope")
    }

    @MainActor
    func test_picker_layout_with_fixed_host_bounds() {
        let host = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 812))
        let picker = FGDatePicker(configuration: .init())
        picker.frame = host.bounds
        host.addSubview(picker)
        picker.layoutIfNeeded()

        // 卡片宽度应为 host.width - 2 * 16
        let expectedCardWidth: CGFloat = 375 - 32
        // 通过 backdropButton 的 frame 验证（铺满），间接验证 layoutSubviews 跑过
        XCTAssertEqual(picker.subviews.count, 2) // backdropButton + cardView

        // 找到 cardView（非 backdrop）
        let cardView = picker.subviews.first { !($0 is UIButton) }
        XCTAssertNotNil(cardView)
        let actualCardWidth = cardView?.frame.width ?? 0
        XCTAssertEqual(actualCardWidth, expectedCardWidth, accuracy: 0.5)
    }
}
#endif
