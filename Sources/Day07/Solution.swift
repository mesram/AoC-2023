import Foundation

print("Part 1: \(part1(Input.lines))")
print("Part 2: \(part2(Input.lines))")

func part1(_ input: [String]) -> Int {
    input
        .map(Hand.init)
        .sorted()
        .enumerated()
        .reduce(0) {
            $0 + ($1.offset + 1) * $1.element.bid
        }
}

func part2(_ input: [String]) -> Int {
    return part1(input.map { $0.replacingOccurrences(of: "J", with: "*") })
}

struct Hand: Comparable {
    let bid: Int
    let type: HandType
    let hand: [Card]
    
    init(from: some StringProtocol) {
        let pieces = from.split(separator: " ")
        
        self.bid = Int(pieces[1])!
        self.hand  = pieces[0].map(Card.init)
        self.type = .init(from: self.hand)
    }
    
    enum HandType: CaseIterable, Comparable {
        case single
        case pair
        case twopair
        case three
        case fullhouse
        case four
        case five
        
        init(from cards: [Card]) {
            // could just use Dictionary(grouping:by:) but this looks simpler
            var map: [Card: Int] = [:]
            for card in cards {
                map[card] = (map[card] ?? 0) + 1
            }
            
            let jokerCount = map.removeValue(forKey: .joker) ?? 0
            
            var groups = map.sorted { lhs, rhs in
                if lhs.value != rhs.value {
                    return lhs.value < rhs.value
                }
                
                return lhs.key < rhs.key
            }
        
            // add the joker cards to the count for the card with highest count, this will have the greatest chance of increasing the hand
            let highest: (Card, Int) = switch(groups.popLast()) {
            case .some(let element): (element.key, element.value + jokerCount)
            case .none:              (.joker, 5)
            }
        
            groups.append(highest)
            
            self = switch groups.last!.value {
            case 5: .five
            case 4: .four
            case 3: (groups[0].value == 2) ? .fullhouse : .three
            case 2: (groups.count == 3) ? .twopair : .pair
            default: .single
            }
        }
        
        static func < (lhs: Hand.HandType, rhs: Hand.HandType) -> Bool {
            Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
        }
    }

    enum Card: String, Hashable, Comparable, CaseIterable {
        case joker = "*"
        
        case two = "2"
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "T"
        case jack = "J"
        case queen = "Q"
        case king = "K"
        case ace = "A"
        
        init(from char: Character) {
            self.init(rawValue: String(char))!
        }
        
        static func <(lhs: Self, rhs: Self) -> Bool {
            Self.allCases.firstIndex(of: lhs)! < Self.allCases.firstIndex(of: rhs)!
        }
    }
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.type == rhs.type {
            for i in 0... {
                if lhs.hand[i] != rhs.hand[i] {
                    return lhs.hand[i] < rhs.hand[i]
                }
            }
        }
        
        return lhs.type < rhs.type
    }
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
