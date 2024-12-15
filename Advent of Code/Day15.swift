//
//  Day15.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-15.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day15: AdventDay {
    
    struct Warehouse {
        var width: Int = 0
        var height: Int = 0
        
        var boxes: Set<Point> = []
        var walls: Set<Point> = []
        var robot: Point = .zero
        var instructions: [Direction] = []
        
        func run() -> Warehouse {
            var nextWarehouse = self
            
            printWarehouse(direction: nil)
            
            while !nextWarehouse.instructions.isEmpty {
                let instruction = nextWarehouse.instructions.removeFirst()
                let nextPosition = nextWarehouse.robot + instruction.offset
                
                // Don't move if there is a wall
                guard !nextWarehouse.walls.contains(nextPosition) else {
                    // nextWarehouse.printWarehouse(direction: instruction)
                    continue
                }
                
                // Move is the space is empty
                guard nextWarehouse.boxes.contains(nextPosition) else {
                    nextWarehouse.robot = nextPosition
                    // nextWarehouse.printWarehouse(direction: instruction)
                    continue
                }
                
                // Find how many boxes are in a row
                var boxesToMove: Set<Point> = []
                var boxesPosition = nextPosition
                
                while nextWarehouse.boxes.contains(boxesPosition) {
                    boxesToMove.insert(boxesPosition)
                    boxesPosition = boxesPosition + instruction.offset
                }
                
                // If the tile after the boxes is a wall, do nothing
                guard !nextWarehouse.walls.contains(boxesPosition) else {
                    // nextWarehouse.printWarehouse(direction: instruction)
                    continue
                }
                
                // Move all of the boxes
                let movedBoxes = boxesToMove.map { $0 + instruction.offset }
                
                nextWarehouse.boxes.subtract(boxesToMove)
                nextWarehouse.boxes.formUnion(movedBoxes)
                
                nextWarehouse.robot = nextPosition
                
                // nextWarehouse.printWarehouse(direction: instruction)
            }
            
            return nextWarehouse
        }
        
        var score: Int {
            boxes.reduce(0) { $0 + ($1.y * 100) + $1.x }
        }
        
        func printWarehouse(direction: Direction?) {
            if let direction {
                print("Move: \(direction)")
            }
            
            for y in (0 ..< height) {
                for x in (0 ..< width) {
                    let point = Point(x: x, y: y)
                    
                    if walls.contains(point) {
                        print("#", terminator: "")
                    } else if boxes.contains(point) {
                        print("O", terminator: "")
                    } else if point == robot {
                        print("@", terminator: "")
                    } else {
                        print(".", terminator: "")
                    }
                }
                
                print()
            }
            
            print()
        }
    }
    
    struct WideWarehouse {
        var width: Int = 0
        var height: Int = 0
        
        var boxes: Set<Point> = []
        var walls: Set<Point> = []
        var robot: Point = .zero
        var instructions: [Direction] = []
        
        
        var score: Int {
            boxes.reduce(0) { $0 + ($1.y * 100) + $1.x }
        }
        
        func run(debug: Bool = false) -> WideWarehouse {
            var nextWarehouse = self
            
            if debug { printWarehouse(direction: nil) }
            
            mainLoop: while !nextWarehouse.instructions.isEmpty {
                let instruction = nextWarehouse.instructions.removeFirst()
                let nextPosition = nextWarehouse.robot + instruction.offset
                
                // Don't move if there is a wall
                guard !nextWarehouse.walls.contains(nextPosition) else {
                    if debug { nextWarehouse.printWarehouse(direction: instruction) }
                    continue
                }
                
                
                // Move if the space is empty
                let potentialBoxes = switch instruction {
                case .north, .south:
                    [nextPosition, nextPosition + Point(x: -1, y: 0)]
                case .east:
                    [nextPosition]
                case .west:
                    [nextPosition + Point(x: -1, y: 0)]
                }
                
                guard let collision = nextWarehouse.boxes.intersection(potentialBoxes).first else {
                    nextWarehouse.robot = nextPosition
                    if debug { nextWarehouse.printWarehouse(direction: instruction) }
                    continue
                }
                
                // Find how many boxes are in a row
                var boxesToMove: Set<Point> = []
                var boxesToVisit: [Point] = [collision]
                
                while !boxesToVisit.isEmpty {
                    let currentBox = boxesToVisit.removeFirst()
                    
                    guard nextWarehouse.boxes.contains(currentBox) else { continue }
                    
                    boxesToMove.insert(currentBox)
                    
                    switch instruction {
                    case .north:
                        boxesToVisit.append(currentBox + Point(x: -1, y: -1))
                        boxesToVisit.append(currentBox + Point(x: 0, y: -1))
                        boxesToVisit.append(currentBox + Point(x: 1, y: -1))
                    case .south:
                        boxesToVisit.append(currentBox + Point(x: -1, y: 1))
                        boxesToVisit.append(currentBox + Point(x: 0, y: 1))
                        boxesToVisit.append(currentBox + Point(x: 1, y: 1))
                    case .east:
                        boxesToVisit.append(currentBox + Point(x: 2, y: 0))
                    case .west:
                        boxesToVisit.append(currentBox + Point(x: -2, y: 0))
                    }
                }
                
                // If a tile is blocking any box, don't move it
                for box in boxesToMove {
                    let toCheck = switch instruction {
                    case .north: [box + Point(x: 0, y: -1), box + Point(x: 1, y: -1)]
                    case .south: [box + Point(x: 0, y: 1), box + Point(x: 1, y: 1)]
                    case .east: [box + Point(x: 2, y: 0)]
                    case .west: [box + Point(x: -1, y: 0)]
                    }
                    
                    guard nextWarehouse.walls.intersection(toCheck).isEmpty else {
                        if debug { nextWarehouse.printWarehouse(direction: instruction) }
                        continue mainLoop
                    }
                }
                
                // Move all of the boxes
                let movedBoxes = boxesToMove.map { $0 + instruction.offset }
                
                nextWarehouse.boxes.subtract(boxesToMove)
                nextWarehouse.boxes.formUnion(movedBoxes)
                
                nextWarehouse.robot = nextPosition
                
                if debug { nextWarehouse.printWarehouse(direction: instruction) }
            }
            
            return nextWarehouse

        }
        
        func printWarehouse(direction: Direction?) {
            if let direction {
                print("Move: \(direction)")
            }
            
            for y in (0 ..< height) {
                for x in (0 ..< width) {
                    let point = Point(x: x, y: y)
                    let previousPoint = Point(x: x - 1, y: y)
                    
                    if walls.contains(point) {
                        print("#", terminator: "")
                    } else if boxes.contains(point) {
                        print("[", terminator: "")
                    } else if boxes.contains(previousPoint) {
                        print("]", terminator: "")
                    } else if point == robot {
                        print("@", terminator: "")
                    } else {
                        print(".", terminator: "")
                    }
                }
                
                print()
            }
            
            print()
        }
    }
    
    public var data: String
    
    var warehouses: [Warehouse] {
        let blobs = data.split(separator: "\n\n")
        
        var result: [Warehouse] = []
        
        for index in stride(from: 0, to: blobs.count, by: 2) {
            var warehouse = Warehouse()
            
            for (y, row) in blobs[index].split(separator: "\n").enumerated() {
                warehouse.height += 1
                warehouse.width = row.count
                
                for (x, letter) in row.enumerated() {
                    let point = Point(x: x, y: y)
                    
                    switch letter {
                    case "#":
                        warehouse.walls.insert(point)
                    case "@":
                        warehouse.robot = point
                    case "O":
                        warehouse.boxes.insert(point)
                    default: break
                    }
                    
                }
            }
            
            warehouse.instructions = blobs[index + 1].compactMap {
                switch $0 {
                case "^": .north
                case "<": .west
                case ">": .east
                case "v": .south
                case "\n": nil
                default: fatalError("Unknown instruction: \($0)")
                }
            }
            
            result.append(warehouse)
        }
        
        return result
    }
    
    var wideWarehouses: [WideWarehouse] {
        let blobs = data.split(separator: "\n\n")
        
        var result: [WideWarehouse] = []
        
        for index in stride(from: 0, to: blobs.count, by: 2) {
            var warehouse = WideWarehouse()
            
            for (y, row) in blobs[index].split(separator: "\n").enumerated() {
                warehouse.height += 1
                warehouse.width = row.count * 2
                
                for (x, letter) in row.enumerated() {
                    let point1 = Point(x: x * 2, y: y)
                    let point2 = Point(x: x * 2 + 1, y: y)

                    switch letter {
                    case "#":
                        warehouse.walls.insert(point1)
                        warehouse.walls.insert(point2)
                    case "@":
                        warehouse.robot = point1
                    case "O":
                        warehouse.boxes.insert(point1)
                    default: break
                    }
                }
            }
            
            warehouse.instructions = blobs[index + 1].compactMap {
                switch $0 {
                case "^": .north
                case "<": .west
                case ">": .east
                case "v": .south
                case "\n": nil
                default: fatalError("Unknown instruction: \($0)")
                }
            }
            
            result.append(warehouse)
        }
        
        return result
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var latest = 0
        
        for warehouse in warehouses {
            let finalWarehouse = warehouse.run()
            latest = finalWarehouse.score
        }
        
        return latest
    }
    
    public func part2() async throws -> Any {
        var latest = 0
        
        for warehouse in wideWarehouses {
            let finalWarehouse = warehouse.run(debug: false)
            latest = finalWarehouse.score
            
            finalWarehouse.printWarehouse(direction: nil)
            print("Score: \(latest)")
        }
        
        return latest
    }
}
