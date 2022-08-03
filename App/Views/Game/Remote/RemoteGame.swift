import FillerKit
import Foundation
import SwiftUI

@MainActor
class RemoteGame: ObservableObject {
    enum GameState {
        case loading
        case waitingForRemotePlayerToJoin
        case playing(turn: Player)
        case finished(winner: Player)
    }

    @Published var state: GameState
    @Published var board: Board
    @Published var error: String?
    @Published var isBusy: Bool = false
    let remoteGame: RemoteGameDetail
    let gameCode: String
    let localPlayer: Player
    private var pollGameTask: Task<Void, Error>?

    var turn: Player? {
        switch state {
        case .loading, .waitingForRemotePlayerToJoin:
            return nil

        case .playing(let turn):
            return turn

        case .finished(let winner):
            return winner
        }
    }

    var winner: Player? {
        switch state {
        case .finished(let winner):
            return winner

        default:
            return nil
        }
    }

    var isLocalPlayersTurn: Bool {
        turn == localPlayer
    }

    var isReady: Bool {
        !isBusy && (isLocalPlayersTurn || winner != nil)
    }

    init(remoteGame: RemoteGameDetail) throws {
        guard [remoteGame.playerOne, remoteGame.playerTwo].contains(FillerAPI.playerID) else {
            // TODO: Throw error
            fatalError()
        }

        self.remoteGame = remoteGame
        state = .loading
        localPlayer = FillerAPI.playerID == remoteGame.playerOne ? .playerOne : .playerTwo
        gameCode = remoteGame.code
        board = remoteGame.board(for: localPlayer)
        update(with: remoteGame)
        pollGame()
    }

    deinit {
        pollGameTask?.cancel()
    }

    private func pollGame() {
        pollGameTask = Task { @MainActor [gameCode, weak self] in
            while true {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1)
                do {
                    let updatedGame = try await FillerAPI.getGame(code: gameCode)
                    self?.update(with: updatedGame)
                    self?.error = nil
                } catch {
                    self?.error = error.localizedDescription
                }
            }
        }
    }

    private func update(with remoteGame: RemoteGameDetail) {
        if remoteGame.playerTwo == nil {
            state = .waitingForRemotePlayerToJoin
        } else if let winner = remoteGame.board.winner {
            state = .finished(winner: winner)
        } else {
            state = .playing(turn: remoteGame.turn)
        }

        board = remoteGame.board(for: localPlayer)
    }

    func playerPicked(_ tile: Tile) {
        Task { @MainActor in
            do {
                guard !isBusy else {
                    return
                }

                isBusy = true

                let updatedGame = try await FillerAPI.makeTurn(gameCode: gameCode, selection: tile)
                update(with: updatedGame)
                error = nil
            } catch {
                self.error = error.localizedDescription
            }

            isBusy = false
        }
    }
}

extension RemoteGameDetail {
    func board(for player: Player) -> Board {
        board
//        player == .playerOne ? board : board.inverted
    }
}
