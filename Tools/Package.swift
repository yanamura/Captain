// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/apple/swift-format", .branch("main")),
        .package(url: "https://github.com/yanamura/Captain", .branch("master"))
    ]
)