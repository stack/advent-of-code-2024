//
//  Day7.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-08.
//  SPDX-License-Identifier: MIT
//

public struct Day7: AdventDay {
    
    enum Operation: CustomDebugStringConvertible {
        case add
        case multiply
        case concat
        
        var debugDescription: String {
            switch self {
            case .add: "+"
            case .multiply: "*"
            case .concat: "||"
            }
        }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    var equations: [(Int64, [Int64])] {
        data.split(separator: "\n").map {
            let parts = $0.split(separator: ":", maxSplits: 2)
            let lhs = Int64(parts[0])!
            let rhs = parts[1].split(separator: " ").map { Int64($0)! }
            
            return (lhs, rhs)
        }
    }
    
    public func part1() async throws -> Any {
        var valid: Int64 = 0
        
        for (index, equation) in equations.enumerated() {
            
            let sum = visit(values: equation.1, target: equation.0, allowedOps: [.add, .multiply])
            
            if sum != 0 {
                valid += equation.0
                print("\(index) matches: \(equation.0) -> \(valid)")
            }
        }
        
        return valid
    }
    
    public func part2() async throws -> Any {
        var valid: Int64 = 0
        
        for (index, equation) in equations.enumerated() {
            
            let sum = visit(values: equation.1, target: equation.0, allowedOps: [.add, .multiply, .concat])
            
            if sum != 0 {
                valid += equation.0
                print("\(index) matches: \(equation.0) -> \(valid)")
            }
        }
        
        return valid
    }
    
    func visit(values: [Int64], target: Int64, allowedOps: Set<Operation>) -> Int {
        var operations = [Operation](repeating: .add, count: values.count - 1)
        let sum = values[0]
        
        return visit(sum: sum, index: 1, values: values, operations: &operations, target: target, allowedOps: allowedOps)
    }
    
    func visit(sum: Int64, index: Int, values: [Int64], operations: inout [Operation], target: Int64, allowedOps: Set<Operation>) -> Int {
        guard index < values.count else {
            if sum == target {
                // let result = zip(values, operations).flatMap { [String($0), $1.debugDescription] }.joined(separator: " ") + " \(values.last!)"
                //print("\(target) = \(result)")
                return 1
            } else {
                return 0
            }
        }
        
        guard sum <= target else { return 0 }
        
        let value = values[index]
        
        var result = 0
        
        if allowedOps.contains(.add) {
            operations[index - 1] = .add
            result += visit(sum: sum + value, index: index + 1, values: values, operations: &operations, target: target, allowedOps: allowedOps)
            
        }
        
        if allowedOps.contains(.multiply) {
            operations[index - 1] = .multiply
            result += visit(sum: sum * value, index: index + 1, values: values, operations: &operations, target: target, allowedOps: allowedOps)
        }
        
        if allowedOps.contains(.concat) {
            operations[index - 1] = .concat
            result += visit(sum: Int64("\(sum)\(value)")!, index: index + 1, values: values, operations: &operations, target: target, allowedOps: allowedOps)
        }
        
        return result
    }
    
}
