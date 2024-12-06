//
//  Day6.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-06.
//  SPDX-License-Identifier: MIT
//

public struct Day6: AdventDay {
    
    enum Run {
        case success(State)
        case loop(State)
    }
    
    struct Stop: Hashable {
        var position: Point
        var direction: Direction
    }
    
    struct State: Sendable {
        var position: Point = Point(x: 0, y: 0)
        var direction: Direction = .north
        var width: Int = 0
        var height: Int = 0
        var blocked: Set<Point> = []
        var used: Set<Point> = []
        var stops: Set<Stop> = []
        
        var inBounds: Bool {
            guard position.x >= 0 && position.x < width else { return false }
            guard position.y >= 0 && position.y < height else { return false }
            
            return true
        }
        
        var lineOfSight: [Point] {
            switch direction {
            case .north:
                return (-1 ... position.y-1).reversed().map { Point(x: position.x, y: $0) }
            case .south:
                return (position.y+1 ... height).map { Point(x: position.x, y: $0) }
            case .east:
                return (position.x+1 ... width).map { Point(x: $0, y: position.y)}
            case .west:
                return (-1 ... position.x-1).reversed().map { Point(x: $0, y: position.y)}
            }
        }
        
        mutating func turn() {
            direction = direction.turnedRight
        }
        
        func run() -> Run {
            var currentState = self
            
            while currentState.inBounds {
                let line = currentState.lineOfSight
                
                if let collisionIndex = line.firstIndex(where: { currentState.blocked.contains($0) }) {
                    if collisionIndex > 0 {
                        currentState.position = line[collisionIndex-1]
                        currentState.used.formUnion(line[0 ... collisionIndex-1])
                    }
                    
                    currentState.turn()
                    
                    let stop = Stop(position: currentState.position, direction: currentState.direction)
                    
                    if currentState.stops.contains(stop) {
                        return .loop(currentState)
                    } else {
                        currentState.stops.insert(stop)
                    }
                } else {
                    currentState.position = line.last!
                    currentState.used.formUnion(line)
                }
            }
            
            return .success(currentState)
        }

        func printState() {
            let result = (0 ..< height).map { y in
                (0 ..< width).map { x in
                    let point = Point(x: x, y: y)
                    
                    if point == position {
                        return direction.debugDescription
                    } else if used.contains(point) {
                        return "X"
                    } else if blocked.contains(point) {
                        return "#"
                    } else {
                        return "."
                    }
                }
                .joined()
            }
            .joined(separator: "\n")
            
            print(result)
            print()
        }
    }
    
    public var data: String
    private let parallelize: Bool = true
    
    public init(data: String) {
        self.data = data
    }
    
    var initialState: State {
        var position = Point(x: 0, y: 0)
        let direction: Direction = .north
        var blocked: Set<Point> = []
        var width: Int = 0
        var height: Int = 0
        
        for (y, row) in data.split(separator: "\n").enumerated() {
            for (x, letter) in row.enumerated() {
                if letter == "#" {
                    blocked.insert(Point(x: x, y: y))
                } else if letter == "^" {
                    position = Point(x: x, y: y)
                }
            }
            
            width = row.count
            height += 1
        }
        
        let used: Set<Point> = [position]
        let stops: Set<Stop> = []
        
        return State(
            position: position,
            direction: direction,
            width: width,
            height: height,
            blocked: blocked,
            used: used,
            stops: stops
        )
    }
    
    public func part1() async throws -> Any {
        let result = initialState.run()
        
        switch result {
        case .loop(_): fatalError("Loop on a non-looping run")
        case .success(let state): return state.used.count - 1
        }
    }
    
    public func part2() async throws -> Any {
        // Do the initial run to get a list of used spaces
        let startState = initialState
        guard case .success(let completeState) = startState.run() else {
            fatalError("Loop on a non-looping run")
        }
        
        var usedSpaces = completeState.used
        usedSpaces.remove(startState.position)
        
        if parallelize {
            return try await part2Parallel(usedSpaces: usedSpaces)
        } else {
            return try await part2Serial(usedSpaces: usedSpaces)
        }
    }
    
    func part2Parallel(usedSpaces: Set<Point>) async throws -> Any {
        let initialState = initialState
        
        return try await withThrowingTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
            for usedSpace in usedSpaces {
                var taskState = initialState
                taskState.blocked.insert(usedSpace)
                
                taskGroup.addTask {
                    switch taskState.run() {
                    case .loop(_): return 1
                    case .success(_): return 0
                    }
                }
            }
            
            return try await taskGroup.reduce(0, +)
        }
    }
    
    func part2Serial(usedSpaces: Set<Point>) async throws -> Any {
        // Run each state, blocking an above space, accumulating loops
        var count = 0
        
        for usedSpace in usedSpaces {
            var startState = initialState
            startState.blocked.insert(usedSpace)
            
            switch startState.run() {
            case .loop(_):
                // print("Loop when blocking \(usedSpace)")
                count += 1
            case .success(_):
                // print("Completion when blocking \(usedSpace)")
                break
            }
        }
        
        return count
    }
    
}
