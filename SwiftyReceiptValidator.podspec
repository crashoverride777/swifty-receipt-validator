#
#  Be sure to run `pod spec lint SwiftyReceiptValidator.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

s.name = 'SwiftyReceiptValidator'
s.version = '2.1.6'
s.license = 'MIT'
s.summary = 'A swift helper for in app purchase receipt validation.'

s.homepage = 'https://github.com/crashoverride777/swifty-receipt-validator'
s.social_media_url = 'http://twitter.com/overrideiactive'
s.authors = { 'DominikRingler' => 'dominikringler@icloud.com' }

s.requires_arc = true
s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }
s.ios.deployment_target = '9.3'

s.source = {
    :git => 'https://github.com/crashoverride777/swifty-receipt-validator.git',
    :tag => s.version
}

s.source_files = "SwiftyReceiptValidator/**/*.{swift}"

end
