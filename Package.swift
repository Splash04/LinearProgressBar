// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LinearProgressBarMaterial",
    platforms: [
        .iOS(.v13)
    ],
    
    products: [
        .library(name: "LinearProgressBarMaterial", targets: ["LinearProgressBarMaterial"])
    ],
    
    targets: [
        .target(name: "LinearProgressBarMaterial", path: "Pod", resources: [.process("PrivacyInfo.xcprivacy")])
    ]
)
