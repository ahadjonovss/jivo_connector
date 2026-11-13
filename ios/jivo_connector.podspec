Pod::Spec.new do |s|
  s.name             = 'jivo_connector'
  s.version          = '0.3.0'
  s.summary          = 'Jivo support chat for Flutter apps.'
  s.description      = 'A bridge to the native Jivo Mobile SDK.'
  s.homepage         = 'https://github.com/ahadjonovss/jivo_connector'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Samandar Ahadjonov'
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  # Comes from Jivo's own spec repo: the app's Podfile has to list
  # `source 'https://github.com/jivochat/cocoapods-repo'` next to the CDN.
  s.dependency 'JivoSDK', '~> 5.3'
  s.platform = :ios, '14.0'

  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
