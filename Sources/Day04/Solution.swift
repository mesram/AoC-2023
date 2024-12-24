//
//  File.swift
//  
//
//  Created by Joshua Harding on 4/12/2023.
//

import Foundation

let lines = Input.lines.map {
    $0.split(separator: ": ")[1]
        .split(separator: " | ")
        .map {
            $0
                .split(separator: " ")
                .map { Int($0)! }
        }
}

print("Part 1: \(part1(lines))")
print("Part 2: \(part2(lines))")

func part1(_ lines: [[[Int]]]) -> Int {
    var total: Int = 0
    for line in lines {
        let winningNumbers = Set<Int>().union(line[0])
        let myNumbers = Set<Int>().union(line[1])
        
        let amount = winningNumbers.intersection(myNumbers).count
        if amount > 0 {
            total += 1 << (amount - 1)
        }
    }
    
    return total
}

func part2(_ lines: [[[Int]]]) -> Int {
    var winnings: [Int] = []
    for (i, line) in lines.enumerated() {
        let winningNumbers = Set<Int>().union(line[0])
        let myNumbers = Set<Int>().union(line[1])
        
        winnings.append(max(0, min(winningNumbers.intersection(myNumbers).count, lines.count - i - 1)))
    }
    
    func getWinnings(for cardIndex: Int) -> Int {
        var total = 1
        for index in 0..<winnings[cardIndex] {
            total += getWinnings(for: cardIndex + index + 1)
        }
        return total
    }
    
    var total = 0;
    for i in 0..<winnings.count {
        total += getWinnings(for: i)
    }
    
    return total
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