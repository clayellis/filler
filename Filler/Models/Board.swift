// TODO: Each local player should see the board oriented such that they are positioned in the bottom left.
// The opposing player should always appear in the top right.
// That means that the board will have to be inverted for one of the players.

struct Board {
    var tiles: [Tile]
    let width: Int
    let height: Int

    init(width: Int = 5, height: Int = 5) {
        var tiles = [Tile]()
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

    init(unsafeWidth width: Int, height: Int, tiles: [Tile]) {
        precondition(tiles.count == width * height, "Invalid width, height, tiles combination.")
        self.width = width
        self.height = height
        self.tiles = tiles
    }

    subscript(row row: Int, col col: Int) -> Tile {
        get {
            tiles[row * width + col]
        }

        set {
            tiles[row * width + col] = newValue
        }
    }

    func isPlayerTile(_ tile: Tile) -> Bool {
        tile == self.startingTile(for: .playerOne) || tile == self.startingTile(for: .playerTwo)
    }

    func startingTileCoordinates(for player: Player) -> TileCoordinate {
        switch player {
        case .playerOne:
            return TileCoordinate(row: height - 1, col: 0)
        case .playerTwo:
            return TileCoordinate(row: 0, col: width - 1)
        }
    }

    func startingTile(for player: Player) -> Tile {
        let tile = startingTileCoordinates(for: player)
        return self[row: tile.row, col: tile.col]
    }

    mutating func capture(_ tile: Tile, for player: Player) {
        self.setTiles(tiles(belongingToPlayer: player), to: tile)
    }

    mutating func setTiles(_ tileCoordinates: Set<TileCoordinate>, to newTile: Tile) {
        for coordinate in tileCoordinates {
            setTile(coordinate, to: newTile)
        }
    }

    mutating func setTile(_ tileCoordinate: TileCoordinate, to newTile: Tile) {
        self[row: tileCoordinate.row, col: tileCoordinate.col] = newTile
    }

    private func tile(row: Int, col: Int, belongsToPlayer player: Player) -> Bool {
        self[row: row, col: col] == startingTile(for: player)
    }

    func tiles(belongingToPlayer player: Player) -> Set<TileCoordinate> {
        let start = startingTileCoordinates(for: player)
        return tilesConnected(to: start, tile: startingTile(for: player))
    }

    private func tilesConnected(to start: TileCoordinate, tile searchTile: Tile) -> Set<TileCoordinate> {
        var results: Set<TileCoordinate> = []
        var seen: Set<TileCoordinate> = []
        var stack = [start]

        while let current = stack.popLast() {
            if seen.contains(current) {
                continue
            }

            seen.insert(current)

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
}

#if DEBUG
extension Board: CustomDebugStringConvertible {
    var debugDescription: String {
        var description = ""
        for (tile, index) in zip(tiles, tiles.indices) {
            description += tile.debugDescription
            if (index + 1) % width == 0 {
                description += "\n"
            }
        }
        return description
    }

    var swiftDescription: String {
        let tilesSD = tiles
            .map(\.swiftDescription)
            .joined(separator: ", ")

        return """
        Board(width: \(width), height: \(height), tiles: [\(tilesSD)])
        """
    }
}
#endif
