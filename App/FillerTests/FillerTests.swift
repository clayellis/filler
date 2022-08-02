//
//  FillerTests.swift
//  FillerTests
//
//  Created by Clay Ellis on 6/24/22.
//

import XCTest
@testable import Filler

class FillerTests: XCTestCase {
    func testTileLookup() throws {
        let board = Board(unsafeWidth: 3, height: 3, tiles: [
            .red,       .yellow,    .green,
            .blue,      .purple,    .orange,
            .yellow,    .purple,    .red
        ])

        XCTAssertEqual(board[row: 0, col: 0], .red)
        XCTAssertEqual(board[row: 1, col: 0], .blue)
        XCTAssertEqual(board[row: 2, col: 0], .yellow)
        XCTAssertEqual(board[row: 0, col: 1], .yellow)
        XCTAssertEqual(board[row: 1, col: 1], .purple)
        XCTAssertEqual(board[row: 2, col: 1], .purple)
        XCTAssertEqual(board[row: 0, col: 2], .green)
        XCTAssertEqual(board[row: 1, col: 2], .orange)
        XCTAssertEqual(board[row: 2, col: 2], .red)

    }

    func testTilesBelongingToPlayerOneDirectionDown() throws {
        let board = Board(unsafeWidth: 3, height: 3, tiles: [
            .yellow,    .yellow,    .yellow,
            .green,     .green,     .green,
            .green,     .yellow,    .green
        ])

        print(board.debugDescription)

        let tiles = board.tiles(belongingToPlayer: .playerOne)
        XCTAssertEqual(tiles.count, 5)
        XCTAssertEqual(tiles, [
            .init(row: 2, col: 0),
            .init(row: 1, col: 0),
            .init(row: 1, col: 1),
            .init(row: 1, col: 2),
            .init(row: 2, col: 2)
        ])
    }

    func testTilesBelongingToPlayerOneDirectionLeft() throws {
        let board = Board(unsafeWidth: 3, height: 3, tiles: [
            .green,     .green,     .yellow,
            .yellow,    .green,     .yellow,
            .green,     .green,     .yellow
        ])

        let tiles = board.tiles(belongingToPlayer: .playerOne)
        XCTAssertEqual(tiles.count, 5)
        XCTAssertEqual(tiles, [
            .init(row: 2, col: 0),
            .init(row: 2, col: 1),
            .init(row: 1, col: 1),
            .init(row: 0, col: 1),
            .init(row: 0, col: 0)
        ])
    }

    func testMeasureTilesBelongingToPlayer() throws {
        let board = Board.complex
        self.measure {
            _ = board.tiles(belongingToPlayer: .playerTwo)
        }
    }

    func testMeasureCapture() throws {
        var board = Board.complex
        self.measure {
            board.capture(.green, for: .playerTwo)
        }
    }
}

extension Board {
    /// 🟥🟥🟥🟪🟪🟪🟩🟪🟪🟪
    /// 🟥🟥🟪🟪🟪🟪🟪🟪🟪🟩
    /// 🟥🟥🟥🟪🟪🟪🟪🟪🟨🟪
    /// 🟥🟥🟪🟪🟪🟪🟩🟪🟪🟪
    /// 🟥🟥🟥🟪🟪🟨🟨🟪🟪🟩
    /// 🟥🟥🟥🟪🟪🟪🟩🟪🟪🟪
    /// ⬛️🟥🟥🟥🟥🟥🟪🟪🟩🟪
    /// 🟥🟥🟥🟥🟥🟥🟥🟪🟪⬛️
    /// 🟥🟥🟥🟥🟥🟥🟪🟪🟪🟪
    /// 🟥🟥🟥🟥🟥🟥⬛️🟨🟪🟥
    static let complex = Board(unsafeWidth: 10, height: 10, tiles: [.red, .red, .red, .purple, .purple, .purple, .green, .purple, .purple, .purple, .red, .red, .purple, .purple, .purple, .purple, .purple, .purple, .purple, .green, .red, .red, .red, .purple, .purple, .purple, .purple, .purple, .yellow, .purple, .red, .red, .purple, .purple, .purple, .purple, .green, .purple, .purple, .purple, .red, .red, .red, .purple, .purple, .yellow, .yellow, .purple, .purple, .green, .red, .red, .red, .purple, .purple, .purple, .green, .purple, .purple, .purple, .orange, .red, .red, .red, .red, .red, .purple, .purple, .green, .purple, .red, .red, .red, .red, .red, .red, .red, .purple, .purple, .orange, .red, .red, .red, .red, .red, .red, .purple, .purple, .purple, .purple, .red, .red, .red, .red, .red, .red, .orange, .yellow, .purple, .red])


    /// ⬛️🟨🟩🟦🟩🟩🟩🟩🟩🟩
    /// 🟨🟦🟥🟥🟪🟩🟩🟩🟩🟩
    /// 🟨⬛️🟥🟨🟪🟪🟩🟩🟩🟩
    /// 🟪🟦🟦🟨🟥🟩🟥🟩🟩🟩
    /// 🟦🟪🟨🟦🟪🟩🟩🟩🟩🟩
    /// 🟦🟦🟪⬛️⬛️🟦🟪🟩🟩🟩
    /// 🟦🟦🟦🟦🟦🟪🟪🟩⬛️🟪
    /// 🟦🟦🟦🟦🟪🟥🟥🟦🟥🟦
    /// 🟦🟦🟦🟦🟦⬛️🟨⬛️🟥⬛️
    /// 🟦🟦⬛️🟪🟦🟦🟨⬛️🟪🟦
    static let moderate = Board(unsafeWidth: 10, height: 10, tiles: [.orange, .yellow, .green, .blue, .green, .green, .green, .green, .green, .green, .yellow, .blue, .red, .red, .purple, .green, .green, .green, .green, .green, .yellow, .orange, .red, .yellow, .purple, .purple, .green, .green, .green, .green, .purple, .blue, .blue, .yellow, .red, .green, .red, .green, .green, .green, .blue, .purple, .yellow, .blue, .purple, .green, .green, .green, .green, .green, .blue, .blue, .purple, .orange, .orange, .blue, .purple, .green, .green, .green, .blue, .blue, .blue, .blue, .blue, .purple, .purple, .green, .orange, .purple, .blue, .blue, .blue, .blue, .purple, .red, .red, .blue, .red, .blue, .blue, .blue, .blue, .blue, .blue, .orange, .yellow, .orange, .red, .orange, .blue, .blue, .orange, .purple, .blue, .blue, .yellow, .orange, .purple, .blue])
}
