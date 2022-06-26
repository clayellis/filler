import SwiftUI

extension Tile {
    var color: Color {
        switch self {
        case .red:
            return .red
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        case .black:
            return .black
        }
    }
}

struct BoardView: View {
    var board: Board
    let spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: spacing) {
                ForEach(0..<board.width, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<board.height, id: \.self) { col in
                            let tile = board[row: row, col: col]
                            let tileLength = tileLength(containerSize: geometry.size)
                            tile.color
                                .frame(width: tileLength, height: tileLength)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            print(board.debugDescription)
            print(board.swiftDescription)
        }
    }

    func tileLength(width: CGFloat) -> CGFloat {
        return (width - spacing * CGFloat(board.width - 1)) / CGFloat(board.width)
    }

    func tileLength(containerSize: CGSize) -> CGFloat {
        if containerSize.width > containerSize.height {
            return (containerSize.height - spacing * CGFloat(board.height - 1)) / CGFloat(board.height)
        } else {
            return (containerSize.width - spacing * CGFloat(board.width - 1)) / CGFloat(board.width)
        }
    }
}

struct ColorPickerView: View {
    var board: Board
    var onPick: (Tile) -> ()

    var body: some View {
        HStack {
            ForEach(Tile.allCases) { tile in
                let isPlayerTile = board.isPlayerTile(tile)

                Button {
                    onPick(tile)
                } label: {
                    tile.color
                        .aspectRatio(1, contentMode: .fit)
                        .scaleEffect(isPlayerTile ? 0.7 : 1)
                        .opacity(isPlayerTile ? 0.5 : 1)
                }
                .disabled(isPlayerTile)
            }
        }
    }
}

struct TurnView: View {
    @ObservedObject var game: Game

    private struct CapsuleID: Hashable {}
    @Namespace var capsule: Namespace.ID

    var body: some View {
        HStack(alignment: .top) {
            ForEach(Player.allCases) { player in
                VStack {
                    HStack {
                        if player == game.winner {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }

                        Text("\(player.name):")
                            .font(.body.bold())

                        Text("\(game.score(for: player))")
                    }

                    if player == game.turn {
                        Capsule()
                            .frame(width: 150, height: 5)
                            .matchedGeometryEffect(id: CapsuleID(), in: capsule)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 20)
    }
}

struct ContentView: View {
    @ObservedObject var game: Game
    // TODO: Let user choose the size of the board when starting a new game

    var body: some View {
        VStack {
            // TODO: Draw a border around the active player's tiles

            BoardView(board: game.board)

            if case .playing = game.state {
                ColorPickerView(board: game.board) { tile in
                    game.playerPicked(tile)
                }
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
        ContentView(game: Game())
    }
}
