//
//  Day4.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-04.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day4: AdventDay {
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        let wordSearch = data
            .split(separator: "\n")
            .map { $0.map { String($0) } }
        
        var count = 0
        
        for (y, row) in wordSearch.enumerated() {
            for (x, letter) in row.enumerated() {
                guard letter == "X" else { continue }
                
                let words = allWords(x: x, y: y, in: wordSearch)
                    .filter { $0 == "XMAS" }
                
                count += words.count
            }
        }
        
        return count
    }
    
    public func part2() async throws -> Any {
        let wordSearch = data
            .split(separator: "\n")
            .map { $0.map { String($0) } }
        
        var count = 0
        
        for (y, row) in wordSearch.enumerated() {
            for (x, letter) in row.enumerated() {
                guard letter == "A" else { continue }
                
                let east = eastward(x: x, y: y, in: wordSearch)
                
                guard east == "MAS" || east == "SAM" else { continue }
                
                let west = westward(x: x, y: y, in: wordSearch)
                
                guard west == "MAS" || west == "SAM" else { continue }
                
                count += 1
            }
        }
        
        return count
    }
    
    func allWords(x: Int, y: Int, in wordSearch: [[String]]) -> [String] {
        let vectors: [Point] = (-1...1).flatMap { x in
            (-1...1).compactMap { y in
                guard x != 0 || y != 0 else { return nil }
                
                return Point(x: x, y: y)
            }
        }
        
        let startPoint = Point(x: x, y: y)
        
        let runs = vectors.map { vector in
            (0...3).map { offset in
                startPoint + vector * offset
            }
        }
        
        let words = runs.map { word(at: $0, in: wordSearch) }
        
        return words
    }
    
    func eastward(x: Int, y: Int, in wordSearch: [[String]]) -> String {
        let midpoint = Point(x: x, y: y)
        
        let points = [
            midpoint + Point(x: -1, y: -1),
            midpoint,
            midpoint + Point(x: 1, y: 1)
        ]
        
        return word(at: points, in: wordSearch)
    }
    
    func westward(x: Int, y: Int, in wordSearch: [[String]]) -> String {
        let midpoint = Point(x: x, y: y)
        
        let points = [
            midpoint + Point(x: 1, y: -1),
            midpoint,
            midpoint + Point(x: -1, y: 1)
        ]
        
        return word(at: points, in: wordSearch)
    }

    func word(at points: [Point], in wordSearch: [[String]]) -> String {
        points
            .compactMap {
                guard $0.x >= 0, $0.x < wordSearch[0].count else { return nil }
                guard $0.y >= 0, $0.y < wordSearch.count else { return nil }
                
                return wordSearch[$0.y][$0.x]
            }
            .joined()
    }
}
