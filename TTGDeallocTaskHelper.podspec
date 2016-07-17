Pod::Spec.new do |s|
  s.name             = 'TTGDeallocTaskHelper'
  s.version          = '0.1.0'
  s.summary          = 'NSObject Category to add callback tasks when object dealloc.'

  s.description      = <<-DESC
                       NSObject Category to add callback tasks when object dealloc.
                       DESC

  s.homepage         = 'https://github.com/zekunyan/TTGDeallocTaskHelper'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zekunyan' => 'zekunyan@163.com' }
  s.source           = { :git => 'https://github.com/zekunyan/TTGDeallocTaskHelper.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zorro_tutuge'

  s.ios.deployment_target = '6.0'
  s.platform = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'TTGDeallocTaskHelper/Classes/**/*'
  s.public_header_files = 'Pod/Classes/**/*.h'

  s.frameworks = 'UIKit', 'CoreFoundation'
end
