import Foundation


let blocks = Input.lines.joined(separator: "\n").split(separator: "\n\n")

let mapped = blocks.map {
    let rows = $0.split(separator: "\n").map(String.init)
    var columns = Array(repeating: "", count: rows[0].count)

    for row in rows {
        for (index, char) in row.enumerated() {
            columns[index] += String(char)
        }
    }

    return (rows: rows, columns: columns)
}

print("Part 1: \(solution(mapped))")
print("Part 2: \(solution(mapped, match: { zip($0, $1).filter({ $0.0 != $0.1 }).count == 1 }))")

func solution(
    _ input: [(rows: [String], columns: [String])],
    match: (String, String) -> Bool = { $0 == $1 }
) -> Int {
    return input.map { 
        let col = findReflection($0.columns, match: match) ?? 0
        let row = findReflection($0.rows, match: match) ?? 0

        return  col + 100 * row
    }.reduce(0, +)
}

func findReflection(_ rows: [String], match: (String, String) -> Bool) -> Int? {
    for index in 0..<rows.count - 1 {
        let width = min(index + 1, rows.count - (index + 1))

        let left = (0..<width).map { rows[index - $0] }.joined()
        let right = (0..<width).map { rows[index + $0 + 1] }.joined()

        if match(left, right) {
            return index + 1
        }
    }

    return nil
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