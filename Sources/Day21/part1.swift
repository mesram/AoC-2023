var input = [[String]]()

while let line = readLine() {
    input.append(line.split(separator: "").map(String.init))
}

let height = input.count
let width = input[0].count


var edges = [Edge<Position>]()

var start: Position? = nil
for row in 0..<height {
    for column in 0..<width {
        let cellValue = input[row][column]
        let position = Position(row: row, column: column)

        if cellValue == "#" {
            continue
        }

        if cellValue == "S" {
            start = position
        }

        
        if row > 0 && input[row - 1][column] != "#" {
            edges.append(Edge<Position>(
                from: position,
                to: Position(row: row - 1, column: column),
                cost: 1
            ))
        }

        if row < height - 1 && input[row + 1][column] != "#" {
            edges.append(Edge<Position>(
                from: position,
                to: Position(row: row + 1, column: column),
                cost: 1
            ))
        }

        if column > 0 && input[row][column - 1] != "#" {
            edges.append(Edge<Position>(
                from: position,
                to: Position(row: row, column: column - 1),
                cost: 1
            ))
        }

        if column < width - 1 && input[row][column + 1] != "#" {
            edges.append(Edge<Position>(
                from: position,
                to: Position(row: row, column: column + 1),
                cost: 1
            ))
        }

    }
}

let distances = dijkstra(edges: edges, source: start!).0

// all positions that are reachable within 64 steps
// exclude odd distances as it would be impossible to finish there after an even number of steps
print(distances.filter { $0.1 <= 64 && $0.1 % 2 == 0 }.count)

struct Position: Hashable {
    let row: Int
    let column: Int
}

struct Edge<Node>: Hashable where Node: Hashable {
    let from: Node
    let to: Node
    let cost: Int

    init(from: Node, to: Node, cost: Int) {
        self.from = from
        self.to = to
        self.cost = cost
    }
}

func dijkstra<Node>(edges: [Edge<Node>], source: Node) -> ([Node: Int], [Node: Node]) {
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

    while !Q.isEmpty {
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