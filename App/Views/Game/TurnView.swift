import FillerKit
import SwiftUI

struct TurnView: View {
    let turn: Player?
    let winner: Player?
    let scores: [Player: Int]

    private struct CapsuleID: Hashable {}
    @Namespace private var capsule: Namespace.ID

    var body: some View {
        HStack(alignment: .top) {
            ForEach(Player.allCases) { player in
                VStack {
                    HStack {
                        if player == winner {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                        }

                        Text("\(player.name):")
                            .font(.body.bold())

                        if let score = scores[player] {
                            Text("\(score)")
                        }
                    }

                    if player == turn {
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
        TurnView(turn: .playerOne, winner: nil, scores: [.playerOne: 1, .playerTwo: 1])
            .previewLayout(.sizeThatFits)
    }
}
