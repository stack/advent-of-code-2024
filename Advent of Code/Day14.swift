//
//  Day14.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-14.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day14: AdventDay {
    
    public struct Robot {
        public var position: Point
        public var velocity: Point
        
        public init(position: Point, velocity: Point) {
            self.position = position
            self.velocity = velocity
        }
    }
    
    public struct Floor {
        public var width: Int
        public var height: Int
        public var robots: [Robot]
        
        public init(width: Int, height: Int, robots: [Robot]) {
            self.width = width
            self.height = height
            self.robots = robots
        }
        
        public var safetyScore: Int {
            let midX = width / 2
            let midY = height / 2
            
            var quadrants = [Int](repeating: 0, count: 4)
            
            for robot in robots {
                if robot.position.x < midX && robot.position.y < midY {
                    quadrants[0] += 1
                } else if robot.position.x > midX && robot.position.y < midY {
                    quadrants[1] += 1
                } else if robot.position.x < midX && robot.position.y > midY {
                    quadrants[2] += 1
                } else if robot.position.x > midX && robot.position.y > midY {
                    quadrants[3] += 1
                }
            }
            
            return quadrants.reduce(1, *)
        }
        
        public func run(times: Int) -> Floor {
            var nextFloor = self
            
            for _ in (0 ..< times) {
                nextFloor.robots = nextFloor.robots.map {
                    var nextPosition = $0.position + $0.velocity
                    nextPosition.x = mod(nextPosition.x, width)
                    nextPosition.y = mod(nextPosition.y, height)
                    
                    return Robot(position: nextPosition, velocity: $0.velocity)
                }
            }
            
            
            return nextFloor
        }
        
        func printFloor(withLines: Bool = false) {
            let midX = width / 2
            let midY = height / 2
            
            for y in 0 ..< height {
                for x in 0 ..< width {
                    let point = Point(x: x, y: y)
                    let count = robots.count(where: { $0.position == point })
                    
                    if withLines && (point.x == midX || point.y == midY) {
                        print(" ", terminator: "")
                    } else if count > 0 {
                        print(count, terminator: "")
                    } else {
                        print(".", terminator: "")
                    }
                }
                
                print()
            }
        }
    }
    
    public var data: String
    
    var floor: Floor {
        let regex = /^p=(\d+),(\d+) v=(-?\d+),(-?\d+)/
        var floor = Floor(width: 0, height: 0, robots: [])
        
        for line in data.split(separator: "\n") {
            let match = line.firstMatch(of: regex)!
            
            let pX = Int(match.output.1)!
            let pY = Int(match.output.2)!
            let vX = Int(match.output.3)!
            let vY = Int(match.output.4)!
            
            floor.width = max(floor.width, pX + 1)
            floor.height = max(floor.height, pY + 1)
            
            floor.robots.append(Robot(position: Point(x: pX, y: pY), velocity: Point(x: vX, y: vY)))
        }
        
        return floor
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        return floor.run(times: 100).safetyScore
    }
}
