Pod::Spec.new do |s|
  s.name             = "BUKPhotoBrowser"
  s.version          = "1.1.0"
  s.summary          = "A photo browser library."
  s.description      = <<-DESC
                       BUKPhotoBrowser is used to view large photos. You can pinch to scale the photo size,
                       tap to dismiss browser, pan to switch photo and so on. You can alse custom toolbar
                       for special usage.
                       DESC
  s.homepage         = 'https://github.com/iException/BUKPhotoBrowser'
  s.license          = 'MIT'
  s.author           = { "hyice" => "hy_ice719@163.com" }
  s.source           = { :git => "https://github.com/iException/BUKPhotoBrowser.git", :tag => "v#{s.version.to_s}" }
  s.platform         = :ios, '8.0'
  s.requires_arc     = true
  s.source_files     = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BUKPhotoBrowser' => ['Pod/Assets/*.png']
  }
  s.dependency 'SDWebImage', '~> 3.7'
end
