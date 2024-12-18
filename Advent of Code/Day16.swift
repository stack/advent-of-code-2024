//
//  Day16.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-16.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day16: AdventDay {
    
    struct Heading: Hashable {
        var point: Point
        var direction: Direction
    }
    
    struct HeadingCost: Hashable {
        var heading: Heading
        var cost: Int
        
        var point: Point { heading.point }
        var direction: Direction { heading.direction }
    }
    
    struct Maze {
        var width: Int = 0
        var height: Int = 0
        var spaces: Set<Point> = []
        var start: Point = .zero
        var end: Point = .zero
        
        func traverse(start: Heading, cameFrom: inout [Heading:Heading], costSoFar: inout [Heading:Int]) {
            var frontier = PriorityQueue<Heading>()
            frontier.push(start, priority: 0)
            
            costSoFar[start] = 0
            
            while let heading = frontier.pop() {
                guard heading.point != end else { break }
                
                guard spaces.contains(heading.point) else { continue }
                
                for nextDirection in [heading.direction, heading.direction.turnedLeft, heading.direction.turnedRight] {
                    let turnCost = nextDirection == heading.direction ? 1 : 1000
                    let newCost = costSoFar[heading]! + turnCost
                    let nextPosition = nextDirection == heading.direction ? heading.point + nextDirection.offset : heading.point
                    let nextHeading = Heading(point: nextPosition, direction: nextDirection)
                    
                    if costSoFar[nextHeading] == nil || newCost < costSoFar[nextHeading]! {
                        costSoFar[nextHeading] = newCost
                        frontier.push(nextHeading, priority: newCost)
                        
                        cameFrom[nextHeading] = heading
                    }
                }
            }
        }
        
        func backtrack(end: HeadingCost, cameFrom: inout [Heading:Heading], costSoFar: inout [Heading:Int]) -> Int {
            var visited: Set<Point> = []
            var frontier = PriorityQueue<HeadingCost>()
            frontier.push(end, priority: 0)
            
            while let heading = frontier.pop() {
                guard spaces.contains(heading.point) else { continue }
                
                visited.insert(heading.point)
                
                guard heading.point != start else { continue }
                
                for nextDirection in [heading.direction.reversed, heading.direction.turnedLeft, heading.direction.turnedRight] {
                    let nextPosition: Point
                    let turnCost: Int
                    
                    if nextDirection == heading.direction.reversed {
                        nextPosition = heading.point + nextDirection.offset
                        turnCost = 1
                    } else {
                        nextPosition = heading.point
                        turnCost = 1000
                    }
                    
                    let nextCost = heading.cost - turnCost
                    
                    let lookupDirection = nextDirection.reversed
                    let lookupHeading = Heading(point: nextPosition, direction: lookupDirection)
                    
                    let nextHeadingCost = HeadingCost(heading: lookupHeading, cost: nextCost)
                    
                    if nextCost == costSoFar[lookupHeading] {
                        frontier.push(nextHeadingCost, priority: nextCost)
                    }
                }
            }
            
            for point in Point.allValues(width: width, height: height) {
                if point.x == 0 {
                    print()
                }
                
                if visited.contains(point) {
                    print("O", terminator: "")
                } else if spaces.contains(point) {
                    print(".", terminator: "")
                } else {
                    print("#", terminator: "")
                }
            }
            
            return visited.count
        }
        
        func solve() -> Int {
            let startHeading = Heading(point: start, direction: .east)
            
            var cameFrom: [Heading:Heading] = [:]
            var costSoFar: [Heading:Int] = [:]
            
            traverse(start: startHeading, cameFrom: &cameFrom, costSoFar: &costSoFar)
            
            let minimumCost = costSoFar.filter { $0.key.point == end }.values.min() ?? -1
            
            return minimumCost
        }
        
        func solve2() -> Int {
            let startHeading = Heading(point: start, direction: .east)
            
            var cameFrom: [Heading:Heading] = [:]
            var costSoFar: [Heading:Int] = [:]
            
            traverse(start: startHeading, cameFrom: &cameFrom, costSoFar: &costSoFar)
            
            let minimumCost = costSoFar.filter { $0.key.point == end }.values.min() ?? -1

            guard let endHeading = costSoFar.filter({ $0.key.point == end && $0.value == minimumCost }).keys.first else {
                return -1
            }
            
            let headingCost = HeadingCost(heading: endHeading, cost: minimumCost)
            
            let count = backtrack(end: headingCost, cameFrom: &cameFrom, costSoFar: &costSoFar)
            
            return count
        }
    }
    
    public var data: String
    
    var mazes: [Maze] {
        var result: [Maze] = []
        
        for blob in data.split(separator: "\n\n") {
            var maze = Maze()
            
            for (y, line) in blob.split(separator: "\n").enumerated() {
                maze.height += 1
                maze.width = line.count
                
                for (x, letter) in line.enumerated() {
                    guard letter != "#" else { continue }
                    
                    let point = Point(x: x, y: y)
                    
                    if letter == "S" {
                        maze.start = point
                    } else if letter == "E" {
                        maze.end = point
                    }
                    
                    maze.spaces.insert(point)
                }
                
            }
            
            result.append(maze)
        }
        
        return result
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var latest = 0
        
        for maze in mazes {
            latest = maze.solve()
            print("Min: \(latest)")
        }
        
        return latest
    }
    
    public func part2() async throws -> Any {
        var latest = 0
        
        for maze in mazes {
            latest = maze.solve2()
            print("Count: \(latest)")
        }
        
        return latest
    }
}
