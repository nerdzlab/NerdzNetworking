

Pod::Spec.new do |s|
  s.name             = 'NerdzNetworking'
  s.version          = '1.4.5'
  s.summary          = 'A wrapper on top of URLSession and URLRequest to simplify creating and managing network requests'
  s.homepage         = 'https://github.com/nerdzlab/NerdzNetworking'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NerdzLab' => 'supernerd@nerdzlab.com' }
  s.source           = { :git => 'https://github.com/nerdzlab/NerdzNetworking.git', :tag => s.version }
  s.social_media_url = 'https://nerdzlab.com'
  s.ios.deployment_target = '12.0'
  s.swift_versions = ['5.0']
  s.source_files = 'Sources/**/*'
  
  s.dependency 'TrustKit', '~> 2.0.0'
end
