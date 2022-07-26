import FillerKit
import SwiftUI

struct GameView: View {
    @ObservedObject var game: ClientGame
    // TODO: Let user choose the size of the board when starting a new game

    var body: some View {
        VStack {
            // TODO: Draw a border around the active player's tiles

            BoardView(board: game.board)

            if case .playing = game.state {
                ColorPickerView(board: game.board) { tile in
                    game.playerPicked(tile)
                }
                .padding(.vertical)
            }

            switch game.state {
            case .playing, .finished:
                TurnView(game: game)
            case .notPlaying:
                EmptyView()
            }

            Spacer()

            switch game.state {
            case .notPlaying, .finished:
                Button {
                    game.newGame()
                } label: {
                    Text("New Game")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .playing:
                EmptyView()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: ClientGame(game: .init(board: .preview), state: .playing(turn: .playerOne)))
    }
}
