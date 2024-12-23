//
//  Day22.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-22.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day22: AdventDay {
    
    struct SecretGenerator: Sequence {
        let seed: Int
        
        func makeIterator() -> SecretIterator {
            return SecretIterator(self)
        }
    }
    
    struct SecretIterator: IteratorProtocol {
        let generator: SecretGenerator
        var current: Int
        
        init(_ generator: SecretGenerator) {
            self.generator = generator
            current = generator.seed
        }
        
        mutating func next() -> Int? {
            var next = current
            
            let one = current * 64
            next ^= one
            next %= 16777216
            
            let two = next / 32
            next ^= two
            next %= 16777216
            
            let three = next * 2048
            next ^= three
            next %= 16777216
            
            current = next
            
            return current
        }
    }
    
    var seeds: [Int] {
        data.split(separator: "\n").map { Int($0)! }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var total = 0
        for seed in seeds {
            let generator = SecretGenerator(seed: seed)
            var iterator = generator.makeIterator()
            var latest = 0
            
            for _ in (0 ..< 2000) {
               latest = iterator.next()!
            }
            
            print("\(seed): \(latest)")
            total += latest
        }
        
        return total
    }
    
    struct Monkey {
        var seed: Int
        var sequence: [Int]
        var changes: [[Int]]
    }
    
    public func part2() async throws -> Any {
        let monkeys = seeds.map { seed in
            let generator = SecretGenerator(seed: seed)
            var iterator = generator.makeIterator()
            
            let sequence = [seed] + (0 ..< 2000).map { _ in iterator.next()! }
            let onesSequence = sequence.map { $0 % 10 }
            let changes = onesSequence.windows(ofCount: 5).map {
                $0.adjacentPairs().map { $1 - $0 }
            }
            
            return Monkey(seed: seed, sequence: sequence, changes: changes)
        }
        
        var allChanges: Set<[Int]> = []
        
        for monkey in monkeys {
            for change in monkey.changes {
                allChanges.insert(change)
            }
        }
        
        var best: [Int] = []
        var bestScore: Int = 0
        
        for change in allChanges {
            var total = 0
            
            for monkey in monkeys {
                guard let index = monkey.changes.firstIndex(where: { $0 == change }) else { continue }
                
                let value = monkey.sequence[index + 4] % 10
                total += value
            }
            
            if total > bestScore {
                print("\(best) -> \(total)")
                bestScore = total
                best = change
            }
        }
        
        return bestScore
    }
    
}
