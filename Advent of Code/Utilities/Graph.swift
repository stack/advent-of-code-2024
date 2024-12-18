//
//  Graph.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-17.
//  SPDX-License-Identifier: MIT
//

public struct Graph<Vertex: Hashable, Category: Hashable>: CustomDebugStringConvertible {
    
    typealias EdgeDictionary = [Category:[Vertex:(Vertex,Int)]]
    
    private(set) public var nodes: Set<Vertex> = []
    private var edges: EdgeDictionary = [:]
    
    public var count: Int { nodes.count }
    
    public mutating func insert(_ vertex: Vertex) {
        nodes.insert(vertex)
    }
    
    public mutating func remove(_ vertex: Vertex) {
        nodes.remove(vertex)
        
        edges = edges.mapValues { edges in
            var nextEdges = edges
            nextEdges.removeValue(forKey: vertex)
            
            nextEdges = nextEdges.filter { targets in
                targets.value.0 != vertex
            }
            
            return nextEdges
        }
    }
    
    public mutating func addEdge(type: Category, from: Vertex, to: Vertex, weight: Int) {
        edges[type, default: [:]][from] = (to, weight)
    }
    
    public mutating func removeEdge(type: Category, from: Vertex)  {
        edges[type, default: [:]].removeValue(forKey: from)
    }
    
    public func edge(type: Category, from: Vertex) -> (Vertex, Int)? {
        edges[type]?[from]
    }
    
    public func totalEdges(from: Vertex) -> Int {
        var count = 0
        
        for edge in edges.values {
            if edge[from] != nil {
                count += 1
            }
        }
        
        return count
    }
    
    public func first(where predicate: (Vertex) -> Bool) -> Vertex? {
        for vertex in nodes {
            if predicate(vertex) {
                return vertex
            }
        }
        
        return nil
    }
    
    public var debugDescription: String {
        var result = ""
        
        for node in nodes {
            result += "\(node)"
            
            for (key, value) in edges {
               if let edge = value[node] {
                    result += "\n- \(key): \(edge)"
                }
            }
            
            result += "\n"
        }
        
        return result
    }
}
