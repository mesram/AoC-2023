import RegexBuilder

print("Part 1: \(part1(Input.lines))")
print("Part 2: \(part2(Input.lines))")

enum Numbers: String {
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine

    var intValue: Int { get {
        switch self {
            case .one: return 1
            case .two: return 2
            case .three: return 3
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
        }
    }}
}

func getMatch(
    _ input: [String], 
    forward: Regex<Regex<(Substring, Int)>.RegexOutput>,
    backward: Regex<Regex<(Substring, Int)>.RegexOutput>
) -> Int {
    input
        .map {
            let firstMatch = try? forward.firstMatch(in: $0)
            let secondMatch = try? backward.firstMatch(in: String($0.reversed()))

            if let firstMatch, let secondMatch {
                return firstMatch.1 * 10 + secondMatch.1
            }

            return 0
        }
        .reduce(0, +)
}

func part1(_ input: [String]) -> Int {
    let regex = Regex {
        Capture {
            ChoiceOf {
                CharacterClass.digit
            }
        } transform: { Int($0)! }
        ZeroOrMore { .any }
        Anchor.endOfSubject
    }

    return getMatch(input, forward: regex, backward: regex)
}

func part2(_ input: [String]) -> Int {
    let forward = Regex {
        Capture {
            ChoiceOf {
                CharacterClass.digit
                "one"
                "two"
                "three" // khkhkjhjk
                "four"
                "five"
                "six"
                "seven"
                "eight"
                "nine"
            }
        } transform: {
            Int($0) ?? Numbers(rawValue: String($0))?.intValue ?? 0
        }
    }

    let backward = Regex {
        Capture {
            ChoiceOf {
                CharacterClass.digit
                "eno"
                "owt"
                "eerht"
                "ruof"
                "evif"
                "xis"
                "neves"
                "thgie"
                "enin"
            }
        } transform: {
            Int($0) ?? Numbers(rawValue: String($0.reversed()))?.intValue ?? 0
        }
    }

    return getMatch(input, forward: forward, backward: backward)
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
