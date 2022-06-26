enum Player: CaseIterable, Equatable, Identifiable {
    case playerOne
    case playerTwo

    var id: Self { self }

    var name: String {
        switch self {
        case .playerOne: return "P1"
        case .playerTwo: return "P2"
        }
    }
}
