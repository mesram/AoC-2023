enum Direction: String {
    case right
    case down
    case left
    case up
}

struct Instruction {
    let direction: Direction
    let distance: Int
}

var instructions = [Instruction]()

while let line = readLine() {
    //L 6 (#250012)
    let result = try #/(L|U|R|D) (\d+) \(\#(.....)(\d)\)/#.wholeMatch(in: line)!.output

    let direction: Direction =
        switch String(result.4) {
        case "0": .right
        case "1": .down
        case "2": .left
        case "3": .up
        default: fatalError()
        }

    let distance = Int(result.3, radix: 16)!

    let instruction = Instruction(
        direction: direction,
        distance: distance
    )

    instructions.append(instruction)
}

struct RightRange {
    var topRow: Int
    var bottomRow: Int
    var leftColumn: Int
}

struct LeftRange {
    var topRow: Int
    var bottomRow: Int
    var rightColumn: Int
}

var rightRanges = [RightRange]() // ranges extending rightwards
var leftRanges = [LeftRange]() // ranges extending leftwards

var perimeter = 0
var row = 0
var column = 0
for i in instructions.indices {
    let previous = i == 0 ? instructions.last! : instructions[i - 1]
    let current = instructions[i]
    let next = instructions[(i + 1) % instructions.count]

    perimeter += current.distance

    switch current.direction {
    case .down:
        // inside direction == left
        let item = LeftRange(
            topRow: row + (previous.direction == .right ? +1 : 0), 
            bottomRow: row + current.distance + (next.direction == .left ? -1 : 0), 
            rightColumn:  column - 1
        )

        leftRanges.append(item)

        row += current.distance
    case .right:
        // inside direction == below
        column += current.distance
    case .up:
        // inside direction == right
        let item = RightRange(
            topRow: row - current.distance + (next.direction == .right ? +1 : 0), 
            bottomRow: row + (previous.direction == .left ? -1 : 0), 
            leftColumn: column + 1
        )

        rightRanges.append(item)

        row -= current.distance
    case .left:
        // inside direction == above
        column -= current.distance
    }

    // print("\(current.direction) \(current.distance) -> (\(row), \(column))")
}

rightRanges.sort { r1, r2 in
    if r1.topRow == r2.topRow {
        return r1.leftColumn < r2.leftColumn
    }

    return r1.topRow < r2.topRow
}

leftRanges.sort { r1, r2 in
    if r1.rightColumn == r2.rightColumn {
        return r1.topRow < r2.topRow
    }

    return r1.rightColumn < r2.rightColumn
}

var areas = 0
for rightRange in rightRanges {
    var topRow = rightRange.topRow
    var bottomRow = rightRange.bottomRow

    let column = rightRange.leftColumn
    let overlaps = leftRanges.filter { $0.rightColumn >= column && $0.topRow <= bottomRow && $0.bottomRow >= topRow }

    while topRow <= bottomRow {
        let topOverlap = overlaps
            .filter { $0.topRow <= topRow && $0.bottomRow >= topRow }
            .first!

        let bottomOverlap = overlaps
            .filter { $0.topRow <= bottomRow && $0.bottomRow >= bottomRow }
            .first!

        if topOverlap.rightColumn < bottomOverlap.rightColumn {
            // subtract top then bottom
            let endRow = min(topOverlap.bottomRow, bottomRow)

            let overlap =  endRow - topRow + 1
            if overlap == 0 {
                fatalError("Somehow got 0 overlap")
            }
            areas += overlap * (topOverlap.rightColumn - column + 1)
            topRow += overlap
        } else {
            // substract bottom then top
            // subtract top then bottom
            let startRow = max(bottomOverlap.topRow, topRow)

            let overlap =  bottomRow - startRow + 1
            if overlap == 0 {
                fatalError("Somehow got 0 overlap")
            }
            areas += overlap * (bottomOverlap.rightColumn - column + 1)
            bottomRow -= overlap
        }
    }
}

print(perimeter + areas)
