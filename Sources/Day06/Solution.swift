import Foundation

print("Part 1: \(part1(Input.lines))")
print("Part 2: \(part2(Input.lines))")

func part1(_ input: [String]) -> Int {
    let lines = input
        .map { $0.split(separator: " ")
        .dropFirst()
        .map { Double($0)! } }
    
    let races = (0..<lines[0].count).map { (time: lines[0][$0], distance: lines[1][$0]) }
    
    return races.map { race in
        if let (min, max) = solveQuadratic(a: 1, b: -race.time, c: race.distance) {
            return Int(ceil(max) - ceil(min))
        }
        
        return 0
    }.reduce(1, *)
}

func part2(_ input: [String]) -> Int {
    let race = input
        .map { $0.replacingOccurrences(of: " ", with: "") }
        .map { Double($0.split(separator: ":")[1])! }
    
    // (tMax - tHeld) * tHeld = distance
    // tMax * tHeld - tHeld**2 = distance
    // tx - x^2 = d
    // 0 = x^2 - tx + d   where t == time, d == distance
    
    if let (min, max) = solveQuadratic(a: 1, b: -race[0], c: race[1]) {
        return Int(ceil(max) - ceil(min))
    }
    
    return 0
}

func solveQuadratic(a: Double, b: Double, c: Double) -> (Double, Double)? {
    let underSquareTerm = b * b - 4 * a * c
    if underSquareTerm < 0 {
        return nil
    }
    
    let squareRootTerm = sqrt(underSquareTerm)

    let plus =  (-b + squareRootTerm) / (2 * a)
    let minus = (-b - squareRootTerm) / (2 * a)
    
    return plus < minus ? (plus, minus) : (minus, plus)
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
