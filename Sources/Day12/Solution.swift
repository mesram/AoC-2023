import Foundation

let input = Input.lines.map {
    let pieces = $0.split(separator: " ")
    let template = String(pieces[0])

    let groups = pieces[1].split(separator: ",").compactMap { Int($0) }
    return (template, groups)
}

func isValidOverlap<C: Collection>(testGroup: C) -> Bool
    where C.Element == Record, C.Index == Int
 {
    return testGroup.allSatisfy { $0 != .space }
}

enum Record: CustomDebugStringConvertible {
    case any
    case required
    case space

    var debugDescription: String {
        switch self {
            case .any: "?"
            case .required: "#"
            case .space: "."
        }
    }
}

var cache: [String: Int] = [:]

func fastEval<C: Collection>(_ input: C, groups: some Collection<Int>, _ level: Int = 0) -> Int 
    where C.Element == Record, C.Index == Int
{
    let cacheIndex = input.map(\.debugDescription).joined() + "|" + groups.map(String.init).joined(separator: ",")

    if let cacheHit = cache[cacheIndex] {
        return cacheHit
    }

    guard let groupWidth = groups.first else {
        return input.contains(.required) ? 0 : 1
    }

    let minWidth = groups.reduce(0, +) + (groups.count - 1)

    if (minWidth > input.count) {
        return 0
    }

    var total = 0

    for offset in 0..<(input.count - minWidth + 1) {
        let startIndex = input.startIndex + offset
        let endIndex = startIndex + groupWidth

        if input[input.startIndex..<startIndex].contains(.required) {
            break
        }
        if isValidOverlap(testGroup: input[startIndex..<endIndex]) {
            let shouldRecurse = groups.count == 1
                ? !input[endIndex..<input.endIndex].contains(.required)
                : input[endIndex] != .required
            if shouldRecurse {
                total += fastEval(
                    input.dropFirst(groupWidth + offset + 1), 
                    groups: groups.dropFirst(),
                    level + 1
                )
            }
        }
    }

    cache.updateValue(total, forKey: cacheIndex)

    return total
}

print("Part 1: \(part1(input))") // ~25s on the normal input, answer = 7286
print("Part 2: \(part2(input))")

func part1(_ input: [(String, [Int])]) -> Int {
    input.map {
        let records = $0.0.map {
            if ($0 == "#") {
                return Record.required
            } else if ($0 == "?") {
                return Record.any
            }

            return Record.space
        }

        let fastResult = fastEval(records, groups: $0.1)
        print("\($0.0) \($0.1) = \(fastResult)")
        return fastResult
    }
    .reduce(0, +)
}

func part2(_ input: [(String, [Int])]) -> Int {
    input
        .map { line in 
            return (
                repeatElement(line.0, count: 5).joined(separator: "?"),
                repeatElement(line.1, count: 5).joined()
            )
        }
        .map {
            let records = $0.0.split(separator: ".").joined(separator: ".").map {
                if ($0 == "#") {
                    return Record.required
                } else if ($0 == "?") {
                    return Record.any
                }

                return Record.space
            }

            let fastResult = fastEval(records, groups: $0.1)
            print("\($0.0) \($0.1) = \(fastResult)")
            return fastResult
        }
        .reduce(0, +)
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