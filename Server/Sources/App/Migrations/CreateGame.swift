import FillerKit
import Fluent

struct CreateServerGame: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(ServerGame.schema)
            .id()
            .field("code", .string, .required)
            .field("width", .int, .required)
            .field("height", .int, .required)
            .field("tiles", .array(of: .int), .required)
            .field("player_one", .uuid, .required)
            .field("player_two", .uuid)
            .field("turn", .uuid, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(ServerGame.schema)
            .delete()
    }
}
