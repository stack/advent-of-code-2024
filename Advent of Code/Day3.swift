//
//  Day3.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-02.
//  SPDX-License-Identifier: MIT
//

import Foundation
import RegexBuilder

public struct Day3: AdventDay {
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        multiply(data)
    }
    
    public func part2() async throws -> Any {
        var working = data
        var index = working.startIndex
        var toRemove: [Range<String.Index>] = []
        
        while index < working.endIndex {
            guard let dontRange = working[index...].firstRange(of: "don't()") else { break }
            
            let nextIndex = working.index(after: dontRange.upperBound)
            
            if let doRange = working[nextIndex...].firstRange(of: "do()") {
                let replaceRange = dontRange.lowerBound ..< doRange.upperBound
                
                toRemove.append(replaceRange)
                index = working.index(after: replaceRange.upperBound)
            } else {
                toRemove.append(dontRange.lowerBound..<working.endIndex)
                index = working.endIndex
            }
        }
        
        for range in toRemove.reversed() {
            working.removeSubrange(range)
        }
        
        return multiply(working)
    }
    
    private func multiply(_ data: String) -> Int {
        let pattern = /mul\((\d{1,3}),(\d{1,3})\)/
        
        return data
            .matches(of: pattern)
            .map {
                guard let lhs = Int($0.output.1), let rhs = Int($0.output.2) else {
                    fatalError("Failed to parse numbers in \($0.output)")
                }
                
                return lhs * rhs
            }
            .reduce(0, +)
    }
}
