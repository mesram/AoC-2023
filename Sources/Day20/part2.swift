import Foundation

enum Pulse {
    case high
    case low
}

protocol Module: AnyObject {
    func receive(pulse: Pulse, from sourceModule: String) -> [(String, Pulse)]
    func addInput(module: String)
    func addOutput(module: String)
}

class FlipFlopModule: Module {
    var isOn: Bool = false
    var outputs = [String]()

    func receive(pulse: Pulse, from sourceModule: String) -> [(String, Pulse)] {
        guard pulse == .low else { return [] }
        isOn.toggle()
        return outputs.map { ($0, isOn ? .high : .low) }
    }

    func addInput(module: String) {
        // no-op
    }

    func addOutput(module: String) {
        outputs.append(module)
    }
}

class ConjunctionModule: Module {
    var inputModules: [String: Pulse] = [:]
    var outputs = [String]()

    func receive(pulse: Pulse, from sourceModule: String) -> [(String, Pulse)] {
        inputModules[sourceModule] = pulse
        let result: Pulse = inputModules.values.allSatisfy { $0 == .high } ? .low : .high
        return outputs.map { ($0, result) }
    }

    func addInput(module: String) {
        inputModules[module] = .low
    }

    func addOutput(module: String) {
        outputs.append(module)
    }
}

class BroadcastModule: Module {
    var outputs = [String]()

    func receive(pulse: Pulse, from sourceModule: String) -> [(String, Pulse)] {
        return outputs.map { ($0, pulse) }
    }

    func addInput(module: String) {

    }

    func addOutput(module: String) {
        outputs.append(module)
    }
}

class OutputModule: Module {
    var inputs = [String]()
    func receive(pulse: Pulse, from sourceModule: String) -> [(String, Pulse)] {
        return []
    }

    func addInput(module: String) {
        inputs.append(module)
    }

    func addOutput(module: String) {
        
    }
}

var modules: [String: any Module] = [:]
var pendingConnections: [String: [String]] = [:]

while let line = readLine() {
    let result: (Substring, Substring, Substring, Substring) = try! #/([%&]?)([a-z]+) -> (.*)/#.wholeMatch(in: line)!.output

    let type = result.1
    let name = String(result.2)
    let connections = result.3.split(separator: ", ").map(String.init)

    let module: any Module = switch type {
        case "&": ConjunctionModule()
        case "%": FlipFlopModule()
        case "": BroadcastModule()
        default: fatalError("Unhandled module type \(type)")
    }

    modules[name] = module
    pendingConnections[name] = connections
}

for (name, outputs) in pendingConnections {
    for output in outputs {
        modules[name]!.addOutput(module: output)
        if modules[output] == nil {
            modules[output] = OutputModule()
        }
        modules[output]!.addInput(module: name)
    }
}

struct QueueItem {
    let source: String
    let destination: String
    let pulse: Pulse
}

struct Target {
    let module: String
    let pulse: Pulse
}

func getReemissionCountUntil(signal: QueueItem, target: Target) -> Int {
    var count = 0
    while true {
        count += 1
        var queue = [signal]
        
        while !queue.isEmpty {
            let item = queue.removeFirst()
            let forwardedPulses = modules[item.destination]?.receive(pulse: item.pulse, from: item.source) ?? []

            for pulse in forwardedPulses {
                if pulse.0 == target.module && pulse.1 == target.pulse {
                    return count
                }

                queue.append(QueueItem(
                    source: item.destination, 
                    destination: pulse.0, 
                    pulse: pulse.1
                ))
            }
        }
    }
}

// There are 4 independent paths branching out from "broadcaster" and converging back on the single & input that emits to rx
// I'm assuming that each path takes a prime number of button presses

let broadcaster = modules["broadcaster"]! as! BroadcastModule
let output = modules["rx"] as! OutputModule
assert(output.inputs.count == 1, "Output expects exactly one connected input")
let outputTarget = output.inputs[0]

var counts = [Int]()
for entry in (modules["broadcaster"]! as! BroadcastModule).outputs {
    let count = getReemissionCountUntil(
        signal: QueueItem(source: "broadcaster", destination: entry, pulse: .low), 
        target: Target(module: outputTarget, pulse: .high)
    )

    print("\(entry): \(count)")
    counts.append(count)
}

// check coprime between all the results, implying there are no common cycle timings
for i in 0..<counts.count {
    for j in (i+1)..<counts.count {
        assert(gcd(counts[i], counts[j]) == 1)
    }
}

print(counts.reduce(1, *))

func gcd(_ a: Int, _ b: Int) -> Int {
    var num1 = a
    var num2 = b
    
    while num2 != 0 {
        let remainder = num1 % num2
        num1 = num2
        num2 = remainder
    }
    
    return num1
}
