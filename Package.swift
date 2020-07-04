// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "SwiftDog",
    platforms: [
       .iOS(.v8)
    ],
    products: [
        .library(name: "SwiftDog", targets: ["SwiftDog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "3.1.0")
    ],
    targets: [ .target(name: "SwiftDog", dependencies: ["KeychainAccess"], path: "SwiftDog/Classes") ]
)
