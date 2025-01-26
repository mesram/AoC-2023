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

    print(type, name, connections)
}

for (name, outputs) in pendingConnections {
    for output in outputs {
        modules[name]!.addOutput(module: output)
        modules[output]?.addInput(module: name)
    }
}

struct QueueItem {
    let source: String
    let destination: String
    let pulse: Pulse
}

func pressButton(count: Int) -> Int {
    var highCount = 0
    var lowCount = 0

    for _ in 0..<count {
        var queue = [QueueItem(source: "", destination: "broadcaster", pulse: .low)]
        
        while !queue.isEmpty {
            let item = queue.removeFirst()
            switch item.pulse {
                case .high: highCount += 1
                case .low: lowCount += 1
            }

            let forwardedPulses = modules[item.destination]?.receive(pulse: item.pulse, from: item.source) ?? []

            for pulse in forwardedPulses {
                queue.append(QueueItem(
                    source: item.destination, 
                    destination: pulse.0, 
                    pulse: pulse.1
                ))
            }
        }
    }

    return highCount * lowCount
}

print(pressButton(count: 1000))




