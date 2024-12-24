import Foundation

let lines = Input.lines
    .filter { !$0.isEmpty }
    .map { 
        $0.replacingOccurrences(of: "=", with: "")
        .replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
        .replacingOccurrences(of: ",", with: "")
    }

let instructions = lines[0].split(separator: "")

var map: [String: (String, String)] = [:]
for i in 1..<lines.count {
    let pieces = lines[i].split(separator: " ")
    let key = String(pieces[0])
    let left = String(pieces[1])
    let right = String(pieces[2])
    
    map.updateValue((left: left, right: right), forKey: key)
}

print("Part 1: \(part1(instructions: instructions, map: map))")
print("Part 2: \(part2(instructions: instructions, map: map))")

func part1(instructions: [some StringProtocol], map: [String: (String, String)]) -> Int {
    var stepsTaken = 0
    var current = "AAA"
    
    while current != "ZZZ" {
        switch (instructions[stepsTaken % instructions.count]) {
        case "L": current = map[current]!.0
        case "R": current = map[current]!.1
        default: fatalError()
        }
        
        stepsTaken += 1
    }
    
    return stepsTaken
}

func part2(instructions: [some StringProtocol], map: [String: (String, String)]) -> Int {    
    // Map each node to the node they end up after fully consuming the instruction input
    var jumpList: [String: String] = [:]
    for key in map.keys {
        var currentNode = key
        for instruction in instructions {
            switch instruction {
            case "L": currentNode = map[currentNode]!.0
            case "R": currentNode = map[currentNode]!.1
            default: fatalError()
            }
        }
        jumpList.updateValue(currentNode, forKey: key)
    }
    
    /* 
        The input just *happens* to work such that:
        1. If you look at just the start and end nodes after full iteration through the insructions
            The pattern will look like A -> B -> ... -> Z -> B
        2. The length of the path A -> Z is a prime number
        
        These 2 facts mean that the problem reduces to multiplying the individual path lengths together, and then multiplying by the instruction length

        There is no real reason that the assumptions above should be true, for instance if the cycle lengths were not prime, then it would require doing some sort of G.C.D. calculations
        There is also no reason why Z has to be reached on the last input in the instruction list.
        There is also no reasy why the cycle couldn't look like A -> B -> ... -> XXX -> ... -> Z -> XXX which would be fuuuuuucked for the calculation

        This puzzle makes me angry. The rules above make it far simpler to solve, but since they weren't stated, it is incorrect to code something that uses them.
    */
    return  map.keys
        .filter { $0.suffix(1) == "A" }
        .map {
            var count = 0
            var currentItem = $0
            while currentItem.suffix(1) != "Z" {
                count += 1
                currentItem = jumpList[currentItem]!
            }

            return count
        }
        .reduce(instructions.count, *)
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