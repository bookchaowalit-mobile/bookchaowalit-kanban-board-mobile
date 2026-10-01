// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "KanbanBoard",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "KanbanBoardCore", targets: ["KanbanBoardCore"]),
        .library(name: "KanbanBoardUI", targets: ["KanbanBoardUI"]),
    ],
    targets: [
        // Foundation-only domain logic; no SwiftUI so it also builds on Linux.
        .target(name: "KanbanBoardCore", path: "Sources/KanbanBoardCore"),
        .target(name: "KanbanBoardUI", dependencies: ["KanbanBoardCore"], path: "Sources/KanbanBoardUI"),
        .testTarget(name: "KanbanBoardCoreTests", dependencies: ["KanbanBoardCore"], path: "Tests/KanbanBoardCoreTests"),
    ]
)
