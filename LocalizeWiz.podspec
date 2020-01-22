#
# Be sure to run `pod lib lint LocalizeWiz.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                = 'LocalizeWiz'
  s.version             = '0.1.0'
  s.summary             = 'Real time localizations for mobile apps.'
  s.swift_version       = '5.0'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description         = <<-DESC
LocalizeWiz is a cloud based localization platform that automates the localization process. Localize all the content in your apps with just a few lines of code. LocalizeWiz also allows you to keep your localizations in sync and update text on the fly without having to resubmit or repackage your app.
                       DESC

  s.homepage            = 'https://github.com/Inn0vative1'
  # s.screenshots       = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license             = { :type => 'MIT', :file => 'LICENSE' }
  s.author              = { 'Inn0vative1' => 'john.warmann@gmail.com' }
  s.source              = { :git => 'https://github.com/Inn0vative1/LocalizeWiz.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target = '10.13'

  s.source_files        = 'LocalizeWiz/Sources/Common/**/*.swift'
  s.ios.source_files    = 'LocalizeWiz/Sources/ios/**/*.swift'
  s.osx.source_files    = 'LocalizeWiz/Sources/osx/**/*.swift'
  
  # s.resource_bundles  = {
  #   'LocalizeWiz' => ['LocalizeWiz/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.ios.framework  = 'UIKit'
  s.osx.framework  = 'AppKit'
end
