enum Direction: String {
    case up = "U"
    case down = "D"
    case left = "L"
    case right = "R"
}

struct Instruction {
    let direction: Direction
    let amount: Int
    let color: Int
}


var instructions = [Instruction]()
var holes = [(row: Int, column: Int)]()
var row = 0
var column = 0

while let line = readLine() {
    //L 6 (#250012)
    let result = try #/(L|U|R|D) (\d+) \(\#(.+)\)/#.wholeMatch(in: line)!.output

    let instruction = Instruction(
        direction: Direction(rawValue: String(result.1))!,
        amount: Int(result.2)!,
        color: Int(result.3, radix: 16)!
    )

    instructions.append(instruction)

    for _ in 0..<instruction.amount {
        switch instruction.direction {
        case .up: row -= 1
        case .down: row += 1
        case .left: column -= 1
        case .right: column += 1
        }

        holes.append((row, column))
    }
}

let minRow = holes.map { $0.row }.min()!
let maxRow = holes.map { $0.row }.max()!
let minColumn = holes.map { $0.column }.min()!
let maxColumn = holes.map { $0.column }.max()!

var rowTemplate = Array(repeating: ".", count: maxColumn - minColumn + 1)
var grid = Array(repeating: rowTemplate, count: maxRow - minRow + 1)

for hole in holes {
    grid[hole.row - minRow][hole.column - minColumn] = "#"
}

holes.sort {
    if $0.row == $1.row {
        return $0.column < $1.column
    }

    return $0.row < $1.row
}

let height = grid.count
let width = grid[0].count

struct Position: Hashable { 
    let row: Int
    let column: Int 
}

var queue = Set<Position>()
for row in 0..<height {
    for column in 0..<width {
        if row == 0 || row == height - 1 || column == 0 || column == width - 1 {
            queue.insert(Position(row: row, column: column))
        }
    }
}

while let item = queue.popFirst() {
    let row = item.row
    let column = item.column

    if (grid[row][column] != ".") {
        continue
    }

    grid[row][column] = " "

    if row > 0 {
        queue.insert(Position(row: row - 1, column: column))
    }

    if row < height - 1 {
        queue.insert(Position(row: row + 1, column: column))
    }

    if column > 0 {
        queue.insert(Position(row: row, column: column - 1))
    }

    if column < width - 1 {
        queue.insert(Position(row: row, column: column + 1))
    }
}

print(grid.map { $0.count { $0 != " " }}.reduce(0, +), holes.count)