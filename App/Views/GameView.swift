import FillerKit
import SwiftUI

struct GameView: View {
    @ObservedObject var game: ClientGame

    var body: some View {
        VStack {
            switch game.state {
            case .playing, .finished:
                TurnView(game: game)
            default:
                EmptyView()
            }

            BoardView(board: game.board)
                .overlay {
                    BoardOverlay(
                        game: game,
                        borderColor: .color(.black),
                        borderStyle: .dashed
                    )
                }

            if case .playing = game.state {
                ColorPickerView(board: game.board) { tile in
                    game.playerPicked(tile)
                }
                .padding(.vertical)
            }

            switch game.state {
            case .pickDimensions:
                VStack {
                    Spacer()

                    DimensionPicker(
                        width: $game.dimensions.width,
                        height: $game.dimensions.height
                    )
                }

            default:
                EmptyView()
            }

            Spacer()

            switch game.state {
            case .pickDimensions:
                Button {
                    game.confirmDimensions()
                } label: {
                    Text("Start")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .notPlaying, .finished:
                Button {
                    game.newGame()
                } label: {
                    Text("New Game")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .playing:
                Button {
                    game.newGame()
                } label: {
                    Text("Start Over")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(game: ClientGame(board: .bordered, state: .notPlaying))
    }
}
