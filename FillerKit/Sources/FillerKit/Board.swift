import Foundation

// TODO: Each local player should see the board oriented such that they are positioned in the bottom left.
// The opposing player should always appear in the top right.
// That means that the board will have to be inverted for one of the players.

public struct Board: Codable {
    public let width: Int
    public let height: Int
    public private(set) var tiles: [Tile]

    public init(width: Int = 5, height: Int = 5) {
        var tiles = [Tile]()
        tiles.reserveCapacity(width * height)
        for _ in 0 ..< width * height {
            tiles.append(Tile.allCases.randomElement()!)
        }

        self.tiles = tiles
        self.width = width
        self.height = height

        // Player one and Player two can't have the same tiles
        if startingTile(for: .playerOne) == startingTile(for: .playerTwo) {
            var eligibleTiles = Set(Tile.allCases)
            eligibleTiles.remove(startingTile(for: .playerTwo))
            let newPlayerOneTile = eligibleTiles.randomElement()!
            setTile(startingTileCoordinates(for: .playerOne), to: newPlayerOneTile)
        }
    }

    public init(unsafeWidth width: Int, height: Int, tiles: [Tile]) {
        precondition(tiles.count == width * height, "Invalid width, height, tiles combination.")
        self.width = width
        self.height = height
        self.tiles = tiles
    }

    // MARK: - Utilities

    public var inverted: Board {
        Board(unsafeWidth: width, height: height, tiles: tiles.reversed())
    }

    public subscript(row row: Int, col col: Int) -> Tile {
        get {
            tiles[row * width + col]
        }

        set {
            tiles[row * width + col] = newValue
        }
    }

    public subscript(_ coord: TileCoordinate) -> Tile {
        get {
            self[row: coord.row, col: coord.col]
        }

        set {
            self[row: coord.row, col: coord.col] = newValue
        }
    }

    // MARK: - Mutating Functions

    public mutating func capture(_ tile: Tile, for player: Player) {
        self.setTiles(tiles(belongingToPlayer: player), to: tile)
    }

    public mutating func setTiles(_ tileCoordinates: Set<TileCoordinate>, to newTile: Tile) {
        for coordinate in tileCoordinates {
            setTile(coordinate, to: newTile)
        }
    }

    public mutating func setTile(_ tileCoordinate: TileCoordinate, to newTile: Tile) {
        self[row: tileCoordinate.row, col: tileCoordinate.col] = newTile
    }

    // MARK: - Stats

    public var scores: [Player: Int] {
        Dictionary.init(uniqueKeysWithValues: Player.allCases.map {
            ($0, tiles(belongingToPlayer: $0).count)
        })
    }

    public var winner: Player? {
        let scores = self.scores

        guard scores.values.reduce(0, +) == width * height else {
            return nil
        }

        return scores.max(by: { $0.value < $1.value })?.key
    }

    public func isStartingTile(_ tile: Tile) -> Bool {
        tile == self.startingTile(for: .playerOne) || tile == self.startingTile(for: .playerTwo)
    }

    public func startingTileCoordinates(for player: Player) -> TileCoordinate {
        switch player {
        case .playerOne:
            return TileCoordinate(row: height - 1, col: 0)
        case .playerTwo:
            return TileCoordinate(row: 0, col: width - 1)
        }
    }

    public func startingTile(for player: Player) -> Tile {
        let tile = startingTileCoordinates(for: player)
        return self[row: tile.row, col: tile.col]
    }

    private func tile(row: Int, col: Int, belongsToPlayer player: Player) -> Bool {
        self[row: row, col: col] == startingTile(for: player)
    }

    public func tiles(belongingToPlayer player: Player) -> Set<TileCoordinate> {
        let start = startingTileCoordinates(for: player)
        return tilesConnected(to: start)
    }

    private func tilesConnected(to start: TileCoordinate) -> Set<TileCoordinate> {
        var results: Set<TileCoordinate> = []
        var seen: Set<TileCoordinate> = []
        var stack = [start]
        let searchTile = self[row: start.row, col: start.col]

        while let current = stack.popLast() {
            guard seen.insert(current).inserted else {
                continue
            }

            let tile = self[row: current.row, col: current.col]

            if tile != searchTile {
                continue
            }

            results.insert(current)

            for direction in Direction.allCases {
                do {
                    try stack.append(direction.applying(to: current, on: self))
                } catch {
                    continue
                }
            }
        }

        return results
    }

    public func tileEdges(belongingToPlayer player: Player) -> Set<TileEdge> {
        var results = Set<TileEdge>()
        let playerTiles = tiles(belongingToPlayer: player)
        for tile in playerTiles {
            for direction in Direction.allCases {
                do {
                    let test = try direction.applying(to: tile, on: self)
                    if self[test] != self[tile] {
                        results.insert(TileEdge(tile: tile, direction: direction))
                    }
                } catch {
                    results.insert(TileEdge(tile: tile, direction: direction))
                }
            }
        }
        return results
    }
}

#if DEBUG
extension Board: CustomDebugStringConvertible {
    public var debugDescription: String {
        var description = ""
        for (tile, index) in zip(tiles, tiles.indices) {
            description += tile.debugDescription
            if (index + 1) % width == 0 {
                description += "\n"
            }
        }
        return description
    }

    public var swiftDescription: String {
        let tilesSD = tiles
            .map(\.swiftDescription)
            .joined(separator: ", ")

        return """
        Board(width: \(width), height: \(height), tiles: [\(tilesSD)])
        """
    }

    public func printDebugDescription() {
        print(debugDescription)
        print(swiftDescription)
        do {
            try print(JSONEncoder().encode(self).utf8String)
        } catch {
            print("Encode error: \(error)")
        }
    }

    public static let preview = Board(unsafeWidth: 6, height: 6, tiles: [
        .🟥, .🟧, .🟨, .🟩, .🟦, .🟪,
        .🟪, .🟥, .🟧, .🟨, .🟩, .🟦,
        .🟦, .🟪, .🟥, .🟧, .🟨, .🟩,
        .🟩, .🟦, .🟪, .🟥, .🟧, .🟨,
        .🟨, .🟩, .🟦, .🟪, .🟥, .🟧,
        .🟧, .🟨, .🟩, .🟦, .🟪, .🟥,
    ])

    public static let bordered = Board(unsafeWidth: 6, height: 6, tiles: [
        .🟩, .🟧, .🟩, .🟩, .🟩, .🟩,
        .🟧, .🟧, .🟧, .🟩, .🟩, .🟩,
        .🟧, .🟩, .🟧, .🟧, .🟧, .🟩,
        .🟩, .🟩, .🟧, .🟩, .🟧, .🟩,
        .🟧, .🟧, .🟧, .🟧, .🟧, .🟧,
        .🟧, .🟧, .🟩, .🟩, .🟩, .🟩,
    ])
}

extension Data {
    var utf8String: String {
        String(data: self, encoding: .utf8) ?? "error"
    }
}
#endif
