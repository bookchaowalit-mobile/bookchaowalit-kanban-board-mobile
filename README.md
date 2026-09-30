# Kanban Board — Mobile

SwiftUI app for **Kanban Board** — organise tasks in columns with work-in-progress limits.

Part of [Chaowalit Greepoke](https://bookchaowalit.com)'s 101 Portfolio Projects.

## Status

This is a Swift package, not yet a shippable app:

- `Sources/KanbanBoardCore` — Foundation-only domain logic, unit-tested in
  `Tests/KanbanBoardCoreTests` (XCTest).
- `Sources/KanbanBoardUI` — SwiftUI tab shell (Home / Explore / Profile). It does not
  use `KanbanBoardCore` yet, and there is no Xcode app target (`@main`) yet.

The code has **not been compiled outside CI** (it was written without a Swift
toolchain); the macOS CI job is the first real build. See
[docs/UPGRADE-PLAN.md](docs/UPGRADE-PLAN.md).

## Core features (`KanbanBoardCore`)

- Board / column / card model (priority, due date, labels); standard To Do → In Progress (WIP 3) → Done board
- Add with title trimming and validation; move between columns with clamped positions; remove
- WIP limits enforced when moving into a full column (reordering inside it stays allowed)
- Column sort: priority, then earliest due date (undated last), then title
- Search across titles and labels, overdue list (excluding Done), completion progress

## Tech Stack

- **UI:** SwiftUI (iOS 17+ / macOS 14+)
- **Language:** Swift 5.10
- **Tests:** XCTest via SwiftPM

## Getting Started

```bash
swift build
swift test          # runs KanbanBoardCoreTests
open Package.swift  # opens in Xcode 15+
```

CI (`.github/workflows/build.yml`, macOS 14) runs `swift build` and
`swift test`; failures fail the workflow.

## Related

- **Frontend:** [bookchaowalit-website/kanban-board-frontend](https://github.com/bookchaowalit-website/bookchaowalit-kanban-board-frontend)
- **Portfolio:** [bookchaowalit.com](https://bookchaowalit.com)

## License

MIT
