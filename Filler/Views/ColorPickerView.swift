import FillerKit
import SwiftUI

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

struct ColorPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ColorPickerView(board: .preview) { _ in }
            .previewLayout(.sizeThatFits)
    }
}
