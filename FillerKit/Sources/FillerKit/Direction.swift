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
