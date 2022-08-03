import FillerKit
import Foundation

struct RemoteGameSummary: Decodable, Identifiable {
    let code: String
    let playerOne: UUID
    let playerTwo: UUID?

    var id: String { code }
}

struct RemoteGameDetail: Decodable {
    let code: String
    let playerOne: UUID
    let playerTwo: UUID?
    let turn: Player
    let board: Board
}

struct FillerAPI {
    static var playerID = UUID()
    static var baseURL = URL(staticString: "http://localhost:8080")
    private static let session = URLSession.shared

    private static var games: URL {
        baseURL/"games"
    }

    private static func games(code: String) -> URL {
        games/code
    }

    static func getGames() async throws -> [RemoteGameSummary] {
        struct Response: Decodable {
            let games: [RemoteGameSummary]
        }

        return try await get(games, decoding: Response.self).games
    }

    static func getGame(code: String) async throws -> RemoteGameDetail {
        try await get(games(code: code))
    }

    private struct JoinGameRequest: Encodable {
        let playerID: UUID
    }

    static func joinGame(code: String) async throws -> RemoteGameDetail {
        try await post(games(code: code)/"join", body: JoinGameRequest(playerID: playerID))
    }

    static func createGame(width: Int, height: Int) async throws -> RemoteGameDetail {
        struct Body: Encodable {
            let playerID: UUID
            let width: Int
            let height: Int
        }

        return try await post(games/"new", body: Body(playerID: playerID, width: width, height: height))
    }

    private struct MakeTurnRequest: Encodable {
        let playerID: UUID
        let selection: Tile
    }

    static func makeTurn(gameCode: String, selection: Tile) async throws -> RemoteGameDetail {
        try await post(games(code: gameCode)/"turn", body: MakeTurnRequest(playerID: playerID, selection: selection))
    }

    private static var gameSocket: URLSessionWebSocketTask?

    static func connectToGameSocket(code: String) -> AsyncStream<RemoteGameDetail> {
        let socket = URLSession.shared.webSocketTask(with: URL(staticString: "ws://localhost:8080")/"games"/code/"socket")
        socket.resume()
        gameSocket = socket

        return AsyncStream(unfolding: {
            while socket.state == .running {
                do {
                    let message = try await socket.receive()
                    log("Recieved socket message")
                    switch message {
                    case .data(let data):
                        log("Received socket data")
                        log(data.prettyJSON)

                    case .string(let string):
                        let data = string.data(using: .utf8)!
                        log("Received socket string")
                        log(data.prettyJSON)
                        let game = try JSONDecoder().decode(RemoteGameDetail.self, from: data)
                        return game

                    @unknown default:
                        fatalError("Unknown web socket task message: \(message)")
                    }
                } catch {
                    log(error.localizedDescription)
                    log("Cancelled socket task")
                    socket.cancel()
                }
            }

            return nil
        })
    }

    static func makeTurnOnSocket(gameCode: String, selection: Tile) async throws {
        try await sendSocketMessage(.turn(.init(playerID: playerID, selection: selection)))
    }

    static func joinOnSocket(gameCode: String) async throws {
        try await sendSocketMessage(.join(.init(playerID: playerID)))
    }

    private enum SocketMessage: Encodable {
        case join(JoinGameRequest)
        case turn(MakeTurnRequest)
    }

    private static func sendSocketMessage(_ message: SocketMessage) async throws {
        guard let socket = gameSocket else {
            // TODO: Throw error "not connected"
            return
        }

        let body = try JSONEncoder().encode(message)
        log("Sending socket message")
        log(body.prettyJSON)
        try await socket.send(.data(body))
        log("Sent socket message")
    }
}

extension URL {
    static func / (lhs: URL, rhs: String) -> URL {
        lhs.appendingPathComponent(rhs)
    }

    init(staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }
}

extension FillerAPI {
    private static func get<Response: Decodable>(_ url: URL, decoding: Response.Type = Response.self) async throws -> Response {
        try await make(request(url: url))
    }

    private static func post<Response: Decodable, Body: Encodable>(_ url: URL, body: Body) async throws -> Response {
        try await make(request(url: url, body: body))
    }

    private static func request(method: String = "GET", url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private static func request<Body: Encodable>(method: String = "POST", url: URL, body: Body) throws -> URLRequest {
        var request = request(method: method, url: url)
        request.httpBody = try JSONEncoder().encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private static func make<Response: Decodable>(_ request: URLRequest, decoding: Response.Type = Response.self) async throws -> Response {
        log("Making request: \(request)")
        if let body = request.httpBody {
            log(body.prettyJSON)
        }

        let (data, _) = try await session.data(for: request)
        log("Recevied response:\n\(data.prettyJSON)")
        return try JSONDecoder().decode(Response.self, from: data)
    }

    private static func log(_ message: @autoclosure () -> String) {
        #if DEBUG
        print(message())
        #endif
    }
}

extension Data {
    var prettyJSON: String {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: .mutableContainers),
              let data = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        else {
            return String(decoding: self, as: UTF8.self)
        }

        return String(decoding: data, as: UTF8.self)
    }
}
