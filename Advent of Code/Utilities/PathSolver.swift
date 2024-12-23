//
//  PathSolver.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-22.
//  SPDX-License-Identifier: MIT
//

public protocol PathSolvable {
    associatedtype Location: Hashable
    
    var start: Location { get }
    var end: Location { get }
    
    func graphCost(from current: Location, to next: Location) -> Int
    func heuristic(from next: Location, to goal: Location) -> Int
    func neighbors(for point: Location) -> [Location]
}

public enum PathSolverError: Error {
    case noPath
}

public struct PathSolver<T: PathSolvable> {
    
    public var data: T
    public var frontier: PriorityQueue<T.Location> = PriorityQueue()
    public var cameFrom: [T.Location:T.Location] = [:]
    public var costSoFar: [T.Location:Int] = [:]
    
    public mutating func solve() throws -> [T.Location] {
        frontier.removeAll()
        cameFrom.removeAll()
        costSoFar.removeAll()
        
        frontier.push(data.start, priority: 0)
        costSoFar[data.start] = 0
        
        while let current = frontier.pop() {
            guard current != data.end else { break }
            
            for next in data.neighbors(for: current){
                let newCost = costSoFar[current]! + data.graphCost(from: current, to: next)
                
                if newCost < costSoFar[next, default: Int.max] {
                    costSoFar[next] = newCost
                    
                    let priority = newCost + data.heuristic(from: next, to: data.end)
                    frontier.push(next, priority: priority)
                    
                    cameFrom[next] = current
                }
            }
        }
        
        var current = data.end
        var path = [current]
        
        while current != data.start {
            guard let next = cameFrom[current] else {
                throw PathSolverError.noPath
            }
            
            path.insert(next, at: 0)
            
            current = next
        }
        
        return path
    }
}
