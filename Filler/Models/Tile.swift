import Foundation

enum Tile: Int, CaseIterable, Codable, Equatable, Identifiable {
    case red
    case yellow
    case green
    case blue
    case purple
    case black

    var id: Self { self }
}

#if DEBUG
extension Tile: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .red:
            return "🟥"
        case .yellow:
            return "🟨"
        case .green:
            return "🟩"
        case .blue:
            return "🟦"
        case .purple:
            return "🟪"
        case .black:
            return "⬛️"
        }
    }

    var swiftDescription: String {
        switch self {
        case .red:
            return ".red"
        case .yellow:
            return ".yellow"
        case .green:
            return ".green"
        case .blue:
            return ".blue"
        case .purple:
            return ".purple"
        case .black:
            return ".black"
        }
    }
}
#endif
