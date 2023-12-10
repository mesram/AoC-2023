import Foundation

let input = {
    let lines = Input.lines.joined(separator: "\n").split(separator: "\n\n")

    let seeds = lines[0].split(separator: " ").dropFirst()
        .map { Int($0)! }
    
    let maps = lines
        .dropFirst()
        .map {
            $0.split(separator: "\n").dropFirst()
                .map {
                    let nums = $0.split(separator: " ")
                        .map { Int($0)! }
                    
                    return RangeMap(
                        min: nums[1],
                        range: nums[2],
                        offset: nums[0] - nums[1]
                    )
                }
        }
    
    return (seeds, maps)
}()

print("Part 1: \(part1(input))")
print("Part 2: \(part2(input))")

struct Range {
    var min: Int
    var range: Int
    var max: Int { min + range - 1 }
    
    func mapped(using maps: [RangeMap]) -> [Self] {
        let input = self
        
        var complete: [RangeMap] = []
        
        var currentIndex: Int = input.min
        for map in maps.sorted(by: { $0.min < $1.min }) {
            if map.max < self.min { continue }
            if map.min > self.max { break }
            
            if map.min > currentIndex {
                complete.append(.init(min: currentIndex, range: map.min - currentIndex, offset: 0))
            }
            
            if let intersection = map.intersecting(input) {
                complete.append(intersection)
            }
            
            currentIndex = map.max + 1
        }
        
        if input.max > currentIndex {
            complete.append(.init(min: currentIndex, range: input.max - (currentIndex - 1), offset: 0))
        }
        
        return complete.map(\.mappedRange)
    }
}

struct RangeMap {
    var min: Int
    var range: Int
    var offset: Int
    
    var max: Int { min + range - 1 }
    var mappedRange: Range {
        .init(min: min + offset, range: range)
    }
    
    func intersecting(_ range: Range) -> Self? {
        if range.max < self.min || range.min > self.max {
            return nil
        }
        
        let left = Swift.max(self.min, range.min)
        let right = Swift.min(self.max, range.max)

        return .init(
            min: left,
            range: right - left + 1,
            offset: self.offset
        )
    }
}

func minimumLocation(seedRanges: [Range], mapRanges: [[RangeMap]]) -> Int {
    var inputRanges = seedRanges
    
    for mapRange in mapRanges {
        inputRanges = inputRanges.flatMap { $0.mapped(using: mapRange) }
    }
    
    return inputRanges.sorted { $0.min < $1.min }.first?.min ?? -1
}

extension Array {
    var paired: [(Element, Element)] {
        var result: [(Element, Element)] = []
        
        for index in 0..<Int(self.count / 2) {
            result.append((self[2 * index], self[2 * index + 1]))
        }
        
        return result
    }
}

func part1(_ input: (seeds: [Int], maps: [[RangeMap]])) -> Int {
    return minimumLocation(
        seedRanges: input.seeds.map { Range(min: $0, range: 1) },
        mapRanges: input.maps
    )
}

func part2(_ input: (seeds: [Int], maps: [[RangeMap]])) -> Int {
    return minimumLocation(
        seedRanges: input.seeds.paired.map { Range(min: $0.0, range: $0.1) },
        mapRanges: input.maps
    )
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
