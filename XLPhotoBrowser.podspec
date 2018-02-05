Pod::Spec.new do |s|
  s.name         = "XLPhotoBrowser"
  s.version      = "0.0.1"
  s.platform     = :ios, '8.0' 
  s.summary      = "图片浏览,类似于微信朋友圈中图片浏览器功能"
  s.homepage     = "https://github.com/weskhen/XLPhotoBrowser"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "wesk 痕" => "wujian516411567@163.com" }
  s.source       = { :git => "https://github.com/weskhen/XLPhotoBrowser.git", :tag => "0.0.1" }
  s.source_files = 'XLPhotoBrowser/XLPhotoBrowser/*.{h,m}'  
  s.public_header_files = 'XLPhotoBrowser/XLPhotoBrowser/**/*.h'   #公开头文件地址
  s.requires_arc = true
  s.dependency 'SDWebImage', '~> 3.0'
  s.dependency 'Masonry', '~> 1.0.2'
end
