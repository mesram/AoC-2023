import Foundation

// 3 in a direction

var cells = [[Int]]()
while let line = readLine() {
    cells.append(line.split(separator: "").map { Int($0)! })
}

let height = cells.count
let width = cells[0].count

struct Node: Hashable, CustomDebugStringConvertible {
    let row: Int
    let column: Int
    let direction: Direction

    var debugDescription: String {
        "(\(row), \(column))\(direction)"
    }

    enum Direction: String, Hashable, CustomDebugStringConvertible {
        case vertical = "Vert"
        case horizontal = "Hor"

        var debugDescription: String {
            self.rawValue
        }
    }


}

struct Edge: Hashable, CustomDebugStringConvertible {
    let from: Node
    let to: Node
    let cost: Int

    var debugDescription: String {
        "\(from) -> \(to) cost \(cost)"
    }
}

let startNode =  Node(row: 0, column: 0, direction: .horizontal)

var queue: [Node] = [
   startNode
]

var edges = [Edge]()

var handled = Set<Node>()

while !queue.isEmpty {
    let node = queue.removeFirst()
    if handled.contains(node) { continue }
    handled.insert(node)

    let row = node.row
    let column = node.column
    let direction = node.direction

    func validNode(_ node: Node) -> Bool {
        return node.row >= 0 && node.column >= 0 && node.row < height && node.column < width
    }

    for i in 4...10 {
        if direction == .horizontal {
            let left = Node(
                row: row, 
                column: column - i, 
                direction: .vertical
            )

            let right = Node(
                row: row, 
                column: column + i, 
                direction: .vertical
            )

            if validNode(left) {
                queue.append(left)
                edges.append(Edge(
                    from: node, 
                    to: left, 
                    cost: (1...i).reduce(0) { (total, j) in total + cells[row][column - j]}
                ))
            }

            if validNode(right) {
                queue.append(right)
                edges.append(Edge(
                    from: node, 
                    to: right, 
                    cost: (1...i).reduce(0) { (total, j) in total + cells[row][column + j]}
                ))
            }
        }
        
        if direction == .vertical || (row == 0 && column == 0) {
            let up = Node(
                row: row - i, 
                column: column, 
                direction: .horizontal
            )

            let down = Node(
                row: row + i, 
                column: column, 
                direction: .horizontal
            )

            if validNode(up) {
                queue.append(up)
                edges.append(Edge(
                    from: node, 
                    to: up, 
                    cost: (1...i).reduce(0) { (total, j) in total + cells[row - j][column]}
                ))
            }

            if validNode(down) {
                queue.append(down)
                edges.append(Edge(
                    from: node, 
                    to: down, 
                    cost: (1...i).reduce(0) { (total, j) in total + cells[row + j][column]}
                ))
            }
        }
    }
}

print ("finished generating graph \(edges.count) edges")
let calc = dijkstra(edges: edges, source: startNode)
let distances = calc.0
print("finish calculating")

var minDistance = Int.max
for (node, cost) in distances {
    if node.row == height - 1 && node.column == width - 1 && cost < minDistance {
        minDistance = cost
    }
}

print(minDistance)

func dijkstra(edges: [Edge], source: Node) -> ([Node: Int], [Node: Node]) {
    var edges = edges
    var dist = [Node: Int]()
    var prev = [Node: Node]()

    var distKeyed = [Int: Set<Node>]()
    distKeyed[Int.max] = Set()
    
    var Q = Set<Node>()

    for edge in edges {
        dist[edge.from] = Int.max
        dist[edge.to] = Int.max
        distKeyed[Int.max]!.insert(edge.from)
        distKeyed[Int.max]!.insert(edge.to)
        prev[edge.from] = nil
        prev[edge.to] = nil
        Q.insert(edge.from)
        Q.insert(edge.to)
    }

    dist[source] = 0;
    distKeyed[0] = Set()
    distKeyed[0]!.insert(source)

    let total = Q.count
    var iterations = 0

    var start = Date.now

    print("Q has \(total) vertics")

    while !Q.isEmpty {
        let remaining = total - iterations

        if iterations % 100 == 0 {
            let now = Date.now

            let elapsedTime = now.timeIntervalSince(start)
            let estimate = elapsedTime * Double(remaining / 100)
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.zeroFormattingBehavior = .pad
            formatter.allowedUnits = [.hour, .minute]
            
            start = now

            print("\(remaining) remaining, est. \(formatter.string(from: TimeInterval(estimate))!)")
        }

        iterations += 1

        // var u: Node? = nil;
        // var minDist = Int.max;
        var u: Node? = nil

        top: for key in distKeyed.keys.sorted() {
            for node in distKeyed[key]! {
                if Q.contains(node) {
                    u = node
                    break top
                }
            }
        }
       
        guard let u else { break }

        Q.remove(u)

        for edge in edges where edge.from == u  {
            let v = edge.to

            let val = dist[v]!
            let alt = dist[u]! + edge.cost
            if (alt < val) {
                distKeyed[val]?.remove(v)
                if distKeyed[val]?.isEmpty ?? false {
                    distKeyed[val] = nil
                }
                dist[v] = alt
                if distKeyed[alt] == nil {
                    distKeyed[alt] = Set()
                }
                distKeyed[alt]?.insert(v)
                prev[v] = u
            }
        }

        edges = edges.filter { $0.from != u }
    }

    return (dist, prev);
}