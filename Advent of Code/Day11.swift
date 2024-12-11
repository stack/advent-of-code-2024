//
//  Day11.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-11.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day11: AdventDay {
    
    struct CacheKey: Hashable {
        var value: Int
        var depth: Int
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let times = 25
        let initial = data.split(separator: " ").map { Int($0)! }
        
        var cache: [CacheKey:Int] = [:]
        
        return initial
            .map { visit2(value: $0, depth: 0, max: times, cache: &cache) }
            .reduce(0, +) + initial.count
    }
    
    public func part2() async throws -> Any {
        let times = 75
        let initial = data.split(separator: " ").map { Int($0)! }
        
        var cache: [CacheKey:Int] = [:]
        
        return initial
            .map { visit2(value: $0, depth: 0, max: times, cache: &cache) }
            .reduce(0, +) + initial.count
    }
    
    func visit2(value: Int, depth: Int, max: Int, cache: inout [CacheKey:Int]) -> Int {
        guard depth < max else { return 0 }
        
        let cacheKey = CacheKey(value: value, depth: depth)
        
        if let result = cache[cacheKey] {
            return result
        }
        
        let nextValues: [Int]
        
        if value == 0 {
            nextValues = [1]
        } else {
            let stringValue = String(value)
            
            if stringValue.count % 2 == 0 {
                let lhs = stringValue.prefix(stringValue.count / 2)
                let rhsTrimmed = stringValue.suffix(stringValue.count / 2).trimmingPrefix(while: { $0 == "0" })
                let rhs = rhsTrimmed.isEmpty ? "0" : rhsTrimmed
                
                
                nextValues = [Int(lhs)!, Int(rhs)!]
            } else {
                nextValues = [value * 2024]
            }
        }
        
        var result = nextValues.count - 1
        
        for nextValue in nextValues {
            result += visit2(value: nextValue, depth: depth + 1, max: max, cache: &cache)
        }
        
        cache[cacheKey] = result
        
        return result
    }
    
    func visit(value: Int, depth: Int, max: Int, cache: inout [Int:[Int]]) -> Int {
        guard depth < max else { return 1 }
        
        if let cachedValues = cache[value] {
            return cachedValues
                .map { visit(value: $0, depth: depth + 1, max: max, cache: &cache) }
                .reduce(0, +)
        }
        
        let nextValues: [Int]
        
        if value == 0 {
            nextValues = [1]
        } else {
            let stringValue = String(value)
            
            if stringValue.count % 2 == 0 {
                let lhs = stringValue.prefix(stringValue.count / 2)
                let rhsTrimmed = stringValue.suffix(stringValue.count / 2).trimmingPrefix(while: { $0 == "0" })
                let rhs = rhsTrimmed.isEmpty ? "0" : rhsTrimmed
                
                
                nextValues = [Int(lhs)!, Int(rhs)!]
            } else {
                nextValues = [value * 2024]
            }
        }
        
        cache[value] = nextValues
        
        return nextValues
            .map { visit(value: $0, depth: depth + 1, max: max, cache: &cache) }
            .reduce(0, +)
    }
}
