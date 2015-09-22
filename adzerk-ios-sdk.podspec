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
  s.version          = "0.1"
  s.summary          = "iOS SDK for the Adzerk API"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                          iOS SDK for the Adzerk API. For more information see the Adzerk API docs at http://adzerk.com/api.
                       DESC

  s.homepage         = "http://adzerk.com"
  s.license          = 'Apache 2.0'
  s.author           = { "Ben Scheirman" => "ben@scheirman.com" }
  s.source           = { :git => "https://github.com/adzerk/adzerk-ios-sdk.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'AdzerkSDK/AdzerkSDK/**/*.swift'
  s.resource_bundles = {
    'adzerk-ios-sdk' => []
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Foundation'
end
