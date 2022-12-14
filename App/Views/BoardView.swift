import FillerKit
import SwiftUI

struct BoardView: View {
    var spacing: CGFloat = 0
    var board: Board

    var body: some View {
        VStack(spacing: spacing) {
            ForEach(0..<board.height, id: \.self) { row in
                HStack(spacing: spacing) {
                    ForEach(0..<board.width, id: \.self) { col in
                        let tile = board[row: row, col: col]
                        tile.color
                    }
                }
            }
        }
        .aspectRatio(CGFloat(board.width) / CGFloat(board.height), contentMode: .fit)
        #if DEBUG
        .onTapGesture {
            board.printDebugDescription()
        }
        #endif
    }
}

extension Tile {
    var color: Color {
        switch self {
        case .red:
            return .red
        case .orange:
            return .orange
        case .yellow:
            return .yellow
        case .green:
            return .green
        case .blue:
            return .blue
        case .purple:
            return .purple
        }
    }
}
struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        let spacing: CGFloat = 0

        BoardView(spacing: spacing, board: .preview)
            .previewLayout(.sizeThatFits)

        BoardView(spacing: spacing, board: .preview.inverted)
            .previewLayout(.sizeThatFits)

        BoardView(spacing: spacing, board: Board(unsafeWidth: 4, height: 6, tiles: [
            .red, .orange, .yellow, .green,
            .green, .red, .orange, .yellow,
            .yellow, .green, .red, .orange,
            .orange, .yellow, .green, .red,
            .red, .orange, .yellow, .green,
            .green, .red, .orange, .yellow,
        ]))
        .previewLayout(.sizeThatFits)

        BoardView(spacing: spacing, board: Board(unsafeWidth: 6, height: 4, tiles: [
            .red, .orange, .yellow, .green, .blue, .purple,
            .purple, .red, .orange, .yellow, .green, .blue,
            .blue, .purple, .red, .orange, .yellow, .green,
            .green, .blue, .purple, .red, .orange, .yellow,
        ]))
        .previewLayout(.sizeThatFits)
    }
}
