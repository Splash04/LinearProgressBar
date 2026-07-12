Pod::Spec.new do |s|
s.name             = "LinearProgressBarMaterial"
s.version          = "2.0"
s.summary          = "LinearProgressBarMaterial"
s.description      = "A simple Linear Progress Bar for IOS (Swift 6), inspired by Material Design"
s.homepage         = "https://github.com/PhilippeBoisney/LinearProgressBar"
s.license          = 'MIT'
s.author           = { "PhilippeBoisney" => "phil.boisney@gmail.com" }
s.source           = { :git => "https://github.com/PhilippeBoisney/LinearProgressBar.git", :tag => s.version }
s.resource_bundle  = {"LinearProgressBarMaterial.privacy"=>"Pod/PrivacyInfo.xcprivacy"}
s.platform     = :ios, '13.0'
s.requires_arc = true
s.swift_version = '6.0'

# If more than one source file: https://guides.cocoapods.org/syntax/podspec.html#source_files
s.source_files = 'Pod/Classes/**/*'

end
