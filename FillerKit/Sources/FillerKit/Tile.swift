import Foundation

public enum Tile: Int, CaseIterable, Codable, Equatable, Identifiable {
    case red = 0
    case orange = 1
    case yellow = 2
    case green = 3
    case blue = 4
    case purple = 5

    public var id: Self { self }
}

extension Tile {
    public static let 🟥: Self = .red
    public static let 🟧: Self = .orange
    public static let 🟨: Self = .yellow
    public static let 🟩: Self = .green
    public static let 🟦: Self = .blue
    public static let 🟪: Self = .purple
}

#if DEBUG
extension Tile: CustomDebugStringConvertible {
    public var debugDescription: String {
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

    public var swiftDescription: String {
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
