Pod::Spec.new do |s|

s.name = 'SwiftyReceiptValidator'
s.version = '4.0.1'
s.license = 'MIT'
s.summary = 'A swift helper for in app purchase receipt validation.'

s.homepage = 'https://github.com/crashoverride777/swifty-receipt-validator'
s.social_media_url = 'http://twitter.com/overrideiactive'
s.authors = { 'DominikRingler' => 'overrideinteractive@icloud.com' }

s.requires_arc = true
s.ios.deployment_target = '10.3'

s.source = {
    :git => 'https://github.com/crashoverride777/swifty-receipt-validator.git',
    :tag => s.version
}

s.source_files = "SwiftyReceiptValidator/**/*.{swift}"

end
