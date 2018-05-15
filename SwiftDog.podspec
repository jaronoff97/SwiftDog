#
# Be sure to run `pod lib lint SwiftDog.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftDog'
  s.version          = '0.0.1'
  s.summary          = 'This is an (un)official swift library of the datadog API!'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        A Swift-y Datadog API!
                        Welcome to the datadog swift API! You can now send metrics and events from a device!
                        DESC
  s.homepage         = 'https://github.com/jaronoff97/SwiftDog'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jacob Aronoff' => 'jacobaronoff45@gmail.com' }
  s.source           = { :git => 'https://github.com/jaronoff97/SwiftDog.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/get_sw1fty'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SwiftDog/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SwiftDog' => ['SwiftDog/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'KeychainAccess', '~> 3.1'
end
