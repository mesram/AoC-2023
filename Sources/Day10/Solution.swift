import Foundation

let input = Input.lines
    .map {
        return $0.map { Tile(rawValue: $0)! }
    }

print("Part 1: \(part1(input))")
print("Part 2: \(part2(input))")

enum Tile: Character {
    case start = "S"
    case ground = "."

    case vertical = "|"
    case horizontal = "-"

    case northeast = "L"
    case northwest = "J"
    case southwest = "7"
    case southeast = "F"

    var isConnectedToBottom: Bool {
        self == .vertical || self == .southwest || self == .southeast
    }

    var isConnectedToTop: Bool {
        self == .vertical || self == .northwest || self == .northeast
    }

    var isConnectedToLeft: Bool {
        self == .horizontal || self == .southwest || self == .northwest
    }

    var isConnectedToRight: Bool {
        self == .horizontal || self == .southeast || self == .northeast
    }
}

func startPosition(_ input: [[Tile]]) -> (row: Int, column: Int) {
    for row in input.enumerated() {
        for column in row.element.enumerated() {
            if column.element == .start {
                return (row: row.offset, column: column.offset)
            }
        }
    }

    fatalError()
}

func deriveStartTile(position: (row: Int, column: Int), map: [[Tile]]) -> Tile {
    let top: Bool = position.row > 0 && map[position.row - 1][position.column].isConnectedToBottom
    let bottom: Bool = position.row < map.count - 1 && map[position.row + 1][position.column].isConnectedToTop

    let left: Bool = position.column > 0 && map[position.row][position.column-1].isConnectedToRight
    let right: Bool = position.column < map[0].count - 1 && map[position.row][position.column + 1].isConnectedToLeft

    return if top && left { .northwest }
        else if top && right { .northeast }
        else if top && bottom { .vertical }
        else if left && right { .horizontal }
        else if bottom && left { .southwest }
        else if bottom && right { .southeast }
        else { fatalError() }
}

func part1(_ input: [[Tile]]) -> Int {
    let start = startPosition(input)
    var map = input
    map[start.row][start.column] = deriveStartTile(position: start, map: input)

    var visited: Set<Coordinate> = Set()
    var queue: Set<Coordinate> = Set()
    queue.insert(.init(start.row, start.column))

    var step = -1
    while !queue.isEmpty {
        step += 1

        var next: Set<Coordinate> = Set()
        for index in queue {
            let tile = map[index.row][index.column]
            visited.insert(index)

            if tile.isConnectedToTop { next.insert(.init(index.row - 1, index.column)) }
            if tile.isConnectedToBottom { next.insert(.init(index.row + 1, index.column)) }
            if tile.isConnectedToLeft{ next.insert(.init(index.row, index.column - 1)) }
            if tile.isConnectedToRight { next.insert(.init(index.row, index.column + 1)) }
        }

        queue.removeAll()

        for index in next {
            if !visited.contains(index) {
                queue.insert(index)
            }
        }
    }

    return step
}

func part2(_ input: [[Tile]]) -> Int {
    let start = startPosition(input)
    var map = input
    map[start.row][start.column] = deriveStartTile(position: start, map: input)

    var visited: Set<Coordinate> = Set()
    var queue: Set<Coordinate> = Set()
    queue.insert(.init(start.row, start.column))

    while !queue.isEmpty {
        var next: Set<Coordinate> = Set()
        for index in queue {
            let tile = map[index.row][index.column]
            visited.insert(index)

            if tile.isConnectedToTop { next.insert(.init(index.row - 1, index.column)) }
            if tile.isConnectedToBottom { next.insert(.init(index.row + 1, index.column)) }
            if tile.isConnectedToLeft{ next.insert(.init(index.row, index.column - 1)) }
            if tile.isConnectedToRight { next.insert(.init(index.row, index.column + 1)) }
        }

        queue.removeAll()

        for index in next {
            if !visited.contains(index) {
                queue.insert(index)
            }
        }
    }

    let height = map.count
    let width = map[0].count

    var insideCount = 0

    for row in 0..<height {
        var line = ""

        for column in 0..<width {
            if visited.contains(.init(row, column)) {
                line.append(String(map[row][column].rawValue))
                continue
            }

            var verticalCount = 0
            var partialVerticalCount = 0

            var horizontalCount = 0
            var partialHorizontalCount = 0

            visited.forEach {
                let tile = map[$0.row][$0.column]

                if ($0.row == row && $0.column < column) {
                    // from the left
                    switch tile {
                        case .vertical: verticalCount += 1
                        
                        case .southwest: partialVerticalCount += 1
                        case .northeast: partialVerticalCount += 1

                        case .southeast: partialVerticalCount -= 1
                        case .northwest: partialVerticalCount -= 1         
                        
                        default: return
                    }
                } else if ($0.row < row && $0.column == column) {
                    // from above
                    switch tile {
                            case .horizontal: horizontalCount += 1
                           
                            case .southwest: partialHorizontalCount += 1
                            case .northeast: partialHorizontalCount += 1

                            case .southeast: partialHorizontalCount -= 1
                            case .northwest: partialHorizontalCount -= 1
                            
                            default: return
                    }
                }
            }

            partialVerticalCount = abs(partialVerticalCount)
            verticalCount += partialVerticalCount / 2
            partialVerticalCount = partialVerticalCount % 2

            partialHorizontalCount = abs(partialHorizontalCount)
            horizontalCount += partialHorizontalCount / 2
            partialHorizontalCount = partialHorizontalCount % 2

            if  horizontalCount % 2 == 1 || partialHorizontalCount != 0
                || verticalCount % 2 == 1  || partialVerticalCount != 0 
            {
                insideCount += 1
                line.append("*")
            } else {
                line.append("O")
            }
        }

        print("\(line)\n")
    }

    return insideCount
}

struct Coordinate: Hashable {
    let row: Int
    let column: Int

    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
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

