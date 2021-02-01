Pod::Spec.new do |s|
#name必须与文件名一致
s.name              = "TXVideoCallHelper"

#更新代码必须修改版本号
s.version           = "1.0.1"
s.summary           = "It is a TXVideoCallHelper used on iOS, which implement by Objective-C"
s.description       = <<-DESC
It is a TXVideoCallHelper used on iOS, which implement by Objective-C.
DESC
s.homepage          = "https://github.com/ChenZhenChun/TXVideoCallHelper"
s.license           = 'MIT'
s.author            = { "ChenZhenChun" => "346891964@qq.com" }

#submodules 是否支持子模块
s.source            = { :git => "https://github.com/ChenZhenChun/TXVideoCallHelper.git", :tag => s.version, :submodules => true}
s.platform          = :ios, '9.0'
s.requires_arc = true

#source_files路径是相对podspec文件的路径
#image模块
s.subspec 'image' do |ss|
ss.resources = 'TXVideoCallHelper/image/*.png'
end

s.subspec 'subView' do |ss|
ss.source_files = 'TXVideoCallHelper/view/subView/*.{h,m,xib}'
ss.public_header_files = 'TXVideoCallHelper/view/subView/*.h'
end

#TXVideoCallHelper模块
s.subspec 'view' do |ss|
ss.source_files = 'TXVideoCallHelper/view/*.{h,m,xib}'
ss.public_header_files = 'TXVideoCallHelper/view/*.h'
ss.dependency 'SDWebImage','~> 5.0'
ss.dependency 'TXLiteAVSDK_Professional','8.1.9721'
ss.dependency 'Categorys','~> 1.0'
end





s.frameworks = 'Foundation', 'UIKit'

# s.ios.exclude_files = 'Classes/osx'
# s.osx.exclude_files = 'Classes/ios'
# s.public_header_files = 'Classes/**/*.h'

end
