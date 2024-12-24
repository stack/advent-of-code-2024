//
//  Day24.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-24.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day24: AdventDay {
    
    struct Adder {
        var wires: [String:Bool]
        var gates: Set<Gate>
        
        func findFaults() -> String {
            let endGates = gates.filter { $0.result.hasPrefix("z") }.map { $0.result }.sorted()
            var badGates: [Gate] = []
            
            for gate in gates {
                var isInvalid = false

                if gate.isOutput && gate.result != endGates.last {
                    isInvalid = gate.operation != .xor
                } else if !gate.isOutput && !gate.lhsIsInput && !gate.rhsIsInput {
                    isInvalid = gate.operation == .xor
                } else if (gate.lhsIsInput && gate.rhsIsInput) && !gate.isFirst {
                    let nextOperation: Operation = gate.operation == .xor ? .xor : .or
                    let result = gates.contains {
                        guard $0 != gate else { return false }
                        guard $0.lhs == gate.result || $0.rhs == gate.result else { return false }
                        guard $0.operation == nextOperation else { return false }
                        
                        return true
                    }
                    
                    isInvalid = !result
                }
                
                if isInvalid {
                    badGates.append(gate)
                }
            }
            
            return badGates.map(\.result).sorted().joined(separator: ",")
        }
        
        func printTree() {
            let endGates = gates.filter { $0.result.hasPrefix("z") }.map(\.result).sorted()
            
            for gate in endGates {
                printTree(result: gate)
            }
        }
        
        private func printTree(result: String, depth: Int = 0) {
            let gate = gates.first { $0.result == result }!
            
            let spacer = String(repeating: " ", count: depth * 2)
            
            print("\(spacer)\(gate.lhs) \(gate.operation.description) \(gate.rhs) = \(gate.result)")
            
            let lhsDone = gate.lhs.hasPrefix("x") || gate.lhs.hasPrefix("y")
            let rhsDone = gate.rhs.hasPrefix("x") || gate.rhs.hasPrefix("y")
            
            if !lhsDone {
                printTree(result: gate.lhs, depth: depth + 1)
            }
            
            if !rhsDone {
                printTree(result: gate.rhs, depth: depth + 1)
            }
        }
        
        mutating func resolve() -> Int {
            var resolvableGates = gates.filter { wires[$0.lhs] != nil && wires[$0.rhs] != nil }
            var remainingGates = gates.subtracting(resolvableGates)
            
            while !resolvableGates.isEmpty {
                let current = resolvableGates.removeFirst()
                
                let lhsValue = wires[current.lhs]!
                let rhsValue = wires[current.rhs]!
                
                wires[current.result] = current.evaluate(lhsValue, rhsValue)
                
                let nextGates = remainingGates.filter { wires[$0.lhs] != nil && wires[$0.rhs] != nil }
                resolvableGates.formUnion(nextGates)
                remainingGates.subtract(nextGates)
            }
            
            let finalKeys = wires.keys.filter { $0.hasPrefix("z") }.sorted().reversed()
            
            var value = 0
            
            for key in finalKeys {
                value = value << 1
                value += wires[key]! ? 1 : 0
            }
            
            return value
        }
    }
    
    struct Gate: Hashable {
        var lhs: String
        var rhs: String
        var result: String
        var operation: Operation
        
        var isOutput: Bool { result.hasPrefix("z") }
        var lhsIsInput: Bool { lhs.hasPrefix("x") || lhs.hasPrefix("y") }
        var rhsIsInput: Bool { rhs.hasPrefix("x") || rhs.hasPrefix("y") }
        var isFirst: Bool { lhs.hasSuffix("00") && rhs.hasSuffix("00") }
        
        func evaluate(_ lhsValue: Bool, _ rhsValue: Bool) -> Bool {
            switch operation {
            case .and: lhsValue && rhsValue
            case .or: lhsValue || rhsValue
            case .xor: lhsValue != rhsValue
            }
        }
    }
    
    enum Operation: CustomStringConvertible, Hashable {
        case and
        case or
        case xor
        
        var description: String {
            switch self {
            case .and: "AND"
            case .or: "OR"
            case .xor: "XOR"
            }
        }
    }
    
    public var data: String
    
    var gates: Set<Gate> {
        Set(
            data
            .split(separator: "\n\n")[1]
            .split(separator: "\n")
            .map {
                let parts = $0.split(separator: " ").map { String($0) }
                
                let operation: Operation = switch parts[1] {
                case "AND": .and
                case "OR": .or
                case "XOR": .xor
                default: fatalError("Unknown operation \(parts[1])")
                }
                
                return Gate(lhs: parts[0], rhs: parts[2], result: parts[4], operation: operation)
            }
        )
    }
    
    var wires: [String:Bool] {
        data
            .split(separator: "\n\n")[0]
            .split(separator: "\n")
            .reduce(into: [:]) {
                let data = $1.split(separator: ": ").map { String($0) }
                $0[data[0]] = data[1] == "1"
            }
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var adder = Adder(wires: wires, gates: gates)
        
        return adder.resolve()
        
    }
    
    public func part2() async throws -> Any {
        let adder = Adder(wires: wires, gates: gates)
        
        return adder.findFaults()
    }
}
