import Foundation
import GameKit
import SwiftUI

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
