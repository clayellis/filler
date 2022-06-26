import SwiftUI

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

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(board: .preview)
    }
}
