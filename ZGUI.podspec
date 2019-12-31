Pod::Spec.new do |s|
  s.name     = 'ZGUI'
  s.version  = '1.0.0'
  s.license  = { :type => "MIT", :file => "FILE_LICENSE" }
  s.summary  = '基础框架核心模块'
  s.homepage = 'https://github.com/ZGComponent-based/ZGUI.git'
  #s.social_media_url = 'https://xx'
  s.authors  = { 'zhaogang' => '372398930@qq.com' }
  s.source   = { :git => 'https://github.com/ZGComponent-based/ZGUI.git', :tag => s.version}
  s.requires_arc = true
  s.frameworks = 'UIKit','Foundation'
  s.dependency 'ZGNetwork'
  s.dependency 'Alamofire'
  s.dependency 'FLAnimatedImage'
  s.dependency 'FSCalendar'
  
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  
  s.source_files = 'ZGUI/**/*.swift'
  s.resources = ["ZGUI/**/*.{png,jpg,xib,storyboard,txt,gif}"]
end
