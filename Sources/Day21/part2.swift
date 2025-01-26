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
        nextPositions.insert(.init(row: position.row - 1, column: position.column))
        nextPositions.insert(.init(row: position.row + 1, column: position.column))
        nextPositions.insert(.init(row: position.row, column: position.column - 1))
        nextPositions.insert(.init(row: position.row, column: position.column + 1))
    }

    positions = nextPositions.filter { position in
        var row = position.row
        var column = position.column

        while row < 0 {
            row += height
        }

        while row >= height {
            row -= height
        }

        while column < 0 {
            column += width
        }

        while column >= width {
            column -= width
        }

        return input[row][column] != "#"
    }
}

var positions: Set = [Position(row: height / 2, column: width / 2)]
for _ in 0..<65 {
    update(positions: &positions)
}

print(positions.count)

for _ in 0..<131 {
    update(positions: &positions)
}

print(positions.count)

for _ in 0..<131 {
    update(positions: &positions)
}

print(positions.count)

func calculate(_ a: Int, _ b: Int, _ c: Int) {
    let steps = 202300
    print(a * steps * steps + b * steps + c)
}

calculate(15094, 15196, 3835)


