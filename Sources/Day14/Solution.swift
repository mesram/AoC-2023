import Foundation


let input = Input.lines

print("Part 1: \(part1(input))")
print("Part 2: \(part2(input))")

func part1(_ input: [String]) -> Int {
    let rows = input.map { $0.split(separator: "").map(String.init) }

    let height = rows.count

    var sum = 0
    for col in  0..<rows[0].count {
        var next = height
        for row in 0..<height {
            switch rows[row][col] {
                case "O":
                    // "move" the rock by just adding where it would land to the total
                    sum += next
                    next -= 1 // the next rock will be 1 unit below the current position
                case "#":
                    // reset the next rock position to 1 unit below the stationary rock
                    next = height - row - 1
                default:
                    continue
            }
        }
    }

    return sum
}

func shiftUp(
    _ rows: [[String]]
) -> [[String]] {
    let height = rows.count

    let blankRow = Array(repeating: ".", count: rows[0].count)
    var result = Array(repeating: blankRow, count: rows.count)

    for col in  0..<rows[0].count {
        var nextWeight = 0
        for row in 0..<height {
            switch rows[row][col] {
                case "O":
                 result[nextWeight][col] = "O"
                    nextWeight += 1
                case "#":
                 result[row][col] = "#"
                    nextWeight = row + 1
                default:
                    continue
            }
        }
    }

    return result
}

func rotate(
    _ rows: [[String]] 
) -> [[String]] {
    let dim = rows.count

    var  result = rows

    for col in  0..<rows[0].count {
        for row in 0..<dim {
         result[col][dim - row - 1] = rows[row][col]
        }
    }

    return result
}

func part2(_ input: [String]) -> Int {
    var rows = input.map { $0.split(separator: "").map(String.init) }

    var results: [[[String]]] = []
    for i in 0...1000 {
        rows = rotate(shiftUp(rows)) // shift North and rotate clockwise
        rows = rotate(shiftUp(rows)) // shift West
        rows = rotate(shiftUp(rows)) // shift South
        rows = rotate(shiftUp(rows)) // shift East

        if results.contains(rows) {
            let cycleStart = results.firstIndex(of: rows)!
            let cycleLength = i - cycleStart

            let value = results[cycleStart + ((1_000_000_000 - 1 - cycleStart) % cycleLength)]

            // weight for the result
            return value.enumerated().map {
                (rows.count - $0.offset) * $0.element.filter { $0 == "O" }.count
            }.reduce(0, +)
        }

        results.append(rows)
    }

    fatalError("Took too long")
}

struct Input {
    static let lines: [String] = {
        var lines: [String] = []
        while let line = readLine() {
            lines.append(line)
        }
        return lines
    }()
}