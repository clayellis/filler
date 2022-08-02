import FillerKit
import Fluent
import Vapor

final class ServerGame: Model {
    static let schema = "games"

    static func generateCode() -> String {
        String.generateRandom()
    }

    @ID(key: .id)
    var id: UUID?

    @Field(key: "code")
    var code: String

    @Field(key: "width")
    var width: Int

    @Field(key: "height")
    var height: Int

    @Field(key: "tiles")
    var tiles: [Tile]

    @Field(key: "player_one")
    var playerOne: UUID

    @OptionalField(key: "player_two")
    var playerTwo: UUID?

    @Field(key: "turn")
    var turn: UUID

    init() {}

    init(
        id: UUID? = nil,
        code: String? = nil,
        width: Int,
        height: Int,
        tiles: [Tile]? = nil,
        playerOne: UUID,
        playerTwo: UUID? = nil,
        turn: UUID? = nil
    ) {
        self.id = id
        self.code = code ?? Self.generateCode()
        self.width = width
        self.height = height
        if let tiles = tiles {
            self.tiles = tiles
        } else {
            let board = Board(width: width, height: height)
            self.tiles = board.tiles
        }
        self.playerOne = playerOne
        self.playerTwo = playerTwo
        self.turn = turn ?? playerOne
    }

    var board: Board {
        Board(unsafeWidth: width, height: height, tiles: tiles)
    }

    var playerTurn: Player {
        guard playerTwo != nil else {
            return .playerOne
        }

        return turn == playerOne ? .playerOne : .playerTwo
    }

    func update(with board: Board) {
        self.tiles = board.tiles
    }

    enum ServerGameError: DebuggableError {
        case noPlayerTwo

        var identifier: String {
            switch self {
            case .noPlayerTwo:
                return "noPlayerTwo"
            }
        }

        var reason: String {
            switch self {
            case .noPlayerTwo:
                return "Failed to toggle turn because player two was nil"
            }
        }
    }

    func toggleTurn() throws {
        guard let playerTwo = playerTwo else {
            throw ServerGameError.noPlayerTwo
        }

        turn = turn == playerOne ? playerTwo : playerOne
    }
}

extension String: RandomGeneratable {
    public static func generateRandom() -> String {
        "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            .randomSample(count: 6)
            .map(String.init)
            .joined(separator: "")
    }
}

extension ServerGame {
    var response: Response {
        .init(self)
    }

    struct Response {
        struct Summary: Content {
            let code: String
            let playerOne: UUID
            let playerTwo: UUID?
        }
        
        struct Full: Content {
            let code: String
            let playerOne: UUID
            let playerTwo: UUID?
            let turn: Player
            let board: Board
        }

        private let game: ServerGame

        fileprivate init(_ game: ServerGame) {
            self.game = game
        }

        var summary: Summary {
            .init(game)
        }

        var full: Full {
            .init(game)
        }
    }
}

extension ServerGame.Response.Summary {
    init(_ game: ServerGame) {
        self.init(code: game.code, playerOne: game.playerOne, playerTwo: game.playerTwo)
    }
}

extension ServerGame.Response.Full {
    init(_ game: ServerGame) {
        self.init(
            code: game.code,
            playerOne: game.playerOne,
            playerTwo: game.playerTwo,
            turn: game.playerTurn,
            board: game.board
        )
    }
}
