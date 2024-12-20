//
//  Point.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Point: Hashable, Sendable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }

    public var cardinalNeighbors: [Point] {
        var neighbors: [Point] = []

        neighbors.append(left)
        neighbors.append(right)
        neighbors.append(up)
        neighbors.append(down)

        return neighbors
    }
    
    public static var cardinalVectors: [Point] {
        [
            Point(x: -1, y:  0),
            Point(x:  1, y:  0),
            Point(x:  0, y: -1),
            Point(x:  0, y:  1)
        ]
    }
    
    public var allNeighbors: [Point] {
        var neighbors: [Point] = []
        
        for yOffset in -1...1 {
            for xOffset in -1...1 {
                if xOffset == 0 && yOffset == 0 { continue }
                
                neighbors.append(Point(x: x + xOffset, y: y + yOffset))
            }
        }
        
        return neighbors
    }
    
    public static func allValues(width: Int, height: Int) -> PointGenerator {
        PointGenerator(width: width, height: height)
    }

    public static var zero: Point {
        return Point(x: 0, y: 0)
    }
    
    public var up: Point {
        return Point(x: x, y: y - 1)
    }
    
    public var down: Point {
        return Point(x: x, y: y + 1)
    }
    
    public var left: Point {
        return Point(x: x - 1, y: y)
    }
    
    public var right: Point {
        return Point(x: x + 1, y: y)
    }
    
    public func manhattenDistance(to other: Point) -> Int {
        return abs(x - other.x) + abs(y - other.y)
    }
    
    public static func +(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    public static func +(lhs: Point, rhs: Int) -> Point {
        return Point(x: lhs.x + rhs, y: lhs.y + rhs)
    }
    
    public static func -(lhs: Point, rhs: Point) -> Point {
        return Point(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    public static func *(lhs: Point, rhs: Int) -> Point {
        return Point(x: lhs.x * rhs, y: lhs.y * rhs)
    }
}

extension Point: Comparable {
    public static func < (lhs: Point, rhs: Point) -> Bool {
        if lhs.x < rhs.x {
            return true
        } else if lhs.x > rhs.x {
            return false
        } else {
            return lhs.y < rhs.y
        }
    }
}

extension Point: CustomDebugStringConvertible {
    public var debugDescription: String {
        "(\(x),\(y))"
    }
}

extension Point: CustomStringConvertible {
    public var description: String {
        "(\(x),\(y))"
    }
}

public struct PointGenerator: Sequence, IteratorProtocol {
    
    var current: Point? = .zero
    var width: Int
    var height: Int
    
    public mutating func next() -> Point? {
        guard let returnValue = current else { return nil }
        
        var nextValue = returnValue
        nextValue.x += 1
        
        if nextValue.x >= width {
            nextValue.x = 0
            nextValue.y += 1
        }
        
        if nextValue.y >= height {
            current = nil
        } else {
            current = nextValue
        }
        
        return returnValue
    }
    
}
