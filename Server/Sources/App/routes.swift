import FillerKit
import Fluent
import Vapor
import Foundation

func routes(_ app: Application) throws {
    // New game
    // POST /game/new (creates a new game on the server, returns the game details)
    // POST /game/:id/join (join a game, fails if the game has already been joined)
    //
    // Gameplay (rest)
    // GET /game/:id
    // POST /game/:id/turn (send the player id and the tile they picked, the server will update the state of the board)
    //
    // Gameplay (ws)
    // WS /game/:id
    //  - on connect: server sends the game state
    //  - on move: client sends player id and tile selection
    //             server sends player id and tile selection

    struct GetGamesResponse: Content {
        let games: [ServerGame.Response.Summary]
    }

    app.get("games") { req async throws -> GetGamesResponse in
        let games = try await ServerGame.query(on: req.db).all()
        return GetGamesResponse(games: games.map(\.response.summary))
    }

    struct NewGameRequest: Content {
        let playerID: UUID
        var width: Int = 10
        var height: Int = 10
    }

    app.post("games", "new") { req async throws -> ServerGame.Response.Full in
        let newGame = try req.content.decode(NewGameRequest.self)
        let game = ServerGame(width: newGame.width, height: newGame.height, playerOne: newGame.playerID)
        try await game.create(on: req.db)
        return game.response.full
    }

    struct JoinGameRequest: Content {
        let playerID: UUID
    }

    app.post("games", ":code", "join") { req async throws -> ServerGame.Response.Full in
        let game = try await req.game()

        guard game.playerTwo == nil else {
            throw Abort(.conflict)
        }

        let join = try req.content.decode(JoinGameRequest.self)
        game.playerTwo = join.playerID
        try await game.save(on: req.db)

        return game.response.full
    }

    app.get("games", ":code") { req async throws -> ServerGame.Response.Full in
        let game = try await req.game()
        return game.response.full
    }

    struct MakeTurnRequest: Content {
        let playerID: UUID
        let selection: Tile
    }

    enum MakeTurnError: DebuggableError {
        case noPlayerTwo
        case invalidPlayer
        case notPlayerTurn

        var identifier: String {
            switch self {
            case .noPlayerTwo:
                return "noPlayerTwo"
            case .invalidPlayer:
                return "invalidPlayer"
            case .notPlayerTurn:
                return "notPlayerTurn"
            }
        }

        var reason: String {
            switch self {
            case .noPlayerTwo:
                return "Player two has not joined the game yet"
            case .invalidPlayer:
                return "Player is not part of this game"
            case .notPlayerTurn:
                return "Player needs to wait for turn"
            }
        }
    }

    app.post("games", ":code", "turn") { req async throws -> ServerGame.Response.Full in
        let turn = try req.content.decode(MakeTurnRequest.self)
        return try await applyTurn(turn, on: req)
    }

    app.webSocket("games", ":code", "socket") { req, ws in
        do {
            // Send the current state of the game when a new connection is opened
            let game = try await req.game()
            try await ws.send(body: game.response.full)
        } catch {
            // Close the connection if the current state can't be sent
            try? await ws.close(code: .unacceptableData)
        }

        ws.onBinary { ws, buffer in
            do {
                let turn = try JSONDecoder().decode(MakeTurnRequest.self, from: buffer)
                let result = try await applyTurn(turn, on: req)
                try await ws.send(body: result)

                if result.board.winner != nil {
                    try await ws.close()
                }
            } catch {
                try? await ws.send(error.localizedDescription)
            }
        }
    }

    func applyTurn(_ turn: MakeTurnRequest, on req: Request) async throws -> ServerGame.Response.Full {
        let game = try await req.game()

        guard game.playerTwo != nil else {
            throw MakeTurnError.noPlayerTwo
        }

        guard [game.playerOne, game.playerTwo].contains(turn.playerID) else {
            throw MakeTurnError.invalidPlayer
        }

        guard game.turn == turn.playerID else {
            throw MakeTurnError.notPlayerTurn
        }

        var board = game.board
        board.capture(turn.selection, for: game.playerTurn)
        game.update(with: board)
        try game.toggleTurn()
        try await game.save(on: req.db)
        return game.response.full
    }
}

extension Request {
    func game() async throws -> ServerGame {
        let code = try self.parameters.require("code")

        guard let game = try await ServerGame.query(on: self.db).filter(\.$code == code).first() else {
            throw Abort(.notFound)
        }

        return game
    }
}

extension WebSocket {
    func send<Body: Encodable>(body: Body) async throws {
        let data = try JSONEncoder().encode(body)
        try await send(data.base64Bytes())
    }
}
