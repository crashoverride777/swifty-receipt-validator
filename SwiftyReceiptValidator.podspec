Pod::Spec.new do |s|

s.name = 'SwiftyReceiptValidator'
s.version = '6.1.2'
s.license = 'MIT'
s.summary = 'A swift helper for in app purchase receipt validation.'

s.homepage = 'https://github.com/crashoverride777/swifty-receipt-validator'
s.social_media_url = 'http://twitter.com/overrideiactive'
s.authors = { 'DominikRingler' => 'overrideinteractive@icloud.com' }

s.swift_version = '5.0'
s.requires_arc = true
s.ios.deployment_target = '11.4'

s.source = {
    :git => 'https://github.com/crashoverride777/swifty-receipt-validator.git',
    :tag => s.version,
    :commit => 0922b9ec56b45c60d080f6e2bc7bbb1000f3a272
}

s.source_files = 'Sources/**/*.{swift}'
s.resource_bundle = { 'SwiftyReceiptValidator' => ['Sources/Resources/**/*.{strings}'] }

end
