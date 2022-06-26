struct TileCoordinate: Hashable {
    let row: Int
    let col: Int
}

#if DEBUG
extension TileCoordinate: CustomDebugStringConvertible {
    var debugDescription: String {
        "[\(row), \(col)]"
    }
}
#endif
