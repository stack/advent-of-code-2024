//
//  Day2.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-02.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day2: AdventDay {
    
    struct Report {
        var levels: [Int]
        
        var isSafe: Bool {
            let diffs = levels.indices.dropFirst().map { levels[$0] - levels[$0 - 1] }
            
            let allDecrease = diffs.allSatisfy { $0 <= 0 }
            let allIncrease = diffs.allSatisfy { $0 >= 0 }
            
            guard allDecrease || allIncrease else { return false }
            
            let allDiffer = diffs.allSatisfy { abs($0) > 0 && abs($0) <= 3 }
            
            return allDiffer
        }
        
        var isSafeDampened: Bool {
            guard !isSafe else { return true }
            
            for index in levels.indices {
                var nextLevels = levels
                nextLevels.remove(at: index)
                
                let nextReport = Report(levels: nextLevels)
                
                if nextReport.isSafe { return true }
            }
            
            return false
        }
    }
    
    public var data: String
    
    var reports: [Report] {
        data
            .split(separator: "\n")
            .map { $0.split(separator: " ") }
            .map { $0.compactMap { Int($0) } }
            .map { Report(levels: $0) }
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
            for report in reports {
                taskGroup.addTask {
                    report.isSafe ? 1 : 0
                }
            }
            
            return await taskGroup.reduce(0, +)
        }
    }
    
    public func part2() async throws -> Any {
        await withTaskGroup(of: Int.self, returning: Int.self) { taskGroup in
            for report in reports {
                taskGroup.addTask {
                    report.isSafeDampened ? 1 : 0
                }
            }
            
            return await taskGroup.reduce(0, +)
        }
    }
}
