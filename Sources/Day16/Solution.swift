import Foundation

let input = Input.lines.map { $0.split(separator: "").map(String.init) }

print("Part 1: \(part1(input))")
print("Part 2: \(part2(input))")



struct Beam: Hashable {
    let row: Int
    let column: Int
    let direction: Direction

    enum Direction {
        case up
        case left
        case down
        case right
    }
}

func followBeam(_ beam: Beam, tileMap: [[String]], energisedTiles: inout Set<Beam>) {
    if (energisedTiles.contains(beam)) {
        return
    }

    if beam.row < 0 || beam.row >= tileMap.count || beam.column < 0 || beam.column >= tileMap[0].count {
        return
    }

    energisedTiles.insert(beam)

    let tile = tileMap[beam.row][beam.column]

    let leftBeam = Beam(row: beam.row, column: beam.column - 1, direction: .left)
    let rightBeam = Beam(row: beam.row, column: beam.column + 1, direction: .right)
    let upBeam = Beam(row: beam.row - 1, column: beam.column, direction: .up)
    let downBeam = Beam(row: beam.row + 1, column: beam.column, direction: .down)

    if tile == "\\" {
        switch beam.direction {
            case .up: followBeam(leftBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .down: followBeam(rightBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .left: followBeam(upBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .right: followBeam(downBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
        }
    } else if tile == "/" {
        switch beam.direction {
            case .down: followBeam(leftBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .up: followBeam(rightBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .right: followBeam(upBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .left: followBeam(downBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
        }
    } else if tile == "|" {
        switch beam.direction {
            case .left: fallthrough
            case .right: 
                followBeam(upBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
                followBeam(downBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .up: followBeam(upBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .down: followBeam(downBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
        }
    } else if tile == "-" {
        switch beam.direction {
            case .up: fallthrough
            case .down: 
                followBeam(leftBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
                followBeam(rightBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .left: followBeam(leftBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .right: followBeam(rightBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
        }
    } else {
        switch beam.direction {
            case .up: followBeam(upBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .down: followBeam(downBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .left: followBeam(leftBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
            case .right: followBeam(rightBeam, tileMap: tileMap, energisedTiles: &energisedTiles)
        }
    }
}

func countEnergisedTiles(_ startBeam: Beam, tileMap: [[String]]) -> Int {
    var calculatedBeams: Set<Beam> = .init()
    followBeam(
        startBeam, 
        tileMap: input, energisedTiles: &calculatedBeams
    )

    var energisedTiles: Set<[Int]> = Set()
    for beam in calculatedBeams {
        energisedTiles.insert([beam.row, beam.column])
    }
    return energisedTiles.count
}

func part1(_ input: [[String]]) -> Int {
    return countEnergisedTiles(
        .init(row: 0, column: 0, direction: .right),
        tileMap: input
    )
}

func part2(_ input: [[String]]) -> Int {
    var beams: [Beam] = []

    for row in input.startIndex..<input.endIndex {
        beams.append(.init(row: row, column: 0, direction: .right))
        beams.append(.init(row: row, column: input[0].endIndex - 1, direction: .left))   
    }

    for column in input[0].startIndex..<input[0].endIndex {
        beams.append(.init(row: 0, column: column, direction: .down))
        beams.append(.init(row: input.endIndex - 1, column: column, direction: .up))
    }

    return beams.map {
        countEnergisedTiles($0, tileMap: input)
    }.max() ?? 0
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