#
# Be sure to run `pod lib lint NerdzNetworking.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NerdzNetworking'
  s.version          = '0.1.0'
  s.summary          = 'A wrapper on top of URLSession and URLRequest to simplify creating and managing network requests'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
NerdzNetworking library allows easily create and execute requests as well as setupping configurations.
                       DESC

  s.homepage         = 'https://github.com/nerdzlab/NerdzNetworking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NerdzLab' => 'supernerd@nerdzlab.com' }
  s.source           = { :git => 'https://github.com/nerdzlab/NerdzNetworking.git', :tag => s.version.to_s }
  s.social_media_url = 'https://nerdzlab.com'

  s.ios.deployment_target = '8.0'
  s.swift_versions = '5.0'

  s.source_files = 'Sources/**/*'
  
  # s.resource_bundles = {
  #   'NerdzNetworking' => ['NerdzNetworking/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
