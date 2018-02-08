Pod::Spec.new do |s|
  s.name             = 'AMGifPicker'
  s.version          = '0.1.4'
  s.summary          = 'Gif picker component'
 
  s.description      = <<-DESC
Gif picker component based on Giphy API.
                       DESC
 
  s.homepage         = 'https://github.com/ProgiiX/AMGifPicker'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alexander Momotiuk' => 'sashamomotyk@gmail.com' }
  s.source           = { :git => 'https://github.com/ProgiiX/AMGifPicker.git', :tag => s.version.to_s }
 
  s.ios.deployment_target = '9.0'
  s.source_files = 'AMGifPicker/Source/**/*'

  s.framework = "UIKit"
  s.dependency 'Alamofire'
  s.dependency 'GiphyCoreSDK'
  s.dependency 'Cache'
  s.dependency 'FLAnimatedImage'
 
end