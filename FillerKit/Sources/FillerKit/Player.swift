public enum Player: CaseIterable, Equatable, Identifiable {
    case playerOne
    case playerTwo

    public var id: Self { self }

    public var name: String {
        switch self {
        case .playerOne: return "P1"
        case .playerTwo: return "P2"
        }
    }
}
