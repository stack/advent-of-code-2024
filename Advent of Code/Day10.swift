//
//  Day10.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-10.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day10: AdventDay {
    
    struct Trail {
        var heads: Set<Point>
        var tiles: [Point:Int]
        
        init<T: StringProtocol>(data: T) {
            var heads: Set<Point> = []
            var tiles: [Point:Int] = [:]
            
            for (y, line) in data.split(separator: "\n").enumerated() {
                for (x, character) in line.enumerated() {
                    guard let value = character.wholeNumberValue else { continue }
                    
                    let point = Point(x: x, y: y)
                    tiles[point] = value
                    
                    if value == 0 {
                        heads.insert(point)
                    }
                }
            }
            
            self.heads = heads
            self.tiles = tiles
        }
        
        func hike() async -> Int {
            await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
                for head in heads {
                    taskGroup.addTask {
                        hike(from: head).count
                    }
                }
                
                return await taskGroup.reduce(0) { $0 + $1 }
            }
        }
        
        func hike(from point: Point) -> Set<Point> {
            var remaining = [point]
            var found: Set<Point> = []
            
            while !remaining.isEmpty {
                let current = remaining.removeFirst()
                guard let currentValue = tiles[current] else { continue }
                
                if currentValue == 9 {
                    found.insert(current)
                    continue
                }
                
                for neighbor in current.cardinalNeighbors {
                    guard let value = tiles[neighbor] else { continue }
                    
                    if value == currentValue + 1 {
                        remaining.append(neighbor)
                    }
                }
            }
            
            return found
        }
        
        func hikeBetter() async -> Int {
            await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
                for head in heads {
                    taskGroup.addTask {
                        hikeBetter(from: head)
                    }
                }
                
                return await taskGroup.reduce(0) { $0 + $1 }
            }
        }
        
        func hikeBetter(from point: Point) -> Int {
            var remaining = [point]
            var found = 0
            
            while !remaining.isEmpty {
                let current = remaining.removeFirst()
                guard let currentValue = tiles[current] else { continue }
                
                if currentValue == 9 {
                    found += 1
                    continue
                }
                
                for neighbor in current.cardinalNeighbors {
                    guard let value = tiles[neighbor] else { continue }
                    
                    if value == currentValue + 1 {
                        remaining.append(neighbor)
                    }
                }
            }
            
            return found
        }
    }
    
    public var data: String
    
    var trails: [Trail] {
        data
            .split(separator: "\n\n")
            .map { Trail(data: $0) }
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var latest = 0
        
        for trail in trails {
            latest = await trail.hike()
            print(latest)
        }
        
        return latest
    }
    
    public func part2() async throws -> Any {
        var latest = 0
        
        for trail in trails {
            latest = await trail.hikeBetter()
            print(latest)
        }
        
        return latest
    }
}
