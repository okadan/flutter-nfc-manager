#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint nfc_manager.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'nfc_manager'
  s.version          = '0.0.1'
  s.summary          = 'Flutter NFC Manager'
  s.description      = <<-DESC
A Flutter plugin providing access to NFC features on iOS.
                       DESC
  s.homepage         = 'https://github.com/okadan/flutter-nfc-manager'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'okadan' => '46291090+okadan@users.noreply.github.com' }
  s.source           = { :path => '.' }
  s.source_files = 'nfc_manager/Sources/nfc_manager/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
