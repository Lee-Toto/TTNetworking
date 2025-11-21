#
# Be sure to run `pod lib lint TTNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TTNetworking'
  s.version          = '0.1.0'
  s.summary          = 'A short description of TTNetworking.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Lee-Toto/TTNetworking'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lee-Toto' => 'daly97@126.com' }
  s.source           = { :git => 'https://github.com/Lee-Toto/TTNetworking.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.swift_version = '5.0'
  s.ios.deployment_target = '12.0'
  
  s.default_subspec = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.source_files = 'TTNetworking/Classes/Core/**/*'
  end
  
  s.subspec 'Captcha' do |ss|
    ss.dependency 'CryptoSwift'
    ss.dependency 'TTNetworking/Core'
    ss.source_files = 'TTNetworking/Classes/Captcha/**/*'
    ss.resource_bundles = {
      'TTNetworking' => ['TTNetworking/Assets/*.xcassets']
    }
  end
  
  s.subspec 'ObjectMapper' do |ss|
    ss.dependency 'TTNetworking/Core'
    ss.source_files = 'TTNetworking/Classes/ObjectMapper/**/*'
    ss.dependency 'ObjectMapper'
  end
  
  s.subspec 'SmartCodable' do |ss|
    ss.dependency 'TTNetworking/Core'
    ss.source_files = 'TTNetworking/Classes/SmartCodable/**/*'
    ss.dependency 'SmartCodable'
  end
  
  s.dependency 'Moya/RxSwift'
  s.dependency 'RxRelay'
  s.dependency 'CryptoSwift'
  
  s.static_framework = true
end
