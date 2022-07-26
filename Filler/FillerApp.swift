import GameKit
import SwiftUI

@main
struct FillerApp: App {
    @State private var vc: UIViewController?
    @State private var isAuthenticated = false

    var body: some Scene {
        WindowGroup {
            GameView(game: ClientGame(game: .init(board: .init(width: 9, height: 9))))
                .overlay {
                    if let vc = vc {
                        HostedController(viewController: vc)
                    }
                }
                .onAppear {
                    GKLocalPlayer.local.authenticateHandler = { viewController, error in
                        if let error = error {
                            print(error)
                        }

                        if let viewController = viewController {
                            self.vc = viewController
                        }

                        check()
                    }
                }
        }
    }

    func check() {
        isAuthenticated = GKLocalPlayer.local.isAuthenticated
    }
}

struct HostedController: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

//protocol GameKitController: ObservableObject {
//    func authenticate
//}
//
//class GameKitController: ObservableObject {
//
//
//}
