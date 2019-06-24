#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'aliyun'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'https://github.com/ygmpkk/flutter_aliyun'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Timothy' => 'ygmpkk@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'

  s.dependency 'Flutter'
  s.dependency 'FMDB', '>= 2.7.5'

  s.static_framework = true
  # s.swift_version = '4.2'
  s.ios.deployment_target = '8.0'
end

