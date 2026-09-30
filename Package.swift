// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CookingImprovementShared",
    platforms: [.iOS(.v17)],
    products: [.library(name: "CookingImprovementShared", targets: ["CookingImprovementShared"])],
    targets: [
        .target(name: "CookingImprovementShared"),
        .testTarget(name: "CookingImprovementSharedTests", dependencies: ["CookingImprovementShared"])
    ]
)
