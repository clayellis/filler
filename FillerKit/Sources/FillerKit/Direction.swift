public enum Direction: CaseIterable {
    case up, down, left, right
}

extension Direction {
    public struct DirectionApplicationError: Error {}

    public func apply(toRow row: inout Int, col: inout Int, on board: Board) throws {
        switch self {
        case .up:
            guard row > 0 else {
                throw DirectionApplicationError()
            }

            row -= 1

        case .down:
            guard row < board.height - 1 else {
                throw DirectionApplicationError()
            }

            row += 1

        case .left:
            guard col > 0 else {
                throw DirectionApplicationError()
            }

            col -= 1

        case .right:
            guard col < board.width - 1 else {
                throw DirectionApplicationError()
            }

            col += 1
        }
    }

    public func apply(to coordinate: inout TileCoordinate, on board: Board) throws {
        var row = coordinate.row
        var col = coordinate.col
        try apply(toRow: &row, col: &col, on: board)
        coordinate = TileCoordinate(row: row, col: col)
    }

    public func applying(to coordinate: TileCoordinate, on board: Board) throws -> TileCoordinate {
        var row = coordinate.row
        var col = coordinate.col
        try apply(toRow: &row, col: &col, on: board)
        return TileCoordinate(row: row, col: col)
    }
}

extension Direction {
    public func apply(toX x: inout Int, y: inout Int, on board: Board) throws {
        switch self {
        case .up:
            guard y > 0 else {
                throw DirectionApplicationError()
            }

            y -= 1

        case .down:
            guard y < board.height else {
                throw DirectionApplicationError()
            }

            y += 1

        case .left:
            guard x > 0 else {
                throw DirectionApplicationError()
            }

            x -= 1

        case .right:
            guard x < board.width else {
                throw DirectionApplicationError()
            }

            x += 1
        }
    }

    public func apply(to coordinate: inout TraceCoordinate, on board: Board) throws {
        var x = coordinate.x
        var y = coordinate.y
        try apply(toX: &x, y: &y, on: board)
        coordinate = TraceCoordinate(x: x, y: y)
    }

    public func applying(to coordinate: TraceCoordinate, on board: Board) throws -> TraceCoordinate {
        var x = coordinate.x
        var y = coordinate.y
        try apply(toX: &x, y: &y, on: board)
        return TraceCoordinate(x: x, y: y)
    }
}
