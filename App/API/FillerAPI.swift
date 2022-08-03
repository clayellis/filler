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

    static func joinGame(code: String) async throws -> RemoteGameDetail {
        struct Body: Encodable {
            let playerID: UUID
        }

        return try await post(games(code: code)/"join", body: Body(playerID: playerID))
    }

    static func createGame(width: Int, height: Int) async throws -> RemoteGameDetail {
        struct Body: Encodable {
            let playerID: UUID
            let width: Int
            let height: Int
        }

        return try await post(games/"new", body: Body(playerID: playerID, width: width, height: height))
    }

    static func makeTurn(gameCode: String, selection: Tile) async throws -> RemoteGameDetail {
        struct Body: Encodable {
            let playerID: UUID
            let selection: Tile
        }

        return try await post(games(code: gameCode)/"turn", body: Body(playerID: playerID, selection: selection))
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
