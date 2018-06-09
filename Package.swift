// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Donut",
    products: [
        .executable(name: "donut", targets: ["Donut"]),
        .library(name: "DonutKit", targets: ["DonutKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Carthage/ReactiveTask.git", from: "0.14.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.13.0"),
        .package(url: "https://github.com/thoughtbot/Curry.git", from: "4.0.1"),
    ],
    targets: [
        .target(name: "Donut", dependencies: ["ReactiveTask", "Commandant", "Curry", "DonutKit"]),
        .target(name: "DonutKit", dependencies: []),
        .testTarget(name: "DonutTests", dependencies: ["Donut"], path: "Tests"),
    ]
)
