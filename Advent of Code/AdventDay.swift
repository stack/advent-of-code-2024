//
//  AdventDay.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2023-12-01.
//  SPDX-License-Identifier: MIT
//

import Foundation

public protocol AdventDay {
    /// The day of the Advent of Code challenge.
    ///
    /// You can implement this property, or , if your type is named with the
    /// day number as its suffix (like `Day01`), it is derived automatically.
    static var day: Int { get }
    
    var data: String { get set }
    
    /// An initializer that uses the provided test data for both parts
    init(data: String)
    
    /// Computes and returns the answer for part 1.
    func part1() async throws -> Any
    
    /// Computes and returns the answer for part 2.
    func part2() async throws -> Any
}

extension AdventDay {
    
    // Find the challenge day from the type name.
    public static var day: Int {
        let typeName = String(reflecting: Self.self)
        
        guard let i = typeName.lastIndex(where: { !$0.isNumber }), let day = Int(typeName[i...].dropFirst()) else {
            fatalError(
                """
                Day number not found in type name: \
                implement the static `day` property \
                or use the day number as your type's suffix (like `Day3`).")
                """
            )
        }
    
        return day
    }

    public var day: Int {
        Self.day
    }

    // Default implementation of `part2`, so there aren't interruptions before
    // working on `part1()`.
    public func part2() -> Any {
        "Not implemented yet"
    }

    /// Prepare the challenge to run
    public mutating func prepare(useSample: Bool) throws {
        let dayString = String(format: "%02d", Self.day)
        let dataName = useSample ? "Sample" : "Day"
        let dataFilename = "\(dataName)\(dayString)"

        guard let bundle = Bundle(identifier: "us.gerstacker.advent-of-code.2024") else {
            fatalError("Failed to find bundle for 'us.gerstacker.advent-of-code.2024'.")
        }
        
        guard let dataURL = bundle.url(forResource: dataFilename, withExtension: "txt") else {
            fatalError("Couldn't find file '\(dataFilename).txt' in the 'Resources' directory.")
        }
        
        let data = try String(contentsOf: dataURL, encoding: .utf8)

        // On Windows, line separators may be CRLF. Converting to LF so that \n
        // works for string parsing.
        self.data = data.replacingOccurrences(of: "\r", with: "")
    }
    
    /// Default initializer
    public init() {
        self.init(data: "")
    }
}
