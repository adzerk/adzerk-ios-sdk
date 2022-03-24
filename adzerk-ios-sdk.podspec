#
# Be sure to run `pod lib lint adzerk-ios-sdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "adzerk-ios-sdk"
  s.module_name      = "AdzerkSDK"
  s.version          = "2.2.0"
  s.summary          = "iOS SDK for the Adzerk API"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                          iOS SDK for the Adzerk API. For more information see the Adzerk API docs at https://adzerk.com/api.
                       DESC

  s.homepage         = "https://kevel.co"
  s.license          = 'Apache 2.0'
  s.author           = { "Ben Scheirman" => "ben@scheirman.com" }
  s.source           = { :git => "https://github.com/adzerk/adzerk-ios-sdk.git", :tag => s.version.to_s }

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.swift_versions = ['5.0']

  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'Foundation'
end
