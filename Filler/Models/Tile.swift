import Foundation

enum Tile: Int, CaseIterable, Codable, Equatable, Identifiable {
    case red
    case orange
    case yellow
    case green
    case blue
    case purple

    var id: Self { self }
}

#if DEBUG
extension Tile: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .red:
            return "🟥"
        case .orange:
            return "🟧"
        case .yellow:
            return "🟨"
        case .green:
            return "🟩"
        case .blue:
            return "🟦"
        case .purple:
            return "🟪"
        }
    }

    var swiftDescription: String {
        switch self {
        case .red:
            return ".red"
        case .orange:
            return ".orange"
        case .yellow:
            return ".yellow"
        case .green:
            return ".green"
        case .blue:
            return ".blue"
        case .purple:
            return ".purple"
        }
    }
}
#endif
