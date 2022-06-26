import Foundation
import GameKit
import SwiftUI

// TODO: Each local player should see the board oriented such that they are positioned in the bottom left.
// The opposing player should always appear in the top right.
// That means that the board will have to be inverted for one of the players.

enum Tile: CaseIterable, CustomDebugStringConvertible, Equatable, Identifiable {
    case red
    case yellow
    case green
    case blue
    case purple
    case black

    var id: Self { self }

    var debugDescription: String {
        switch self {
        case .red:
            return "🟥"
        case .yellow:
            return "🟨"
        case .green:
            return "🟩"
        case .blue:
            return "🟦"
        case .purple:
            return "🟪"
        case .black:
            return "⬛️"
        }
    }

    var swiftDescription: String {
        switch self {
        case .red:
            return ".red"
        case .yellow:
            return ".yellow"
        case .green:
            return ".green"
        case .blue:
            return ".blue"
        case .purple:
            return ".purple"
        case .black:
            return ".black"
        }
    }
}

struct TileCoordinate: CustomDebugStringConvertible, Hashable {
    let row: Int
    let col: Int

    var debugDescription: String {
        "[\(row), \(col)]"
    }
}

enum Player: CaseIterable, Equatable, Identifiable {
    case playerOne
    case playerTwo

    var id: Self { self }

    var name: String {
        switch self {
        case .playerOne: return "P1"
        case .playerTwo: return "P2"
        }
    }
}

enum Direction: CaseIterable {
    case up, down, left, right

    struct DirectionApplicationError: Error {}

    func apply(toRow row: inout Int, col: inout Int, on board: Board) throws {
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

    func apply(to coordinate: inout TileCoordinate, on board: Board) throws {
        var row = coordinate.row
        var col = coordinate.col
        try apply(toRow: &row, col: &col, on: board)
        coordinate = TileCoordinate(row: row, col: col)
    }

    func applying(to coordinate: TileCoordinate, on board: Board) throws -> TileCoordinate {
        var row = coordinate.row
        var col = coordinate.col
        try apply(toRow: &row, col: &col, on: board)
        return TileCoordinate(row: row, col: col)
    }
}

struct Board: CustomDebugStringConvertible {
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

class Game: ObservableObject {
    @Published var board: Board
    @Published var state: GameState = .notPlaying
    @Published private var scores: [Player: Int] = [:]

    init(board: Board = .init()) {
        self.board = board
    }

    var turn: Player? {
        guard case let .playing(turn) = state else {
            return nil
        }

        return turn
    }

    var winner: Player? {
        guard case let .finished(winner) = state else {
            return nil
        }

        return winner
    }

    enum GameState {
        case notPlaying
        case playing(turn: Player)
        case finished(winner: Player?)
    }

    func newGame() {
        board = Board(width: board.width, height: board.height)
        state = .playing(turn: .playerOne)
        updateScores()
    }

    func playerPicked(_ tile: Tile) {
        guard let turn = turn else {
            return
        }

        board.capture(tile, for: turn)
        updateTurn()
        updateScores()
        checkForWinner()
    }

    private func updateTurn() {
        guard let turn = turn else {
            return
        }

        withAnimation {
            state = .playing(turn: turn == .playerOne ? .playerTwo : .playerOne)
        }
    }

    private func updateScores() {
        for player in Player.allCases {
            let playerTiles = board.tiles(belongingToPlayer: player)
            let score = playerTiles.count
            scores[player] = score
        }
    }

    private func checkForWinner() {
        if scores.values.reduce(0, +) == board.width * board.height {
            let winner = scores.max(by: { $0.value < $1.value })?.key
            state = .finished(winner: winner)
        }
    }

    func score(for player: Player) -> Int {
        scores[player, default: 0]
    }
}
