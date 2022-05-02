Pod::Spec.new do |s|

s.name = 'SwiftyReceiptValidator'
s.version = '6.5.0'
s.license = 'MIT'
s.summary = 'A Swift library for in app purchase receipt validation.'

s.homepage = 'https://github.com/crashoverride777/swifty-receipt-validator'
s.authors = { 'Dominik Ringler' => 'overrideinteractive@icloud.com' }

s.ios.deployment_target = '12.0'
s.tvos.deployment_target = '12.0'
s.osx.deployment_target = '10.15'

s.swift_versions = ['5.3', '5.4', '5.5', '5.6']
s.requires_arc = true

s.source = {
    :git => 'https://github.com/crashoverride777/swifty-receipt-validator.git',
    :tag => s.version
}

s.source_files = 'Sources/**/*.{swift}'

end
