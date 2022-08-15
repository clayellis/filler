import FillerKit
import Foundation
import SwiftUI

class LocalGame: ObservableObject {
    enum GameState {
        case notPlaying
        case pickDimensions
        case playing(turn: Player)
        case finished(winner: Player)
    }

    @Published var board: Board
    @Published var state: GameState = .notPlaying
    @Published var dimensions = (width: 10, height: 10) {
        didSet {
            board = .init(width: dimensions.width, height: dimensions.height)
        }
    }

    init(board: Board = .init(), state: GameState = .notPlaying) {
        self.board = board
        self.state = state
    }

    var winner: Player? {
        board.winner
    }

    var turn: Player {
        switch state {
        case .notPlaying, .pickDimensions:
            return .playerOne

        case .playing(let turn):
            return turn

        case .finished(let winner):
            return winner
        }
    }

    func newGame() {
        state = .pickDimensions
    }

    func confirmDimensions() {
        board = .init(width: dimensions.width, height: dimensions.height)
        state = .playing(turn: .playerOne)
    }

    func playerPicked(_ tile: Tile) {
        guard case let .playing(turn) = state else {
            return
        }

        withAnimation {
            board.capture(tile, for: turn)
            updateState()
        }
    }

    func score(for player: Player) -> Int {
        board.scores[player, default: 0]
    }

    private func updateState() {
        if let winner = board.winner {
            state = .finished(winner: winner)
        } else {
            state = .playing(turn: turn == .playerOne ? .playerTwo : .playerOne)
        }
    }
}
