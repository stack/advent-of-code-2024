//
//  Day1.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-01.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day1: AdventDay {
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    var lists: ([Int], [Int]) {
        let lines = data.split(separator: "\n")
        
        let lineDigits = lines.flatMap {
            let parts = $0.split(separator: " ", omittingEmptySubsequences: true)
            
            return parts.compactMap { Int($0) }
        }
        
        let lhs = stride(from: 0, to: lineDigits.count, by: 2).map { lineDigits[$0] }
        let rhs = stride(from: 1, to: lineDigits.count, by: 2).map { lineDigits[$0] }

        return (lhs, rhs)
    }
    
    public func part1() async throws -> Any {
        var (lhs, rhs) = lists
        
        lhs.sort()
        rhs.sort()
        
        let distances = zip(lhs, rhs).map { abs($0.0 - $0.1) }
        let totalDistance = distances.reduce(0, +)
        
        return totalDistance
    }
    
    public func part2() async throws -> Any {
        let (lhs, rhs) = lists
        
        let frequencies = rhs.reduce(into: [Int:Int]()) {
            $0[$1] = $0[$1, default: 0] + 1
        }
        
        let similarity = lhs.reduce(0) {
            $0 + ($1 * frequencies[$1, default: 0])
        }
        
        return similarity
    }
}

