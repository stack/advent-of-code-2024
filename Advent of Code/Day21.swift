//
//  Day21.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-22.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day21: AdventDay {
    
    enum Action: CustomDebugStringConvertible {
        case up
        case down
        case left
        case right
        case activate
        
        var debugDescription: String {
            switch self {
            case .up: return "^"
            case .down: return "v"
            case .left: return "<"
            case .right: return ">"
            case .activate: return "A"
            }
        }
        
        var offset: Point {
            switch self {
            case .up: Point(x: 0, y: -1)
            case .down: Point(x: 0, y: 1)
            case .left: Point(x: -1, y: 0)
            case .right: Point(x: 1, y: 0)
            case .activate: .zero
            }
        }
    }
    
    struct CacheKey: Hashable {
        var actions: [Action]
        var depth: Int
    }
    
    struct Keypad {
        
        var keysToPoints: [String:Point] = [:]
        var pointsToKeys: [Point:String] = [:]
        
        var edges: [String:[String:[[Action]]]] = [:]
        
        static var directional: Keypad {
            var keypad = Keypad()
            
            keypad.insert(key: "^", point: Point(x: 1, y: 0))
            keypad.insert(key: "A", point: Point(x: 2, y: 0))
            keypad.insert(key: "<", point: Point(x: 0, y: 1))
            keypad.insert(key: "v", point: Point(x: 1, y: 1))
            keypad.insert(key: ">", point: Point(x: 2, y: 1))
            
            keypad.resolve()
            
            return keypad
        }
        
        static var numeric: Keypad {
            var keypad = Keypad()
            
            keypad.insert(key: "7", point: Point(x: 0, y: 0))
            keypad.insert(key: "8", point: Point(x: 1, y: 0))
            keypad.insert(key: "9", point: Point(x: 2, y: 0))
            keypad.insert(key: "4", point: Point(x: 0, y: 1))
            keypad.insert(key: "5", point: Point(x: 1, y: 1))
            keypad.insert(key: "6", point: Point(x: 2, y: 1))
            keypad.insert(key: "1", point: Point(x: 0, y: 2))
            keypad.insert(key: "2", point: Point(x: 1, y: 2))
            keypad.insert(key: "3", point: Point(x: 2, y: 2))
            keypad.insert(key: "0", point: Point(x: 1, y: 3))
            keypad.insert(key: "A", point: Point(x: 2, y: 3))
            
            keypad.resolve()
            
            return keypad
        }
        
        mutating func insert(key: String, point: Point) {
            keysToPoints[key] = point
            pointsToKeys[point] = key
        }
        
        mutating func resolve() {
            let points = Set(pointsToKeys.keys)
            
            for source in pointsToKeys.keys {
                for destination in pointsToKeys.keys {
                    let diff = destination - source
                    let xDirection: Action = diff.x < 0 ?  .left : .right
                    let yDirection: Action = diff.y < 0 ? .up : .down
                    
                    let directions = [Action](repeating: xDirection, count: abs(diff.x)) + [Action](repeating: yDirection, count: abs(diff.y))
                    
                    for pathDirections in directions.uniquePermutations() {
                        let path = pathDirections.reduce(into: [source]) { $0.append($0.last! + $1.offset) }
                        
                        guard path.allSatisfy(points.contains) else { continue }
                        
                        let from = pointsToKeys[source]!
                        let to = pointsToKeys[destination]!
                        
                        edges[from, default: [:]][to, default: []].append(pathDirections)
                    }
                }
            }
        }
        
        func solve(from: String, to: String, keypads: [Keypad], cache: inout [CacheKey:Int]) -> Int {
            var length = Int.max
            
            for actions in edges[from]![to]! {
                let nextActions = actions + [ .activate ]
                let nextLength = keypads.first!.solve(actions: nextActions, keypads: keypads, cache: &cache)
            
                length = min(length, nextLength)
            }
            
            return length
        }
        
        func solve(actions: [Action], keypads: [Keypad], cache: inout [CacheKey:Int]) -> Int {
            guard !keypads.isEmpty else { return actions.count }
            
            let cacheKey = CacheKey(actions: actions, depth: keypads.count)
            
            if let value = cache[cacheKey] {
                return value
            }
            
            var nextKeypads = keypads
            nextKeypads.removeFirst()
            
            var key = "A"
            var totalLength = 0
            
            for action in actions {
                var length = Int.max
                
                let nextKey = action.debugDescription
                
                for actions in edges[key]![nextKey]! {
                    let nextActions = actions + [ .activate ]
                    let nextLength = solve(actions: nextActions, keypads: nextKeypads, cache: &cache)
                    
                    length = min(length, nextLength)
                }
                
                totalLength += length
                
                key = nextKey
            }
            
            cache[cacheKey] = totalLength
            
            return totalLength
        }
    }
    
    var codes: [String] {
        data.split(separator: "\n").map { String($0) }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() throws -> Any {
        var finalTotal = 0
        
        for code in codes {
            let value = Int(String(code.trimmingPrefix { $0 == "0" }.dropLast()))!
            
            let firstKeypad = Keypad.numeric
            let otherKeypads = [Keypad](repeating: .directional, count: 2)
            
            var total = 0
            
            var cache: [CacheKey:Int] = [:]
            var currentPosition = "A"
            
            for letter in code {
                let letter = String(letter)
                
                let length = firstKeypad.solve(from: currentPosition, to: letter, keypads: otherKeypads, cache: &cache)
                
                total += length
                currentPosition = letter
            }
            
            finalTotal += total * value
            
            print("\(code): \(total * value)")
        }
        
        return finalTotal
    }
    
    public func part2() throws -> Any {
        var finalTotal = 0
        
        for code in codes {
            let value = Int(String(code.trimmingPrefix { $0 == "0" }.dropLast()))!
            
            let firstKeypad = Keypad.numeric
            let otherKeypads = [Keypad](repeating: .directional, count: 25)
            
            var total = 0
            
            var cache: [CacheKey:Int] = [:]
            var currentPosition = "A"
            
            for letter in code {
                let letter = String(letter)
                
                let length = firstKeypad.solve(from: currentPosition, to: letter, keypads: otherKeypads, cache: &cache)
                
                total += length
                currentPosition = letter
            }
            
            finalTotal += total * value
            
            print("\(code): \(total * value)")
        }
        
        return finalTotal
    }
}
