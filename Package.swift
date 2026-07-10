// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Kanban Board",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Kanban Board", targets: ["Kanban Board"])
    ],
    targets: [
        .target(name: "Kanban Board", path: "Sources")
    ]
)
