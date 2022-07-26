import FillerKit
import SwiftUI

struct TurnView: View {
    @ObservedObject var game: ClientGame

    private struct CapsuleID: Hashable {}
    @Namespace private var capsule: Namespace.ID

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

struct TurnView_Previews: PreviewProvider {
    static var previews: some View {
        TurnView(game: ClientGame(game: .init(board: .preview)))
            .previewLayout(.sizeThatFits)
    }
}
