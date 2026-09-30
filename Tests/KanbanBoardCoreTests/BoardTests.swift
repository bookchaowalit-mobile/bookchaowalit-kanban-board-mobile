import XCTest
@testable import KanbanBoardCore

final class BoardTests: XCTestCase {
    private var board = Board.standard()
    private var todo: UUID { board.columns[0].id }
    private var doing: UUID { board.columns[1].id }
    private var done: UUID { board.columns[2].id }

    override func setUp() {
        super.setUp()
        board = Board.standard()
    }

    func testAddTrimsAndRejectsEmptyTitles() throws {
        let card = try board.addCard(Card(title: "  Write tests \n"), to: todo)
        XCTAssertEqual(card.title, "Write tests")
        XCTAssertThrowsError(try board.addCard(Card(title: "   "), to: todo)) { XCTAssertEqual($0 as? BoardError, .emptyTitle) }
        XCTAssertThrowsError(try board.addCard(Card(title: "x"), to: UUID())) { XCTAssertEqual($0 as? BoardError, .columnNotFound) }
    }

    func testWipLimitBlocksMovesIntoFullColumn() throws {
        var ids: [UUID] = []
        for i in 0..<4 { ids.append(try board.addCard(Card(title: "Task \(i)"), to: todo).id) }
        for id in ids.prefix(3) { try board.move(card: id, to: doing, at: 0) }
        XCTAssertTrue(board.columns[1].isAtLimit)
        XCTAssertThrowsError(try board.move(card: ids[3], to: doing, at: 0)) {
            XCTAssertEqual($0 as? BoardError, .wipLimitReached(column: "In Progress", limit: 3))
        }
        // Reordering inside a full column is still allowed.
        try board.move(card: ids[0], to: doing, at: 0)
        XCTAssertEqual(board.columns[1].cards.first?.id, ids[0])
    }

    func testMoveClampsPosition() throws {
        let a = try board.addCard(Card(title: "A"), to: todo)
        let b = try board.addCard(Card(title: "B"), to: todo)
        try board.move(card: a.id, to: todo, at: 99)
        XCTAssertEqual(board.columns[0].cards.map(\.title), ["B", "A"])
        try board.move(card: a.id, to: done, at: -5)
        XCTAssertEqual(board.columns[2].cards.map(\.id), [a.id])
        XCTAssertThrowsError(try board.move(card: UUID(), to: done, at: 0))
        try board.removeCard(b.id)
        XCTAssertTrue(board.columns[0].cards.isEmpty)
    }

    func testSortByPriorityThenDueThenTitle() throws {
        let now = Date(timeIntervalSince1970: 1_000_000)
        try board.addCard(Card(title: "b low", priority: .low), to: todo)
        try board.addCard(Card(title: "urgent later", priority: .urgent, due: now.addingTimeInterval(200)), to: todo)
        try board.addCard(Card(title: "urgent soon", priority: .urgent, due: now.addingTimeInterval(100)), to: todo)
        try board.addCard(Card(title: "a low", priority: .low), to: todo)
        try board.addCard(Card(title: "urgent none", priority: .urgent), to: todo)
        try board.sortColumn(todo)
        XCTAssertEqual(board.columns[0].cards.map(\.title), ["urgent soon", "urgent later", "urgent none", "a low", "b low"])
    }

    func testSearchOverdueAndProgress() throws {
        let now = Date(timeIntervalSince1970: 1_000_000)
        try board.addCard(Card(title: "Fix login", due: now.addingTimeInterval(-60), labels: ["Auth"]), to: todo)
        let shipped = try board.addCard(Card(title: "Ship v1", due: now.addingTimeInterval(-60)), to: todo)
        try board.move(card: shipped.id, to: done, at: 0)
        XCTAssertEqual(board.search("auth").map(\.title), ["Fix login"])
        XCTAssertEqual(board.search("  ").count, 0)
        XCTAssertEqual(board.overdue(now: now).map(\.title), ["Fix login"]) // done cards are never overdue
        XCTAssertEqual(board.progress, 0.5, accuracy: 0.0001)
        XCTAssertEqual(Board.standard().progress, 0)
    }
}
