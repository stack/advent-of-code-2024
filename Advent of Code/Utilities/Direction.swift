//
//  Direction.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2023-12-17.
//  SPDX-License-Identifier: MIT
//

import Foundation

public enum Direction: CaseIterable, Hashable, CustomDebugStringConvertible, Sendable {
    case north
    case south
    case east
    case west
    
    public var debugDescription: String {
        switch self {
        case .north: "^"
        case .south: "v"
        case .east: ">"
        case .west: "<"
        }
    }
    
    public var turnedLeft: Direction {
        switch self {
        case .north: .west
        case .south: .east
        case .east: .north
        case .west: .south
        }
    }
    
    public var turnedRight: Direction {
        switch self {
        case .north: .east
        case .south: .west
        case .east: .south
        case .west: .north
        }
    }
    
    public var reversed: Direction {
        switch self {
        case .north: .south
        case .south: .north
        case .east: .west
        case .west: .east
        }
    }
    
    public var offset: Point {
        switch self {
        case .north: Point(x: 0, y: -1)
        case .south: Point(x: 0, y: 1)
        case .east: Point(x: 1, y: 0)
        case .west: Point(x: -1, y: 0)
        }
    }
}
