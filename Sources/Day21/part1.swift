import Foundation

var input = [[String]]()

while let line = readLine() {
    input.append(line.split(separator: "").map(String.init))
}

let height = input.count
let width = input[0].count

struct Position: Hashable {
    let row: Int
    let column: Int
}

func update(positions: inout Set<Position>) {
    var nextPositions = Set<Position>()

    for position in positions {
        if position.row > 0 && input[position.row - 1][position.column] != "#" {
            nextPositions.insert(.init(row: position.row - 1, column: position.column))
        }

        if position.row < height - 1 && input[position.row + 1][position.column] != "#" {
            nextPositions.insert(.init(row: position.row + 1, column: position.column))
        }

        if position.column > 0 && input[position.row][position.column - 1] != "#" {
            nextPositions.insert(.init(row: position.row, column: position.column - 1))
        }

        if position.column < width - 1 && input[position.row][position.column + 1] != "#" {
            nextPositions.insert(.init(row: position.row, column: position.column + 1))
        }
    }

    positions = nextPositions
}

var positions: Set = [Position(row: height / 2, column: width / 2)]
for _ in 0..<64 {
    update(positions: &positions)
}

print(positions.count)
