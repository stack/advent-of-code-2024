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
    
    struct Maze {
        var width: Int = 0
        var height: Int = 0
        var spaces: Set<Point> = []
        var start: Point = .zero
        var end: Point = .zero
        
        func solve() -> Int {
            let startHeading = Heading(point: start, direction: .east)
            
            var frontier = PriorityQueue<Heading>()
            frontier.push(startHeading, priority: 0)
            
            var cameFrom: [Heading:Heading] = [:]
            var costSoFar: [Heading:Int] = [startHeading:0]
            
            while let heading = frontier.pop() {
                guard heading.point != end else { break }
                
                guard spaces.contains(heading.point) else { continue }
                
                for nextDirection in [heading.direction, heading.direction.turnedLeft, heading.direction.turnedRight] {
                    let turnCost = nextDirection == heading.direction ? 0 : 1000
                    let newCost = costSoFar[heading]! + 1 + turnCost
                    let nextHeading = Heading(point: heading.point + nextDirection.offset, direction: nextDirection)
                    
                    if costSoFar[nextHeading] == nil || newCost < costSoFar[nextHeading]! {
                        costSoFar[nextHeading] = newCost
                        frontier.push(nextHeading, priority: newCost)
                        
                        cameFrom[nextHeading] = heading
                    }
                }
            }
            
            let minimumCost = costSoFar.filter { $0.key.point == end }.values.min() ?? -1
            
            return minimumCost
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
}
