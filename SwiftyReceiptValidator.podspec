Pod::Spec.new do |s|

s.name = 'SwiftyReceiptValidator'
s.version = '3.1.0'
s.license = 'MIT'
s.summary = 'A swift helper for in app purchase receipt validation.'

s.homepage = 'https://github.com/crashoverride777/swifty-receipt-validator'
s.social_media_url = 'http://twitter.com/overrideiactive'
s.authors = { 'DominikRingler' => 'overrideinteractive@icloud.com' }

s.requires_arc = true
s.ios.deployment_target = '9.3'

s.source = {
    :git => 'https://github.com/crashoverride777/swifty-receipt-validator.git',
    :tag => s.version
}

s.source_files = "SwiftyReceiptValidator/**/*.{swift}"

end
