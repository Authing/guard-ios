#
#  Be sure to run `pod spec lint Guard-iOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name              = 'Guard-iOS'
    s.version           = '1.3.0'
    s.summary           = 'Guard 采用了全新的 语义化编程模型，可以快速构建自定义风格的认证流程。'
    s.homepage          = 'https://github.com/Authing/guard-ios'

    s.author            = { "jnMars" => "563438383@qq.com" }
    s.license = { :type => "MIT", :text => "MIT License" }

    s.platform          = :ios
    # change the source location
    s.source            = { :http => 'https://github.com/Authing/guard-ios/releases/download/1.3.0/Guard.xcframework.zip' }
    s.ios.deployment_target = '11.0'
    s.ios.vendored_frameworks = 'Guard.xcframework'
    
end
