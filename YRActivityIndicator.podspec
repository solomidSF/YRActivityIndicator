#
# Be sure to run `pod lib lint YRActivityIndicator.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'YRActivityIndicator'
  s.version          = '1.2.0'
  s.summary          = 'Fancy, highly customizable activity indicator that is using cubic Bezier for animation.'
  s.description      = <<-DESC
YRActivityIndicator - component for showing loading activity in your application.
Animation consist of items that rotate around imaginary circle in fixed time interval.
Items size are interpolated linearly between maxItemSize and minItemSize.
Each item has it’s own rotation speed value, that tells how fast it will make full rotation cycle from 0..2PI.
This value is specified by setting maxSpeed property and it’s interpolated linearly between items.
First item get’s max speed, last item gets regular speed (1.0).
Rotation angle is interpolated by using cubic Bezier curve.
https://www.youtube.com/watch?v=YJ3_vZMaG8E&feature=youtu.be
DESC
  s.homepage         = 'https://github.com/solomidSF/YRActivityIndicator'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Yurii Romanchenko' => 'yuri.boorie@gmail.com' }
  s.source           = { :git => 'https://github.com/solomidSF/YRActivityIndicator.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Source/YRActivityIndicator/*'
  
  # s.resource_bundles = {
  #   'YRActivityIndicator' => ['YRActivityIndicator/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
