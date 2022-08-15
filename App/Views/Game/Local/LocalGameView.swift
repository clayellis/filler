import FillerKit
import SwiftUI

struct LocalGameView: View {
    @ObservedObject var game: LocalGame

    var body: some View {
        VStack {
            switch game.state {
            case .playing, .finished:
                TurnView(
                    turn: game.turn,
                    winner: game.winner,
                    scores: game.board.scores
                )
            default:
                EmptyView()
            }

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
        LocalGameView(game: LocalGame(board: .bordered, state: .notPlaying))
    }
}
