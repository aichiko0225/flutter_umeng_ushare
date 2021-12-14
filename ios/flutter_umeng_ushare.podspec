#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_umeng_ushare.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_umeng_ushare'
  s.version          = '1.0.1'
  s.summary          = '友盟分享插件 for Flutter'
  s.description      = <<-DESC
友盟分享插件 for Flutter
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '9.0'

  # 友盟分享基础库
  s.dependency 'UMCommon'
  s.dependency 'UMDevice'
  s.dependency 'UMCCommonLog'

  # U-Share SDK UI模块（分享面板，建议添加）
  s.dependency 'UMShare/UI'

  #集成微信(完整版14.4M)
  # s.dependency 'UMShare/Social/WeChat'
  
  #集成QQ/QZone/TIM(完整版7.6M)
  # s.dependency 'UMShare/Social/QQ'
  
  #集成新浪微博(完整版25.3M)
  # s.dependency 'UMShare/Social/Sina'
  
  #集成新浪微博(精简版1M)
  # s.dependency 'UMShare/Social/ReducedSina'
  
  #集成钉钉
  # s.dependency 'UMShare/Social/DingDing'
  
  #企业微信
  # s.dependency 'UMShare/Social/WeChatWork'

  s.static_framework = true

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
