import App
import Vapor

/*

 docker run --name postgres \
 -e POSTGRES_DB=vapor_database \
 -e POSTGRES_USER=vapor_username \
 -e POSTGRES_PASSWORD=vapor_password \
 -p 5432:5432 -d postgres

 */

var env = try Environment.detect()
try LoggingSystem.bootstrap(from: &env)
let app = Application(env)
defer { app.shutdown() }
try configure(app)
// Run migrations
try app.autoMigrate().wait()
try app.run()
