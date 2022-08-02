import FillerKit
import Foundation
import SwiftUI

class ClientGame: ObservableObject {
    enum GameState {
        case notPlaying
        case pickDimensions
        case playing
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
        board.turn
    }

    func newGame() {
        state = .pickDimensions
    }

    func confirmDimensions() {
        board = .init(width: dimensions.width, height: dimensions.height)
        state = .playing
    }

    func playerPicked(_ tile: Tile) {
        withAnimation {
            board.capture(tile, for: board.turn)
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
            board.toggleTurn()
        }
    }
}
