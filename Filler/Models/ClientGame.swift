import FillerKit
import Foundation
import SwiftUI

class ClientGame: ObservableObject {
    enum GameState {
        case notPlaying
        case pickDimensions
        case playing(turn: Player)
        case finished(winner: Player)
    }

    @Published var game: Game
    @Published var state: GameState = .notPlaying
    @Published var dimensions = (width: 10, height: 10) {
        didSet {
            game.board = .init(width: dimensions.width, height: dimensions.height)
        }
    }

    var board: Board { game.board }

    var winner: Player? {
        switch state {
        case .finished(let winner):
            return winner
        default:
            return nil
        }
    }

    var turn: Player? {
        switch state {
        case .playing(let turn):
            return turn
        default:
            return nil
        }
    }

    init(game: Game = .init(), state: GameState = .notPlaying) {
        self.game = game
        self.state = state
    }

    func newGame() {
        state = .pickDimensions
    }

    func confirmDimensions() {
        game = .init(board: .init(width: dimensions.width, height: dimensions.height), turn: .playerOne)
        state = .playing(turn: .playerOne)
    }

    func playerPicked(_ tile: Tile) {
        withAnimation {
            game.playerPicked(tile)
            updateState()
        }
    }

    func score(for player: Player) -> Int {
        game.getScore(for: player)
    }

    private func updateState() {
        if let winner = game.getWinner() {
            state = .finished(winner: winner)
        } else {
            state = .playing(turn: game.turn)
        }
    }
}
