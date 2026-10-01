import Foundation

public enum Priority: Int, Comparable, CaseIterable {
    case low = 0, medium, high, urgent
    public static func < (a: Priority, b: Priority) -> Bool { a.rawValue < b.rawValue }
}

public struct Card: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var priority: Priority
    public var due: Date?
    public var labels: Set<String>

    public init(id: UUID = UUID(), title: String, priority: Priority = .medium, due: Date? = nil, labels: Set<String> = []) {
        self.id = id
        self.title = title
        self.priority = priority
        self.due = due
        self.labels = labels
    }

    public func isOverdue(now: Date) -> Bool { due.map { $0 < now } ?? false }
}

public struct Column: Identifiable, Equatable {
    public let id: UUID
    public var name: String
    /// Work-in-progress limit; nil means unlimited.
    public var wipLimit: Int?
    public var cards: [Card]

    public init(id: UUID = UUID(), name: String, wipLimit: Int? = nil, cards: [Card] = []) {
        self.id = id
        self.name = name
        self.wipLimit = wipLimit
        self.cards = cards
    }

    public var isAtLimit: Bool { wipLimit.map { cards.count >= $0 } ?? false }
}

public enum BoardError: Error, Equatable {
    case emptyTitle
    case columnNotFound
    case cardNotFound
    case wipLimitReached(column: String, limit: Int)
}

public struct Board: Equatable {
    public private(set) var columns: [Column]

    public init(columns: [Column]) { self.columns = columns }

    /// The default three-column board.
    public static func standard() -> Board {
        Board(columns: [Column(name: "To Do"), Column(name: "In Progress", wipLimit: 3), Column(name: "Done")])
    }

    private func columnIndex(_ id: UUID) throws -> Int {
        guard let i = columns.firstIndex(where: { $0.id == id }) else { throw BoardError.columnNotFound }
        return i
    }

    public func locate(card id: UUID) -> (column: Int, index: Int)? {
        for (ci, col) in columns.enumerated() {
            if let i = col.cards.firstIndex(where: { $0.id == id }) { return (ci, i) }
        }
        return nil
    }

    @discardableResult
    public mutating func addCard(_ card: Card, to columnID: UUID) throws -> Card {
        var card = card
        card.title = card.title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !card.title.isEmpty else { throw BoardError.emptyTitle }
        let ci = try columnIndex(columnID)
        try checkLimit(ci)
        columns[ci].cards.append(card)
        return card
    }

    /// Moves a card to `columnID` at `position` (clamped). Moving within the
    /// same column only reorders and never trips the WIP limit.
    public mutating func move(card id: UUID, to columnID: UUID, at position: Int) throws {
        guard let from = locate(card: id) else { throw BoardError.cardNotFound }
        let to = try columnIndex(columnID)
        if from.column != to { try checkLimit(to) }
        let card = columns[from.column].cards.remove(at: from.index)
        let clamped = max(0, min(position, columns[to].cards.count))
        columns[to].cards.insert(card, at: clamped)
    }

    public mutating func removeCard(_ id: UUID) throws {
        guard let at = locate(card: id) else { throw BoardError.cardNotFound }
        columns[at.column].cards.remove(at: at.index)
    }

    private func checkLimit(_ ci: Int) throws {
        if let limit = columns[ci].wipLimit, columns[ci].cards.count >= limit {
            throw BoardError.wipLimitReached(column: columns[ci].name, limit: limit)
        }
    }

    /// Sorts a column: highest priority first, then earliest due date (no due date last), then title.
    public mutating func sortColumn(_ columnID: UUID) throws {
        let ci = try columnIndex(columnID)
        columns[ci].cards.sort { a, b in
            if a.priority != b.priority { return a.priority > b.priority }
            switch (a.due, b.due) {
            case let (x?, y?) where x != y: return x < y
            case (.some, nil): return true
            case (nil, .some): return false
            default: return a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending
            }
        }
    }

    /// Cards whose title or labels contain `query` (case-insensitive), across all columns.
    public func search(_ query: String) -> [Card] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return [] }
        return columns.flatMap(\.cards).filter { card in
            card.title.lowercased().contains(q) || card.labels.contains { $0.lowercased().contains(q) }
        }
    }

    public func overdue(now: Date) -> [Card] { columns.dropLast().flatMap(\.cards).filter { $0.isOverdue(now: now) } }

    /// Share of cards in the last ("Done") column, 0...1.
    public var progress: Double {
        let total = columns.reduce(0) { $0 + $1.cards.count }
        guard total > 0, let done = columns.last else { return 0 }
        return Double(done.cards.count) / Double(total)
    }
}
