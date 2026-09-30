# Upgrade plan

## Current state

Score: 3/10 (was 1/10) — domain logic + XCTest suite and honest CI exist, but
nothing has been compiled yet (no Swift toolchain was available when this was
written) and the UI is still a placeholder.

## Backlog

- P0: Confirm the macOS CI job is green (`swift build` + `swift test`); fix any
  compile errors it reports first.
- P0: Add an Xcode app target (`@main`) that hosts `KanbanBoardUI`, and build screens on
  top of `KanbanBoardCore` (an `@Observable` model wrapping the core API).
- P1: Drag-and-drop board UI (`draggable` / `dropDestination`) bound to `Board`.
- P1: Persist boards with SwiftData or JSON in the app container.
- P2: Add a Linux CI job that runs `swift test --filter KanbanBoardCoreTests` after
  making the UI target conditional, to keep the core portable.

## Done in this pass (pass 1)

- Split the package into `KanbanBoardCore` (Foundation-only logic), `KanbanBoardUI` (existing
  SwiftUI shell) and `KanbanBoardCoreTests` (5 XCTest cases).
- Removed `@main` from the library target (it belongs in an app target).
- CI: removed `|| echo` / `|| true` so build and test failures are visible.
- README now states what is verified and what is not.
- New Swift sources were syntax-checked with tree-sitter-swift only.

## Done in this pass (pass 2)

- Static compile review only (no Swift toolchain in this environment): read every
  source and test file for type/API errors (access levels across modules, tuple
  labels, closure destructuring, result-builder declarations, macOS 14/iOS 17
  API availability, `@testable` usage). No compile errors found; nothing changed.
  All files also parse cleanly with tree-sitter-swift.
- The P0 item (confirm the macOS `swift build` / `swift test` CI job is green) stays open.
