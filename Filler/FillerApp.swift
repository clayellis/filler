//
//  FillerApp.swift
//  Filler
//
//  Created by Clay Ellis on 6/24/22.
//

import SwiftUI

@main
struct FillerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(game: Game(board: .init(width: 9, height: 9)))
        }
    }
}
