import Foundation

public struct TileEdge: Hashable {
    public let tile: TileCoordinate
    public let direction: Direction

    public init(tile: TileCoordinate, direction: Direction) {
        self.tile = tile
        self.direction = direction
    }
}
