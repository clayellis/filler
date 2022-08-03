import SwiftUI

struct RemoteGameView: View {
    @ObservedObject var game: RemoteGame

    var body: some View {
        ZStack {
            VStack {
                TurnView(
                    turn: game.turn,
                    winner: game.winner,
                    scores: game.board.scores
                )

                BoardView(board: game.board)
                    .overlay {
                        BoardOverlay(
                            turn: game.turn,
                            winner: game.winner,
                            board: game.board,
                            borderColor: .color(.black),
                            borderStyle: .dashed
                        )
                    }

                if game.winner == nil {
                    ColorPickerView(board: game.board) { tile in
                        game.playerPicked(tile)
                    }
                    .disabled(!game.isReady)
                    .opacity(game.isReady ? 1 : 0.5)
                }

                Spacer()

                #if DEBUG
                GroupBox {
                    VStack(alignment: .leading) {
                        Text("Game: \(game.gameCode)")
                        Text("P1: \(game.remoteGame.playerOne.uuidString)")
                        Text("P2: \(game.remoteGame.playerTwo?.uuidString ?? "none")")
                        Text("Local: \(game.localPlayer.name)")
                    }
                    .font(.caption.monospaced())
                    .layoutPriority(1)
                }
                .contextMenu {
                    Button("Game Code") {
                        UIPasteboard.general.string = game.gameCode
                    }

                    Button("P1 ID") {
                        UIPasteboard.general.string = game.remoteGame.playerOne.uuidString
                    }

                    Button("P2 ID") {
                        UIPasteboard.general.string = game.remoteGame.playerTwo?.uuidString
                    }
                }
                #endif
            }
            .padding()

            if !game.isReady {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay {
                        ProgressView()
                            .foregroundColor(.white)
                    }
            }
        }
        .onDisappear {
            // TODO: Disconnect from socket
        }
    }
}

struct RemoteGameView_Previews: PreviewProvider {
    static var previews: some View {
        let playerOne = UUID()
        FillerAPI.playerID = playerOne

        return RemoteGameView(game: try! RemoteGame(remoteGame: RemoteGameDetail(
            code: "123456",
            playerOne: playerOne,
            playerTwo: nil,
            turn: .playerOne,
            board: .preview
        )))
    }
}
