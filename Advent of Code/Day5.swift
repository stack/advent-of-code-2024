//
//  Day4.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-05.
//  SPDX-License-Identifier: MIT
//

import Foundation

typealias RuleSet = [Int:Set<Int>]

public struct Day5: AdventDay {
    
    public var data: String
    
    var rules: RuleSet {
        let ruleData = data.split(separator: "\n\n")[0]
        
        var rules: RuleSet = [:]
        
        for line in ruleData.split(separator: "\n") {
            let parts = line.split(separator: "|").map { Int($0)! }
            
            var set = rules[parts[0]] ?? []
            set.insert(parts[1])
            rules[parts[0]] = set
        }
        
        return rules
    }
    
    var updates: [[Int]] {
        let updateData = data.split(separator: "\n\n")[1]
        
        return updateData
            .split(separator: "\n")
            .map { line in
                line
                    .split(separator: ",")
                    .map { Int($0)! }
            }
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let rules = self.rules
        let updates = self.updates
        
        var total: Int = 0
        
        for update in updates {
            guard isOrdered(update: update, rules: rules) else { continue }
            
            total += update[update.count / 2]
        }
        
        return total
    }
    
    public func part2() async throws -> Any {
        let rules = self.rules
        let updates = self.updates.filter { !isOrdered(update: $0, rules: rules) }
        
        var total: Int = 0
        
        for var update in updates {
            while !isOrdered(update: update, rules: rules) {
                update = fixOrder(update: update, rules: rules)
            }
            
            total += update[update.count / 2]
        }
        
        return total
    }
    
    func fixOrder(update: [Int], rules: RuleSet) -> [Int] {
        for (index, value) in update.enumerated() {
            guard let set = rules[value] else { continue }
            
            for checkIndex in 0 ..< index {
                let checkValue = update[checkIndex]
                
                if set.contains(checkValue) {
                    var nextUpdate = update
                    nextUpdate.remove(at: checkIndex)
                    nextUpdate.append(checkValue)
                    
                    return nextUpdate
                }

            }
        }
        
        return update
    }
    
    func isOrdered(update: [Int], rules: RuleSet) -> Bool {
        for (index, value) in update.enumerated() {
            guard let set = rules[value] else { continue }
            
            for checkValue in update[0 ..< index] {
                if set.contains(checkValue) {
                    return false
                }
            }
        }
        
        return true
    }
}
