import Foundation

// 3 in a direction

var cells = [[Int]]()
while let line = readLine() {
    cells.append(line.split(separator: "").map { Int($0)! })
}

let height = cells.count
let width = cells[0].count

struct Node: Hashable {
    let row: Int
    let column: Int
    let direction: Direction
    let amount: Int

    enum Direction: Hashable {
        case up
        case down
        case left
        case right
    }
}

struct Edge: Hashable {
    let from: Node
    let to: Node
    let cost: Int
}

let startNode =  Node(row: 0, column: 0, direction: .right, amount: 0)

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

    let up = Node(row: row - 1, column: column, direction: .up, amount: direction == .up ? node.amount + 1 : 1)
    let down = Node(row: row + 1, column: column, direction: .down, amount: direction == .down ? node.amount + 1 : 1)
    let left = Node(row: row, column: column - 1, direction: .left, amount: direction == .left ? node.amount + 1 : 1)
    let right = Node(row: row, column: column + 1, direction: .right, amount: direction == .right ? node.amount + 1 : 1)

    func validNode(_ node: Node) -> Bool {
        return node.amount <= 3 && node.row >= 0 && node.column >= 0 && node.row < height && node.column < width
    }

    if (direction != .up && validNode(down)) {
        queue.append(down)
        edges.append(Edge(from: node, to: down, cost: cells[down.row][down.column]))
    }

    if (direction != .down && validNode(up)) {
        queue.append(up)
        edges.append(Edge(from: node, to: up, cost: cells[up.row][up.column]))
    }

    if (direction != .left && validNode(right)) {
        queue.append(right)
        edges.append(Edge(from: node, to: right, cost: cells[right.row][right.column]))
    }

    if (direction != .right && validNode(left)) {
        queue.append(left)
        edges.append(Edge(from: node, to: left, cost: cells[left.row][left.column]))
    }
}

print ("finished generating graph \(edges.count) edges")
let distances = dijkstra(edges: edges, source: startNode).0
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