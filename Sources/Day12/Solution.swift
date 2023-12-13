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

func fastEval<C: Collection>(_ currentGroups: C, groups: some Collection<Int>, _ level: Int = 0) -> Int 
    where C.Element == Record, C.Index == Int
{
    let cacheIndex = currentGroups.map(\.debugDescription).joined() + "|" + groups.map(String.init).joined(separator: ",")

    if let cacheHit = cache[cacheIndex] {
        return cacheHit
    }

    guard let groupWidth = groups.first else {
        return currentGroups.contains(.required) ? 0 : 1
    }

    let minWidth = groups.reduce(0, +) + (groups.count - 1)

    if (minWidth > currentGroups.count) {
        return 0
    }

    var total = 0

    for offset in 0..<(currentGroups.count - minWidth + 1) {
        let startIndex = currentGroups.startIndex + offset
        let endIndex = startIndex + groupWidth

        if currentGroups[currentGroups.startIndex..<startIndex].contains(.required) {
            break
        }
        if isValidOverlap(testGroup: currentGroups[startIndex..<endIndex]) {
            let shouldRecurse = groups.count == 1
                ? !currentGroups[endIndex..<currentGroups.endIndex].contains(.required)
                : currentGroups[endIndex] != .required
            if shouldRecurse {
                total += fastEval(
                    currentGroups.dropFirst(groupWidth + offset + 1), 
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
            var template = line.0
            var groups: [Int] = line.1

            for _ in 0..<4 {
                template += "?" + line.0
                groups += line.1
            }

            return (template, groups)
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