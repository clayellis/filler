public struct TileCoordinate: Hashable {
    public let row: Int
    public let col: Int

    public init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
}

#if DEBUG
extension TileCoordinate: CustomDebugStringConvertible {
    public var debugDescription: String {
        "[\(row), \(col)]"
    }
}
#endif

public struct TraceCoordinate: Hashable {
    public let x: Int
    public let y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}
