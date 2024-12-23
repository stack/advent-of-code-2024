//
//  Day23.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-23.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day23: AdventDay {
    
    struct Network {
        var nodes: Set<String> = []
        var edges: [String:Set<String>] = [:]
        
        var interconnected: Set<[String]> {
            let tNodes = nodes.filter { $0.hasPrefix("t") && edges[$0]!.count >= 2 }
            
            var results: Set<[String]> = []
            
            for rootNode in tNodes {
                for leftNode in edges[rootNode]! {
                    for rightNode in edges[rootNode]! {
                        guard leftNode != rightNode else { continue }
                        guard edges[leftNode]!.contains(rightNode) else { continue }
                        
                        let group = [rootNode, leftNode, rightNode].sorted()
                        results.insert(group)
                    }
                }
            }
            
            return results
        }
        
        var maximalClique: [String] {
            var cliques: [[String]] = []
            
            bronKerbosch(p: nodes, cliques: &cliques)
            
            return cliques.max { $0.count < $1.count }!
        }
        
        private func bronKerbosch(p: Set<String>, r: Set<String> = [], x: Set<String> = [], cliques: inout [[String]]) {
            if p.isEmpty && x.isEmpty {
                cliques.append(r.sorted())
            }
            
            var nextP = p
            var nextX = x
            
            for node in p {
                let v = Set([node])
                let n = edges[node, default: []]
                
                bronKerbosch(p: nextP.intersection(n), r: r.union(v), x: nextX.intersection(n), cliques: &cliques)
                
                nextP = nextP.subtracting(v)
                nextX = nextX.union(v)
                
            }
        }
    }
    
    var network: Network {
        var network = Network()
        
        for line in data.split(separator: "\n") {
            let computers = line.split(separator: "-").map { String($0) }
            
            network.nodes.insert(computers[0])
            network.nodes.insert(computers[1])
            
            network.edges[computers[0], default: []].insert(computers[1])
            network.edges[computers[1], default: []].insert(computers[0])
        }
        
        return network
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let interconnected = network.interconnected
        let filtered = interconnected.filter { $0.contains(where: { $0.hasPrefix("t") } ) }
        
        return filtered.count
    }
    
    public func part2() async throws -> Any {
        let maxClique = network.maximalClique
        
        return maxClique.map { String($0) }.joined(separator: ",")
    }
}
