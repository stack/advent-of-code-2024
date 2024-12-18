//
//  Day18.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-18.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day18: AdventDay {
    
    struct MemorySpace {
        var width: Int = 0
        var height: Int = 0
        
        var falling: [Point] = []
        var corrupted: Set<Point> = []
        
        @discardableResult mutating func run(nanoseconds: Int) -> [Point] {
            let corruptedPoints = falling[..<nanoseconds]
            corrupted.formUnion(corruptedPoints)
            
            falling.removeFirst(nanoseconds)
            
            return Array(corruptedPoints)
        }
        
        func traverse() -> [Point] {
            let start = Point(x: 0, y: 0)
            let end = Point(x: width - 1, y: height - 1)
            
            var frontier = PriorityQueue<Point>()
            frontier.push(start, priority: 0)
            
            var cameFrom: [Point: Point] = [:]
            var costSoFar: [Point: Int] = [start : 0]
            
            while let currentPoint = frontier.pop() {
                guard currentPoint != end else {
                    break
                }
                
                guard currentPoint.x >= 0 && currentPoint.x < width else { continue }
                guard currentPoint.y >= 0 && currentPoint.y < height else { continue }
                guard !corrupted.contains(currentPoint) else { continue }

                for neighbor in currentPoint.cardinalNeighbors {
                    let newCost = costSoFar[currentPoint]! + 1
                    
                    if costSoFar[neighbor] == nil || newCost < costSoFar[neighbor]! {
                        costSoFar[neighbor] = newCost
                        
                        let priority = newCost + neighbor.manhattenDistance(to: end)
                        frontier.push(neighbor, priority: priority)
                        
                        cameFrom[neighbor] = currentPoint
                    }
                }
            }
            
            var currentPoint = end
            var path: [Point] = [end]
            
            while currentPoint != start {
                guard let nextPoint = cameFrom[currentPoint] else {
                    path.removeAll()
                    break
                }
                
                path.append(nextPoint)
                
                currentPoint = nextPoint
            }
            
            return path
        }
    }
    
    var memorySpace: MemorySpace {
        var memorySpace = MemorySpace()
        
        for line in data.split(separator: "\n") {
            let parts = line.split(separator: ",")
            
            let point = Point(x: Int(parts[0])!, y: Int(parts[1])!)
            
            memorySpace.falling.append(point)
            memorySpace.width = max(memorySpace.width, point.x + 1)
            memorySpace.height = max(memorySpace.height, point.y + 1)
        }
        
        return memorySpace
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var memorySpace = self.memorySpace
        let nanoseconds = memorySpace.width == 7 ? 12 : 1024
        
        memorySpace.run(nanoseconds: nanoseconds)
        return memorySpace.traverse().count - 1
    }
    
    public func part2() async throws -> Any {
        var memorySpace = self.memorySpace
        var currentPath = memorySpace.traverse()
        var lastCorruption: Set<Point> = []
        
        while !currentPath.isEmpty {
            lastCorruption = Set(memorySpace.run(nanoseconds: 1))
            
            if !lastCorruption.intersection(currentPath).isEmpty {
                currentPath = memorySpace.traverse()
            }
        }
        
        return lastCorruption
    }
}
