Pod::Spec.new do |s|

s.name = 'SwiftyReceiptValidator'
s.version = '6.2.0'
s.license = 'MIT'
s.summary = 'A Swift library for in app purchase receipt validation.'

s.homepage = 'https://github.com/crashoverride777/swifty-receipt-validator'
s.authors = { 'Dominik Ringler' => 'overrideinteractive@icloud.com' }

s.swift_version = '5.0'
s.requires_arc = true
s.ios.deployment_target = '11.4'

s.source = {
    :git => 'https://github.com/crashoverride777/swifty-receipt-validator.git',
    :tag => s.version
}

s.source_files = 'Sources/**/*.{swift}'

end
