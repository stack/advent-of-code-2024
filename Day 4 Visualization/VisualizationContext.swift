//
//  VisualizationContext.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-04.
//  SPDX-License-Identifier: MIT
//

import AdventOfCode
import Foundation
import QuartzCore
import Visualization

class VisualizationContext: Solution2DContext {
    
    private var cachedBackground: CGImage? = nil
    
    override var name: String {
        "Day 4"
    }
    
    override func run() async throws {
        guard let bundle = Bundle(identifier: "us.gerstacker.advent-of-code.2024") else {
            fatalError("Failed to find bundle for 'us.gerstacker.advent-of-code.2024'.")
        }
        
        guard let dataURL = bundle.url(forResource: "Day04", withExtension: "txt") else {
            fatalError("Couldn't find file 'Day04.txt' in the 'Resources' directory.")
        }
        
        let data = try String(contentsOf: dataURL, encoding: .utf8)
        let wordSearch = data
            .split(separator: "\n")
            .map { $0.map { String($0) } }
        
        for (y, row) in wordSearch.enumerated() {
            for (x, letter) in row.enumerated() {
                let (context, pixelBuffer) = try nextContext()
                
                let cursor = Point(x: x, y: y)
                render(wordSearch: wordSearch, cursor: cursor, vector: nil, in: context)
                
                submit(context: context, pixelBuffer: pixelBuffer)
                
                guard letter == "X" else { continue }
                
                for vector in vectors(for: cursor) {
                    let (context, pixelBuffer) = try nextContext()
                    
                    render(wordSearch: wordSearch, cursor: cursor, vector: vector, in: context)
                    
                    submit(context: context, pixelBuffer: pixelBuffer)
                    
                    if word(at: vector, in: wordSearch) == "XMAS" {
                        highlightBackground(wordSearch: wordSearch, vector: vector)
                    }
                }
            }
        }
        
        let (context, pixelBuffer) = try nextContext()
        render(wordSearch: wordSearch, cursor: nil, vector: nil, in: context)
        submit(context: context, pixelBuffer: pixelBuffer)
    }
    
    private func vectors(for point: Point) -> [[Point]] {
        let vectors: [Point] = [
            Point(x: -1, y:  0),
            Point(x: -1, y: -1),
            Point(x:  0, y: -1),
            Point(x:  1, y: -1),
            Point(x:  1, y:  0),
            Point(x:  1, y:  1),
            Point(x:  0, y:  1),
            Point(x: -1, y:  1)
        ]
        
        return vectors.map { vector in
            (0...3).map { offset in
                point + vector * offset
            }
        }
    }
    
    private func word(at points: [Point], in wordSearch: [[String]]) -> String {
        points
            .compactMap {
                guard $0.x >= 0, $0.x < wordSearch[0].count else { return nil }
                guard $0.y >= 0, $0.y < wordSearch.count else { return nil }
                
                return wordSearch[$0.y][$0.x]
            }
            .joined()
    }

    private func highlightBackground(wordSearch: [[String]], vector: [Point]) {
        guard let cachedBackground else { return }
        
        let columns = wordSearch[0].count
        let rows = wordSearch.count
        
        let backgroundRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        let boxSize = CGSize(
            width: CGFloat(width) / CGFloat(columns),
            height: CGFloat(height) / CGFloat(rows)
        )
        
        let fontSize = min(boxSize.width, boxSize.height)
        let font = NativeFont.monospacedSystemFont(ofSize: fontSize * 0.5, weight: .regular)
        let white = NativeColor.white.cgColor
        let green = NativeColor.systemGreen.cgColor

        self.cachedBackground = offscreenImage { context in
            context.draw(cachedBackground, in: backgroundRect)
            
            for point in vector {
                guard point.x >= 0 && point.x < columns else { continue }
                guard point.y >= 0 && point.y < rows else { continue }
                
                let rect = CGRect(
                    origin: CGPoint(x: CGFloat(point.x) * boxSize.width, y: CGFloat(point.y) * boxSize.height),
                    size: boxSize
                )
                
                fill(rect: rect, color: green, in: context)
                
                let letter = wordSearch[point.y][point.x]
                draw(text: letter, color: white, font: font, rect: rect, in: context)
            }
        }
    }
    
    private func render(wordSearch: [[String]], cursor: Point?, vector: [Point]?, in context: CGContext) {
        let columns = wordSearch[0].count
        let rows = wordSearch.count
        
        let boxSize = CGSize(
            width: CGFloat(width) / CGFloat(columns),
            height: CGFloat(height) / CGFloat(rows)
        )
        
        let fontSize = min(boxSize.width, boxSize.height)
        let font = NativeFont.monospacedSystemFont(ofSize: fontSize * 0.5, weight: .regular)
        
        let white = NativeColor.white.cgColor
        let black = NativeColor.black.cgColor
        let orange = NativeColor.systemOrange.cgColor
        let red = NativeColor.systemRed.cgColor
        
        let backgroundRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        if cachedBackground == nil {
            cachedBackground = offscreenImage { context in
                fill(rect: backgroundRect, color: white, in: context)
                
                for (y, row) in wordSearch.enumerated() {
                    for (x, letter) in row.enumerated() {
                        let cellRect = CGRect(
                            origin: CGPoint(x: CGFloat(x) * boxSize.width, y: CGFloat(y) * boxSize.height),
                            size: boxSize
                        )
                        
                        draw(text: letter, color: black, font: font, rect: cellRect, in: context)
                    }
                }
            }
        }
        
        if let cachedBackground {
            context.draw(cachedBackground, in: backgroundRect)
        }

        if let vector {
            for point in vector {
                guard point.x >= 0 && point.x < columns else { continue }
                guard point.y >= 0 && point.y < rows else { continue }
                
                let rect = CGRect(
                    origin: CGPoint(x: CGFloat(point.x) * boxSize.width, y: CGFloat(point.y) * boxSize.height),
                    size: boxSize
                )
                
                fill(rect: rect, color: orange, in: context)
                
                let letter = wordSearch[point.y][point.x]
                draw(text: letter, color: black, font: font, rect: rect, in: context)
            }
        }
        
        if let cursor {
            let rect = CGRect(
                origin: CGPoint(x: CGFloat(cursor.x) * boxSize.width, y: CGFloat(cursor.y) * boxSize.height),
                size: boxSize
            )
            
            fill(rect: rect, color: red, in: context)
            
            let letter = wordSearch[cursor.y][cursor.x]
            draw(text: letter, color: white, font: font, rect: rect, in: context)
        }
        
    }
}
