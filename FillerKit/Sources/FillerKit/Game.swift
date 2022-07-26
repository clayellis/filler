import Foundation

public struct Game {
    public var board: Board
    private(set) var scores: [Player: Int] = [:]
    public private(set) var turn: Player

    public init(board: Board = .init(), turn: Player = .playerOne) {
        self.board = board
        self.turn = turn
    }

    public mutating func playerPicked(_ tile: Tile) {
        board.capture(tile, for: turn)
        updateTurn()
        updateScores()
    }

    public func getWinner() -> Player? {
        guard scores.values.reduce(0, +) == board.width * board.height else {
            return nil
        }

        return scores.max(by: { $0.value < $1.value })?.key
    }

    public func getScore(for player: Player) -> Int {
        scores[player, default: 0]
    }

    private mutating func updateTurn() {
        turn = turn == .playerOne ? .playerTwo : .playerOne
    }

    private mutating func updateScores() {
        for player in Player.allCases {
            let playerTiles = board.tiles(belongingToPlayer: player)
            let score = playerTiles.count
            scores[player] = score
        }
    }
}
