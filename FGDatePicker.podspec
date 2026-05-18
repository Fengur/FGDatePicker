Pod::Spec.new do |s|
  s.name             = 'FGDatePicker'
  s.version          = '1.0.0'
  s.summary          = '轻量、纯代码、零依赖的 iOS 日期选择弹窗组件。'
  s.description      = <<-DESC
                       FGDatePicker 是 UIDatePicker 的 modal 包装组件：半透明
                       遮罩 + 居中卡片（slide-up 动画），支持闭包与 async/await
                       两种回调风格，可定制主题（light/dark/custom palette）。

                       内部纯 frame 布局，不依赖 Auto Layout / SnapKit。iOS 16+。
                       DESC
  s.homepage         = 'https://github.com/Fengur/FGDatePicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fengur' => 'noreply@github.com' }
  s.source           = { :git => 'https://github.com/Fengur/FGDatePicker.git', :tag => s.version.to_s }

  s.ios.deployment_target = '16.0'
  s.swift_versions        = ['5.9']

  s.source_files = 'Sources/FGDatePicker/**/*.swift'
  s.frameworks   = 'UIKit'
end
