Pod::Spec.new do |s|
#name必须与文件名一致
s.name              = "TXVideoCallHelper"

#更新代码必须修改版本号
s.version           = "1.0.7"
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
ss.resources = 'TXVideoCallHelper/image/TXVideoCallHelper.bundle'
end

#TXVideoCallHelper/subView模块
s.subspec 'subView' do |ss|
ss.resources = 'TXVideoCallHelper/subView/*.xib'
ss.source_files = 'TXVideoCallHelper/subView/*.{h,m}'
ss.public_header_files = 'TXVideoCallHelper/subView/*.h'
end

#TXVideoCallHelper模块
s.subspec 'view' do |ss|
ss.resources = 'TXVideoCallHelper/view/*.xib'
ss.source_files = 'TXVideoCallHelper/view/*.{h,m}'
ss.public_header_files = 'TXVideoCallHelper/view/*.h'
ss.dependency 'TXVideoCallHelper/subView'
ss.dependency 'SDWebImage'
ss.dependency 'TXLiteAVSDK_Professional','8.1.9721'
ss.dependency 'Categorys','~> 1.0'
ss.dependency 'ZOEAlertView','~>1.5'
end

s.frameworks = 'Foundation', 'UIKit'

# s.ios.exclude_files = 'Classes/osx'
# s.osx.exclude_files = 'Classes/ios'
# s.public_header_files = 'Classes/**/*.h'

end
