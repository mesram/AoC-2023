import Foundation

let (total, gaps) = calculateDistances(Input.lines)

print("Part 1: \(total + gaps)")
print("Part 2: \(total + gaps * (1000000 - 1))")

func calculateDistances(_ lines: [String]) -> (total: Int, gaps: Int) {
    var populatedRows: Set<Int> = Set()
    var populatedColumns: Set<Int> = Set()

    let input = lines.enumerated()
        .flatMap {
            let row = $0.offset
            return $0.element
                .split(separator: "")
                .enumerated()
                .compactMap {
                    if ($0.element == "#") {
                        let column = $0.offset
                        populatedRows.insert(row)
                        populatedColumns.insert(column)
                        
                        return (row: row, column: column)
                    }

                    return nil
                }
        }

    var gaps = 0

    var total = 0
    for i in 0..<input.count - 1 {
        let (startRow, startColumn) = input[i]
        for j in (i+1)..<input.count {
            let (endRow, endColumn) = input[j]
            
            total += abs(endRow - startRow)
            total += abs(endColumn - startColumn)
            
            gaps += stride(from: startRow, to: endRow, by: startRow < endRow ? 1 : -1).filter { !populatedRows.contains($0) }.count
            gaps += stride(from: startColumn, to: endColumn, by: startColumn < endColumn ? 1 : -1).filter { !populatedColumns.contains($0) }.count
        }
    }

    return (total, gaps)
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