import SwiftUI

@MainActor
class MatchmakingModel: ObservableObject {
    @Published private var games: [RemoteGameSummary] = []
    @Published var error: String?
    @Published var currentGame: RemoteGameDetail?

    var myGames: [RemoteGameSummary] {
        games.filter { $0.playerOne == FillerAPI.playerID || $0.playerTwo == FillerAPI.playerID }
    }

    var otherGames: [RemoteGameSummary] {
        games.filter { $0.playerOne != FillerAPI.playerID && $0.playerTwo != FillerAPI.playerID }
    }

    func getGames() {
        apiTask {
            self.games = try await FillerAPI.getGames()
        }
    }

    func joinGame(_ game: RemoteGameSummary) {
        apiTask {
            self.currentGame = try await FillerAPI.joinGame(code: game.code)
        }
    }

    func newGame() {
        apiTask {
            self.currentGame = try await FillerAPI.createGame(width: 10, height: 10)
        }
    }

    func rejoinGame(_ game: RemoteGameSummary) {
        apiTask {
            self.currentGame = try await FillerAPI.getGame(code: game.code)
        }
    }

    private func apiTask(_ work: @escaping () async throws -> Void) {
        Task { @MainActor in
            do {
                try await work()
                self.error = nil
            } catch {
                self.error = error.localizedDescription
                print(error)
            }
        }
    }
}

struct MatchmakingView: View {
    @ObservedObject var model: MatchmakingModel

    var body: some View {
        Form {
            if let error = model.error {
                Text(error)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }

            Section("My Games") {
                ForEach(model.myGames) { game in
                    HStack {
                        Text(game.code)
                            .font(.title.monospaced())

                        Spacer()

                        Button {
                            model.rejoinGame(game)
                        } label: {
                            Text("Play")
                        }
                        .buttonStyle(.borderedProminent)

                        if game.playerTwo == nil {
                            Button {
                                UIPasteboard.general.string = game.code
                            } label: {
                                Text("Invite")
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding()
                }
            }

            Section("Other Games") {
                ForEach(model.otherGames) { game in
                    HStack {
                        Text(game.code)
                            .font(.title.monospaced())

                        Spacer()

                        Button {
                            model.joinGame(game)
                        } label: {
                            Text("Join")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(game.playerTwo != nil)
                    }
                    .padding()
                }
            }
        }
        .refreshable {
            model.getGames()
        }
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    model.newGame()

                    // choose from
                    // - new local game
                    // - new online game
                    // - new gamecenter game

                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            model.getGames()
        }
    }
}

struct MatchmakingView_Previews: PreviewProvider {
    static var previews: some View {
        MatchmakingView(model: MatchmakingModel())
    }
}
