#
# Be sure to run `pod lib lint LocalizeWiz.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                = 'LocalizeWiz'
  s.version             = '0.1.0-beta'
  s.summary             = 'Real time app localization.'
  s.swift_version       = '5.0'

  s.description         = <<-DESC
LocalizeWiz is a cloud based localization platform that automates the localization process. Localize all the content in your apps with just a few lines of code. LocalizeWiz also allows you to keep your localizations in sync and update text on the fly without having to create a new version of your app.
                       DESC

  s.homepage            = 'https://localizewiz.com'
  # s.screenshots       = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { 'LocalizeWiz' => 'https://localizewiz.com' }
  s.source              = { :git => 'https://github.com/LocalizeWiz/localizewiz-ios-sdk.git', :tag => s.version.to_s }
  s.requires_arc        = true
  s.module_name         = 'LocalizeWiz'
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'
  s.osx.deployment_target = '10.13'

  s.source_files        = 'LocalizeWiz/Sources/Common/**/*.swift'
  s.ios.source_files    = 'LocalizeWiz/Sources/Common/**/*.swift', 'LocalizeWiz/Sources/ios/**/*.swift'
  s.tvos.source_files   = 'LocalizeWiz/Sources/Common/**/*.swift', 'LocalizeWiz/Sources/ios/**/*.swift'
  s.osx.source_files    = 'LocalizeWiz/Sources/Common/**/*.swift', 'LocalizeWiz/Sources/osx/**/*.swift'
  
  # s.resource_bundles  = {
  #   'LocalizeWiz' => ['LocalizeWiz/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.framework  = 'UIKit'
  s.osx.framework  = 'AppKit'
end
