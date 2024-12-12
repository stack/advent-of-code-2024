//
//  Day12.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-12.
//  SPDX-License-Identifier: MIT
//

import Algorithms
import Foundation

public struct Day12: AdventDay {
    
    struct Map {
        var plots: [Point:Character] = [:]
        
        var regions: [Region] {
            var remaining = Set(plots.keys)
            var regions: [Region] = []
            
            while !remaining.isEmpty {
                let currentPoint = remaining.removeFirst()
                let letter = plots[currentPoint]!
                
                var region = Region(letter: letter, plots: [currentPoint])
                var toVisit = currentPoint.cardinalNeighbors
                
                while !toVisit.isEmpty {
                    let neighborPoint = toVisit.removeFirst()
                    
                    guard remaining.contains(neighborPoint) else { continue }
                    guard let neighborLetter = plots[neighborPoint] else { continue }
                    
                    if neighborLetter == letter {
                        region.plots.insert(neighborPoint)
                        remaining.remove(neighborPoint)
                        
                        toVisit.append(contentsOf: neighborPoint.cardinalNeighbors)
                    }
                }
                
                regions.append(region)
            }
            
            return regions
        }
    }
    
    struct Region {
        var letter: Character
        var plots: Set<Point>
        
        var area: Int { plots.count }
        
        var perimeter: Int {
            var count = 0
            
            for plot in plots {
                for neighbor in plot.cardinalNeighbors {
                    if !plots.contains(neighbor) {
                        count += 1
                    }
                }
            }
            
            return count
        }
        
        var sides: Int {
            let center = Point.zero
            
            return center.cardinalNeighbors.reduce(0) { $0 + sides(for: $1) }
        }
        
        var price: Int { area * perimeter }
        var bulkPrice: Int { area * sides }
        
        private func sides(for offset: Point) -> Int {
            var adjacentPlots: Set<Point> = []
            
            for plot in plots {
                let neighbor = plot + offset
                
                if !plots.contains(neighbor) {
                    adjacentPlots.insert(neighbor)
                }
            }
            
            let groups = adjacentPlots.grouped { offset.x == 0 ? $0.y : $0.x }.values
            let sets = groups.map { $0.map { offset.x == 0 ? $0.x : $0.y }.sorted() }
            let diffs = sets.map { $0.adjacentPairs().map { $1 - $0 } }
            let sides = diffs.map { $0.filter { $0 != 1 }.count + 1 }
            
            return sides.reduce(0, +)
        }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    var maps: [Map] {
        let blobs = data.split(separator: "\n\n")
        
        var maps: [Map] = []
        
        for blob in blobs {
            var map = Map()
            
            for (y, row) in blob.split(separator: "\n").enumerated() {
                for (x, letter) in row.enumerated() {
                    let point = Point(x: x, y: y)
                    map.plots[point] = letter
                }
            }
            
            maps.append(map)
        }
        
        return maps
    }
    
    public func part1() async throws -> Any {
        var latest = 0
        
        for map in maps {
            var total = 0
            
            for region in map.regions {
                print("A region of \(region.letter) plants with price \(region.area) * \(region.perimeter) = \(region.price)")
                total += region.price
            }
            
            latest = total
            
            print()
        }
        
        return latest
    }
    
    public func part2() async throws -> Any {
        var latest = 0
        
        for map in maps {
            var total = 0
            
            for region in map.regions {
                print("A region of \(region.letter) plants with price \(region.area) * \(region.sides) = \(region.bulkPrice)")
                total += region.bulkPrice
            }
            
            print("Total: \(total)")
            
            latest = total
            
            print()
        }
        
        return latest
        
    }
}
