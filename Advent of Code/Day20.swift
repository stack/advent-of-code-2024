//
//  Day20.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-20.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day20: AdventDay {
    
    struct Racetrack {
        var width: Int = 0
        var height: Int = 0
        var walls: Set<Point> = []
        var spaces: Set<Point> = []
        var start: Point = .zero
        var end: Point = .zero
        
        var fastestPath: ([Point], [Point:Int]) {
            var frontier = PriorityQueue<Point>()
            frontier.push(start, priority: 0)
            
            var cameFrom: [Point: Point] = [:]
            var costSoFar: [Point: Int] = [start:0]
            
            while let current = frontier.pop() {
                guard current != end else { break }
                
                for next in current.cardinalNeighbors {
                    guard spaces.contains(next) else { continue }
                    
                    let newCost = costSoFar[current]! + 1
                    
                    if costSoFar[next] == nil || newCost < costSoFar[next]! {
                        costSoFar[next] = newCost
                        
                        let priority = newCost + next.manhattenDistance(to: end)
                        frontier.push(next, priority: priority)
                        
                        cameFrom[next] = current
                    }
                }
            }
            
            var current = end
            var path = [end]
            
            while current != start {
                guard let next = cameFrom[current] else {
                    fatalError("No full path found")
                }
                
                path.insert(next, at: 0)
                
                current = next
            }
            
            return (path, costSoFar)
        }
    }
    
    var racetrack: Racetrack {
        var racetrack = Racetrack()
        
        for (y, line) in data.split(separator: "\n").enumerated() {
            racetrack.height += 1
            racetrack.width = line.count
            
            for (x, character) in line.enumerated() {
                let point = Point(x: x, y: y)
                
                switch character {
                case "#":
                    racetrack.walls.insert(point)
                case ".":
                    racetrack.spaces.insert(point)
                case "S":
                    racetrack.start = point
                    racetrack.spaces.insert(point)
                case "E":
                    racetrack.end = point
                    racetrack.spaces.insert(point)
                default:
                    fatalError("Unhandled tile: \(character)")
                }
            }
        }
        
        return racetrack
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let initialRacetrack = racetrack
        let (bestPath, costs) = initialRacetrack.fastestPath
        
        print("Best Path: \(bestPath)")
        
        var totalCheats = 0
        var highCheats = 0
        
        for point in bestPath {
            guard let pointCost = costs[point] else { continue }
            
            for vector in Point.cardinalVectors {
                let wallPoint = point + vector
                let spacePoint = wallPoint + vector
                
                guard racetrack.walls.contains(wallPoint) else { continue }
                guard let spaceCost = costs[spacePoint] else { continue }
                guard spaceCost > pointCost else { continue }
                
                let savings = spaceCost - pointCost - 2
                print("Cheat at \(wallPoint) + \(spacePoint) saves \(savings)")
                
                totalCheats += 1
                
                if savings >= 100 {
                    highCheats += 1
                }
            }
        }
        
        return highCheats
    }
    
    public func part2() async throws -> Any {
        let initialRacetrack = racetrack
        let (bestPath, costs) = initialRacetrack.fastestPath
        let bestPathSet = Set(bestPath)
        
        var totalCheats = 0
        var highCheats = 0
        var highestCheats = 0
        
        for point in bestPath {
            let pointCost = costs[point]!
            
            let nextPoints = bestPath.filter {
                let distance = point.manhattenDistance(to: $0)
                guard distance > 0 && distance <= 20 else { return false }
                guard bestPathSet.contains($0) else { return false }
                
                return true
            }
            
            for nextPoint in nextPoints {
                let nextCost = costs[nextPoint]!
                
                guard nextCost > pointCost else { continue }
                
                let savings = nextCost - pointCost - point.manhattenDistance(to: nextPoint)
                guard savings > 0 else { continue }
                
                print("Cheat from \(point) to \(nextPoint) saves \(savings)")

                totalCheats += 1
                
                if savings >= 50 {
                    highCheats += 1
                }
                
                if savings >= 100 {
                    highestCheats += 1
                }
            }
        }
        
        print("Total Cheats: \(totalCheats)")
        print("High Cheats: \(highCheats)")
        print("Highest Cheats: \(highestCheats)")
        
        return highCheats
    }
}
