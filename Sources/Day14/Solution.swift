import Foundation


let input = Input.lines

print("Part 1: \(part1(input))")
print("Part 2: \(part2(input))")

func part1(_ input: [String]) -> Int {
    let rows = input.map { $0.split(separator: "").map(String.init) }

    let height = rows.count

    var sum = 0
    for col in  0..<rows[0].count {
        var nextWeight = height
        for row in 0..<height {
            switch rows[row][col] {
                case "O":
                    sum += nextWeight
                    nextWeight -= 1
                case "#":
                    nextWeight = height - row - 1
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
    var  nextRows = Array(repeating: blankRow, count: rows.count)

    for col in  0..<rows[0].count {
        var nextWeight = 0
        for row in 0..<height {
            switch rows[row][col] {
                case "O":
                    nextRows[nextWeight][col] = "O"
                    nextWeight += 1
                case "#":
                    nextRows[row][col] = "#"
                    nextWeight = row + 1
                default:
                    continue
            }
        }
    }

    return nextRows
}

func rotate(
    _ rows: [[String]] 
) -> [[String]] {
    let dim = rows.count

    var  nextRows = rows

    for col in  0..<rows[0].count {
        for row in 0..<dim {
            nextRows[col][dim - row - 1] = rows[row][col]
        }
    }

    return nextRows
}

func part2(_ input: [String]) -> Int {
    var rows = input.map { $0.split(separator: "").map(String.init) }

    var results: [String] = []
    for i in 0...1000 {
        rows = rotate(shiftUp(rows)) // shift North and rotate clockwise
        rows = rotate(shiftUp(rows)) // shift West
        rows = rotate(shiftUp(rows)) // shift South
        rows = rotate(shiftUp(rows)) // shift East

        let resultString = rows.map { $0.joined() }.joined(separator: "\n")
        if results.contains(resultString) {
            let cycleStart = results.firstIndex(of: resultString)!
            let cycleLength = i - cycleStart

            let value = results[cycleStart + ((1_000_000_000 - 1 - cycleStart) % cycleLength)]

            // weight for the result
            return value.split(separator: "\n").enumerated().map {
                (rows.count - $0.offset) * $0.element.filter { $0 == "O" }.count
            }.reduce(0, +)
        }

        results.append(resultString)
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