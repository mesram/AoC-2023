import Foundation

let input = Input.lines
    .map { 
        $0.split(separator: " ").map { Int(String($0))! }
    }

print("Part 1: \(part1(input))")
print("Part 2: \(part2(input))")

func part1(_ input: [[Int]]) -> Int {
    input
        .map(extrapolateValue(for:))
        .reduce(0, +)
}

func part2(_ input: [[Int]]) -> Int {
    part1(input.map { $0.reversed() })
}

func extrapolateValue(for values: [Int]) -> Int {
    // if array is all zeros (or empty), there's nothing left to extrapolate
    if values.filter({ $0 != 0 }).isEmpty {
        return 0
    }

    let differences = zip(values.dropLast(), values.dropFirst()).map { $1 - $0 }

    return values.last! + extrapolateValue(for: differences)
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

