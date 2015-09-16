#
# Be sure to run `pod lib lint BUKPhotoBrowser.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BUKPhotoBrowser"
  s.version          = "1.0.2"
  s.summary          = "A photo browser library."
  s.description      = <<-DESC
                       BUKPhotoBrowser is used to view large photos. You can pinch to scale the photo size,
                       tap to dismiss browser, pan to switch photo and so on. You can alse custom toolbar
                       for special usage.
                       DESC
  s.homepage         = "https://github.com/iException/BUKPhotoBrowser"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "hyice" => "hy_ice719@163.com" }
  s.source           = { :git => "https://github.com/iException/BUKPhotoBrowser.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BUKPhotoBrowser' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SDWebImage', '3.7.2'
end
