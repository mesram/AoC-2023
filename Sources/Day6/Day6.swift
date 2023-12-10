import Foundation

print("Day 6.1: \(Day6.part1)")
print("Day 6.2: \(Day6.part2)")

struct Day6 {
    static var part1: Int {
        let lines = input.split(separator: "\n")
            .map { $0.split(separator: " ").dropFirst().map { Double($0)! } }
        
        let races = (0..<lines[0].count).map { (time: lines[0][$0], distance: lines[1][$0]) }
        
        return races.map { race in
            if let (min, max) = solveQuadratic(a: 1, b: -race.time, c: race.distance) {
                return Int(ceil(max) - ceil(min))
            }
            
            return 0
        }.reduce(1, *)
    }
    
    static var part2: Int {
        let race = input.replacingOccurrences(of: " ", with: "")
            .split(separator: "\n")
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
    
    
    static let example = """
        Time:      7  15   30
        Distance:  9  40  200
        """
    
    static let input = """
        Time:        48     93     84     66
        Distance:   261   1192   1019   1063
        """
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
