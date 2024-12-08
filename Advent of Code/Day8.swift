//
//  Day8.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-08.
//  SPDX-License-Identifier: MIT
//

import Algorithms

public struct Day8: AdventDay {
    
    struct Map {
        var frequencies: [String:Set<Point>]
        var width: Int
        var height: Int
        
        var anitnodes: Set<Point> {
            var antinodes: [String:Set<Point>] = [:]
            
            for (frequency, points) in frequencies {
                for combo in points.uniquePermutations(ofCount: 2) {
                    let diff = combo[0] - combo[1]
                    let lhs = combo[0] + diff
                    let rhs = combo[1] - diff
                    
                    if inBounds(lhs) {
                        print("\(frequency): \(combo[0]) + \(combo[1]) = \(lhs)")
                        antinodes[frequency, default: []].insert(lhs)
                    }
                    
                    if inBounds(rhs) {
                        print("\(frequency): \(combo[0]) + \(combo[1]) = \(rhs)")
                        antinodes[frequency, default: []].insert(rhs)
                    }
                }
            }
            
            let allAntinodes = antinodes.reduce(into: Set<Point>()) {
                $0.formUnion($1.value)
            }
            
            return allAntinodes
        }
        
        var allAntinodes: Set<Point> {
            var antinodes: [String:Set<Point>] = [:]
            
            for (frequency, points) in frequencies {
                for combo in points.uniquePermutations(ofCount: 2) {
                    let diff = combo[0] - combo[1]
                    
                    var current = combo[0]
                    while inBounds(current) {
                        antinodes[frequency, default: []].insert(current)
                        current = current + diff
                    }
                    
                    current = combo[1]
                    while inBounds(current) {
                        antinodes[frequency, default: []].insert(current)
                        current = current - diff
                    }
                }
            }
            
            let allAntinodes = antinodes.reduce(into: Set<Point>()) {
                $0.formUnion($1.value)
            }
            
            return allAntinodes
        }
        
        private func inBounds(_ point: Point) -> Bool {
            guard point.x >= 0 && point.x < width else { return false }
            guard point.y >= 0 && point.y < height else { return false }
            
            return true
        }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    var map: Map {
        var result: [String:Set<Point>] = [:]
        
        var width = 0
        var height = 0
        
        for (y, row) in data.split(separator: "\n").enumerated() {
            width = row.count
            height += 1
            
            for (x, letter) in row.enumerated() {
                guard letter != "." else { continue }
                
                let key = String(letter)
                
                result[key, default: []].insert(Point(x: x, y: y))
            }
        }
        
        return Map(frequencies: result, width: width, height: height)
    }
    
    public func part1() async throws -> Any {
        map.anitnodes.count
    }
    
    public func part2() async throws -> Any {
        map.allAntinodes.count
    }
    
    func printMap(_ map: Map) {
        print("Antenna:")
        
        for y in 0 ..< map.height {
            let row = (0 ..< map.width).map { x in
                let point = Point(x: x, y: y)
                
                for (key, value) in map.frequencies {
                    if value.contains(point) {
                        return key
                    }
                }
                
                return "."
            }
            .joined()
            
            print(row)
        }
        
        print()
        print("Antinodes:")
        
        let antinodes = map.anitnodes
        
        for y in 0 ..< map.height {
            let row = (0 ..< map.width).map { x in
                let point = Point(x: x, y: y)
                
                return antinodes.contains(point) ? "#" : "."
            }
            .joined()
            
            print(row)
        }

    }
    
}
