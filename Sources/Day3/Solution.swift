import Foundation

print("Part 1: \(part1(Input.lines))")
print("Part 2: \(part2(Input.lines))")

func part1(_ lines: [String]) -> Int {        
    let data = lines.map { $0.data(using: .utf8)! }
    
    let rowCount = data.count
    let columnCount = data[0].count
    
    let isDot = { (row: Int, column: Int) in
        data[row][column] == 46
    }
    
    let isDigit = { (row: Int, column: Int) in
        let value = data[row][column]
        return value >= 48 && value <= 57 // not a digit
    }
    
    let isSymbol = { (row: Int, column: Int) in
        return !isDot(row, column) && !isDigit(row, column)
    }
    
    let checkSurrounding = { (row: Int, column: Int) in
        let left = max(0, column - 1)
        let top = max(0, row - 1)
        let right = min(column + 1, columnCount - 1)
        let bottom = min(row + 1, rowCount - 1)
        
        return isSymbol(top, left)
            || isSymbol(top, column)
            || isSymbol(top, right)
            || isSymbol(row, left)
            || isSymbol(row, right)
            || isSymbol(bottom, left)
            || isSymbol(bottom, column)
            || isSymbol(bottom, right)
    }
    
    let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var numbers: [Int] = []
    
    for row in 0..<rowCount {
        var currentRun: String = ""
        var keepCurrentRun: Bool = false
        
        for column in 0..<columnCount {
            if isDigit(row, column) {
                currentRun.append(digits[Int(data[row][column]) - 48])
                keepCurrentRun = keepCurrentRun || checkSurrounding(row, column)
            } else {
                if !currentRun.isEmpty && keepCurrentRun {
                    numbers.append(Int(currentRun)!)
                }
                currentRun = ""
                keepCurrentRun = false
            }
        }
        
        if !currentRun.isEmpty && keepCurrentRun {
            numbers.append(Int(currentRun)!)
        }
    }
    
    return numbers.reduce(0, +)
}

func part2(_ lines: [String]) -> Int {        
    let rows = lines.map { $0.data(using: .utf8)! }
    
    let width = rows[0].count
    let height = rows.count
    
    let isDigit = { (x: Int, y: Int) in
        let value = rows[y][x]
        return value >= 48 && value <= 57 // not a digit
    }
    
    let checkSurrounding = { (x: Int, y: Int) in
        let left = max(0, x - 1)
        let top = max(0, y - 1)
        let right = min(x + 1, width - 1)
        let bottom = min(y + 1, height - 1)
        
        return [
            GearPosition(x: left, y: top),
            GearPosition(x: x, y: top),
            GearPosition(x: right, y: top),
            GearPosition(x: left, y: y),
            GearPosition(x: right, y: y),
            GearPosition(x: left, y: bottom),
            GearPosition(x: x, y: bottom),
            GearPosition(x: right, y: bottom),
        ].filter { pos in
            rows[pos.y][pos.x] == 42
        }
    }
    
    let digits = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    
    var gearPositionMap: [GearPosition: [Int]] = [:]
    
    for y in 0..<height {
        var currentRun: String = ""
        var gearsFound: Set<GearPosition> = Set()
        
        for x in 0..<width {
            if isDigit(x, y) {
                currentRun.append(digits[Int(rows[y][x]) - 48])
                gearsFound = gearsFound.union(checkSurrounding(x, y))
            } else {
                if !currentRun.isEmpty && !gearsFound.isEmpty {
                    let num = Int(currentRun)!
                    
                    for gear in gearsFound {
                        var current = gearPositionMap[gear] ?? []
                        current.append(num)
                        gearPositionMap[gear] = current
                    }
                }
                currentRun = ""
                gearsFound = []
            }
        }
        
        if !currentRun.isEmpty && !gearsFound.isEmpty {
            let num = Int(currentRun)!
            
            for gear in gearsFound {
                var current = gearPositionMap[gear] ?? []
                current.append(num)
                gearPositionMap[gear] = current
            }
        }
    }
    
    return gearPositionMap.values
        .filter({ $0.count == 2 })
        .map { $0[0] * $0[1] }
        .reduce(0, +)
}

struct GearPosition: Hashable {
    let x: Int
    let y: Int
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
