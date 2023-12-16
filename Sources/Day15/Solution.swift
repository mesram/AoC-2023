import Foundation

let instructions = Input.lines
    .flatMap { $0.split(separator: "," )
    .map(String.init) 
}

print("Part 1: \(part1(instructions))")
print("Part 2: \(part2(instructions))")

func part1(_ input: [String]) -> Int {
    return instructions
        .map(hash)
        .reduce(0, +)
}

func part2(_ input: [String]) -> Int {
    var map: [[Lense]] = Array(repeating: [], count: 256)

    func remove(_ label: String) {
        map[hash(label)] = map[hash(label)].filter {
            $0.label != label
        }
    }

    func add(_ lense: Lense) {
        if let index = map[lense.hashKey].firstIndex(where: { $0.label == lense.label }) {
            map[lense.hashKey][index] = lense
        } else {
            map[lense.hashKey].append(lense)
        }
    }

    for instruction in input {
        if instruction.contains("=") {
            let pieces = instruction.split(separator: "=")
            add(.init(label: String(pieces[0]), focalLength: Int(pieces[1])!))
        } else {
            remove(String(instruction.split(separator: "-")[0]))
        }
    }

    var result = 0
    for (box, lenses) in map.enumerated() {
        for (index, lense) in lenses.enumerated() {
            result += (1 + box) * (1 + index) * lense.focalLength
        }
    }

    return result
}

struct Lense {
    var label: String
    var focalLength: Int

    var hashKey: Int {
        hash(label)
    }
}


func hash(_ input: String) -> Int {
    var result: Int = 0

    for char in input {
        result += Int(char.asciiValue!)
        result *= 17
        result %= 256
    }

    return result
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