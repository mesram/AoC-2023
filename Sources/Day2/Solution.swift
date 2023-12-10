import Foundation

let games = Input.lines.map(Game.init)

print("Part 1: \(part1(games))")
print("Part 2: \(part2(games))")

struct BagContents {
    let red: Int
    let green: Int
    let blue: Int
    
    init(red: Int, green: Int, blue: Int) {
        self.red = red
        self.green = green
        self.blue = blue
    }
    
    init(from text: some StringProtocol) {
        var dict: [String: Int] = ["red": 0, "green": 0, "blue": 0]
        text.split(separator: ", ").forEach {
            let result = $0.split(separator: " ")
            dict.updateValue(Int(String(result[0]))!, forKey: String(result[1]))
        }
        
        self.red = dict["red"] ?? 0
        self.green = dict["green"] ?? 0
        self.blue = dict["blue"] ?? 0
    }
    
    var power: Int {
        return red * green * blue
    }
}

struct Game {
    let id: Int
    let reveals: [BagContents]
    
    init(from line: some StringProtocol){
        let split = line.split(separator: ": ")
        
        self.id = Int(String(split[0].split(separator: " ")[1]))!
        self.reveals = split[1].split(separator: "; ").map(BagContents.init)
    }
    
    func isValid(for contents: BagContents) -> Bool {
        if self.reveals.isEmpty {
            print("Empty reveals for id \(self.id)")
            return false
        }
        
        for reveal in self.reveals {
            if reveal.red > contents.red || reveal.green > contents.green || reveal.blue > contents.blue {
                return false
            }
        }
        
        return true
    }
    
    var minimumBagContents: BagContents {
        .init(
            red: self.reveals.map(\.red).max() ?? 0,
            green: self.reveals.map(\.green).max() ?? 0,
            blue: self.reveals.map(\.blue).max() ?? 0
        )
    }
}

func part1(_ input: [Game]) -> Int {
    let testContents = BagContents(red: 12, green: 13, blue: 14)
        
    return input
        .filter { $0.isValid(for: testContents) }
        .map(\.id)
        .reduce(0, +)
}

func part2(_ input: [Game]) -> Int {
    input
        .map { Int($0.minimumBagContents.power) }
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