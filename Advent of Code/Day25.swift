//
//  Day25.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-25.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day25: AdventDay {
    
    public var data: String
    
    var locksAndKeys: ([[Int]], [[Int]]) {
        var locks: [[Int]] = []
        var keys: [[Int]] = []
        
        for blob in data.split(separator: "\n\n") {
            let lines = blob.split(separator: "\n")
            let width = lines.first!.count
            let isLock = lines.first!.hasPrefix("#")
            
            var total = [Int](repeating: -1, count: width)
            
            for line in lines {
                for (index, character) in line.enumerated() {
                    total[index] += character == "#" ? 1 : 0
                }
            }
            
            if isLock {
                locks.append(total)
            } else {
                keys.append(total)
            }
        }
        
        return (locks, keys)
    }
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let (locks, keys) = locksAndKeys
        
        var total = 0
        
        for lock in locks {
            for key in keys {
                if !overlaps(lock: lock, key: key) {
                    total += 1
                }
            }
        }
        
        return total
    }
    
    func overlaps(lock: [Int], key: [Int], maxHeight: Int = 7) -> Bool {
        print("Lock \(lock) and key \(key): ", terminator: "")
        for (lockValue, keyValue) in zip(lock, key) {
            if lockValue + keyValue >= (maxHeight - 1) {
                print("overlap")
                return true
            }
        }
        
        print("all columns fit!")
        return false
    }
}
