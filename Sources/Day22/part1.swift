
//1,0,1~1,2,1

class Block {
    let id: Int
    let x: (Int, Int)
    let y: (Int, Int)
    var z: (Int, Int)

    var settled = false
    var dependencyIds = [Int]()

    init(id: Int, x: (Int, Int), y: (Int, Int), z: (Int, Int)) {
        self.id = id
        self.x = x
        self.y = y
        self.z = z
    }

    func settle(into region: inout [[Block?]]) {
        var level = 1
        var collisions = [Block]()

        for xPos in x.0...x.1 {
            for yPos in y.0...y.1 {
                if let occupant = region[xPos][yPos] {
                    if occupant.z.1 > level {
                        level = occupant.z.1
                        collisions = [occupant]
                    } else if occupant.z.1 == level {
                        collisions.append(occupant)
                    }
                }

                region[xPos][yPos] = self
            }
        }

        if !collisions.isEmpty {
            self.dependencyIds = collisions.map { $0.id }
            level += 1
        }

        let diff = self.z.0 - level
        self.z = (self.z.0 - diff, self.z.1 - diff)
    }

    func check(region: inout [[Block?]]) -> Bool {
        var level = 1
        var collisions = [Block]()

        for xPos in x.0...x.1 {
            for yPos in y.0...y.1 {
                if let occupant = region[xPos][yPos] {
                    if occupant.z.1 > level {
                        level = occupant.z.1
                        collisions = [occupant]
                    } else if occupant.z.1 == level {
                        collisions.append(occupant)
                    }
                }

                region[xPos][yPos] = self
            }
        }

        if !collisions.isEmpty {
            level += 1
        }

        return self.z.0 != level
    }
}

var blocks = [Block]()
var id = 0

var maxX = 0
var maxY = 0

while let line = readLine() {
    let result = try! #/(\d+),(\d+),(\d+)~(\d+),(\d+),(\d+)/#.wholeMatch(in: line)!.output
    let x1 = Int(result.1)!
    let y1 = Int(result.2)!
    let z1 = Int(result.3)!

    let x2 = Int(result.4)!
    let y2 = Int(result.5)!
    let z2 = Int(result.6)!

    if x2 > maxX {
        maxX = x2
    }

    if y2 > maxY {
        maxY = y2
    }

    blocks.append(Block(
        id: id,
        x: (x1, x2), 
        y: (y1, y2), 
        z: (z1, z2)
    ))

    id += 1
}

blocks.sort { $0.z.0 < $1.z.0 }

var region = Array(repeating: Array(repeating: Optional<Block>.none, count: maxY + 1), count: maxX + 1)
for block in blocks {
    block.settle(into: &region)
}

blocks.sort { $0.z.0 < $1.z.0 }


var dependencyCount = 0
outer: for block in blocks {
    let filtered = blocks.filter { ObjectIdentifier($0) != ObjectIdentifier(block) }
    var region = Array(repeating: Array(repeating: Optional<Block>.none, count: maxY + 1), count: maxX + 1)

    for test in filtered {
        if test.check(region: &region) {
            dependencyCount += 1
            continue outer
        }
    }
    
}

print(blocks.count - dependencyCount)
