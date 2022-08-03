import FillerKit
import SwiftUI

struct BoardOverlay: View {
    var turn: Player?
    var winner: Player?
    var board: Board
    var borderColor: BorderColor = .color(.black)
    var borderStyle: BorderStyle = .solid

    enum BorderColor {
        case currentPlayer
        case color(Color)
    }

    enum BorderStyle {
        case dashed
        case solid
    }

    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            if let turn = winner ?? turn {
                Path { path in
                    for edge in board.tileEdges(belongingToPlayer: turn) {
                        path.addPath(Path(frame.path(at: edge, boardWidth: board.width, boardHeight: board.height)))
                    }
                }
                .stroke(strokeColor(turn: turn), style: strokeStyle)
            }
        }
    }

    func strokeColor(turn: Player) -> some ShapeStyle {
        switch borderColor {
        case .currentPlayer:
            return board.startingTile(for: turn).color
        case .color(let color):
            return color
        }
    }

    var strokeStyle: StrokeStyle {
        StrokeStyle(
            lineWidth: borderStyle == .dashed ? 3 : 10,
            lineCap: .round,
            lineJoin: .round,
            miterLimit: 0,
            dash: borderStyle == .dashed ? [5, 6] : [],
            dashPhase: borderStyle == .dashed ? 15 : 0
        )
    }
}

extension CGRect {
    func point(at coordinate: TraceCoordinate, boardWidth: Int, boardHeight: Int) -> CGPoint {
        let xScale = size.width / CGFloat(boardWidth)
        let yScale = size.height / CGFloat(boardHeight)

        let x = minX + CGFloat(coordinate.x) * xScale
        let y = minY + CGFloat(coordinate.y) * yScale

        return CGPoint(x: x, y: y)
    }

    func path(at edge: TileEdge, boardWidth: Int, boardHeight: Int) -> CGPath {
        let start: TraceCoordinate
        let end: TraceCoordinate

        switch edge.direction {
        case .up:
            start = .init(x: edge.tile.col, y: edge.tile.row)
            end = .init(x: edge.tile.col + 1, y: edge.tile.row)

        case .down:
            start = .init(x: edge.tile.col, y: edge.tile.row + 1)
            end = .init(x: edge.tile.col + 1, y: edge.tile.row + 1)

        case .left:
            start = .init(x: edge.tile.col, y: edge.tile.row)
            end = .init(x: edge.tile.col, y: edge.tile.row + 1)

        case .right:
            start = .init(x: edge.tile.col + 1, y: edge.tile.row)
            end = .init(x: edge.tile.col + 1, y: edge.tile.row + 1)
        }

        let startPoint = point(at: start, boardWidth: boardWidth, boardHeight: boardHeight)
        let endPoint = point(at: end, boardWidth: boardWidth, boardHeight: boardHeight)

        return CGPath(
            rect: CGRect(
                x: startPoint.x,
                y: startPoint.y,
                width: abs(endPoint.x - startPoint.x),
                height: abs(endPoint.y - startPoint.y)
            ),
            transform: nil
        )
    }
}

struct BoardOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let board = Board.bordered

        BoardView(board: board)
            .overlay {
                BoardOverlay(turn: .playerOne, board: .preview)
            }
            .padding()

        BoardView(board: board)
            .overlay {
                BoardOverlay(turn: .playerOne, board: .preview, borderStyle: .dashed)
            }
            .padding()
    }
}
