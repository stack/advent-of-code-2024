//
//  Day19.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-19.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day19: AdventDay {
    
    struct TowelRack {
        var patterns: Set<String>
        var designs: [String]
        
        func totalMakeable() -> Int {
            designs.filter { doesMatch(design: $0) }.count
        }
        
        private func doesMatch(design: String) -> Bool {
            var cache = [Int](repeating: 0, count: design.count + 1)
            cache[0] = 1
            
            for index in 0 ..< design.count {
                let current = design.suffix(design.count - index)
                
                for pattern in patterns {
                    if current.starts(with: pattern) {
                        cache[index + pattern.count] += cache[index]
                    }
                    
                    if cache[design.count] != 0 {
                        return true
                    }
                }
            }
            
            return false
        }
        
        func allCombinations() -> Int {
            designs.map { totalMatches(design: $0) }.reduce(0, +)
        }
        
        private func totalMatches(design: String) -> Int {
            var cache = [Int](repeating: 0, count: design.count + 1)
            cache[0] = 1
            
            for index in 0 ..< design.count {
                let current = design.suffix(design.count - index)
                
                for pattern in patterns {
                    if current.starts(with: pattern) {
                        cache[index + pattern.count] += cache[index]
                    }
                }
            }
            
            return cache[design.count]
        }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    var towelRack: TowelRack {
        let blobs = data.split(separator: "\n\n")
        
        let patterns = blobs[0] .split(separator: ", ") .map { String($0) }
        let designs = blobs[1].split(separator: "\n").map { String($0) }
        
        return TowelRack(patterns: Set(patterns), designs: designs)
    }
    
    public func part1() async throws -> Any {
        towelRack.totalMakeable()
    }
    
    public func part2() async throws -> Any {
        towelRack.allCombinations()
    }
}
