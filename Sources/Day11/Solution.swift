import Foundation

var populatedRows: Set<Int> = Set()
var populatedColumns: Set<Int> = Set()

let input = Input.lines.enumerated()
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

var spaces = 0

var total = 0
for i in 0..<input.count - 1 {
    for j in (i+1)..<input.count {
        let (startRow, endRow) = input[i].row < input[j].row ? (input[i].row, input[j].row) : (input[j].row, input[i].row)
        let (startColumn, endColumn) = input[i].column < input[j].column ? (input[i].column, input[j].column) : (input[j].column, input[i].column)
        
        total += endRow - startRow
        total += endColumn - startColumn
        
        spaces += (startRow..<endRow).filter { !populatedRows.contains($0) }.count
        spaces += (startColumn..<endColumn).filter { !populatedColumns.contains($0) }.count
    }
}

print("Part 1: \(total + spaces)")
print("Part 2: \(total + spaces * (1000000 - 1))")

struct Input {
    static let lines: [String] = {
        var lines: [String] = []
        while let line = readLine() {
            lines.append(line)
        }
        return lines
    }()
}