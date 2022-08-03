import GameKit
import SwiftUI

@MainActor
@main
struct FillerApp: App {
    @ObservedObject var matchmaking = MatchmakingModel()

    init() {
        if let playerID = UserDefaults.standard.string(forKey: "playerID") {
            FillerAPI.playerID = UUID(uuidString: playerID)!
        } else {
            let playerID = UUID()
            FillerAPI.playerID = playerID
            UserDefaults.standard.set(playerID.uuidString, forKey: "playerID")
        }
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                MatchmakingView(model: matchmaking)
                    .navigationDestination(when: $matchmaking.currentGame) { game in
                        try! RemoteGameView(game: RemoteGame(remoteGame: game))
//                        LocalGameView(game: LocalGame(board: game.board))
                    }
            }
        }
    }
}
