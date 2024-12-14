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
        "Day 14"
    }
    
    override func run() async throws {
        guard let bundle = Bundle(identifier: "us.gerstacker.advent-of-code.2024") else {
            fatalError("Failed to find bundle for 'us.gerstacker.advent-of-code.2024'.")
        }
        
        guard let dataURL = bundle.url(forResource: "Day14", withExtension: "txt") else {
            fatalError("Couldn't find file 'Day14.txt' in the 'Resources' directory.")
        }
        
        let data = try String(contentsOf: dataURL, encoding: .utf8)
        
        let regex = /^p=(\d+),(\d+) v=(-?\d+),(-?\d+)/
        var floor = Day14.Floor(width: 0, height: 0, robots: [])
        
        for line in data.split(separator: "\n") {
            let match = line.firstMatch(of: regex)!
            
            let pX = Int(match.output.1)!
            let pY = Int(match.output.2)!
            let vX = Int(match.output.3)!
            let vY = Int(match.output.4)!
            
            floor.width = max(floor.width, pX + 1)
            floor.height = max(floor.height, pY + 1)
            
            floor.robots.append(Day14.Robot(position: Point(x: pX, y: pY), velocity: Point(x: vX, y: vY)))
        }
        
        let backgroundRect = CGRect(x: 0, y: 0, width: width, height: height)
        let textRect = CGRect(x: 0, y: height - 20, width: width, height: 20)
        
        let green = NativeColor.systemGreen.cgColor
        let white = NativeColor.white.cgColor
        let black = NativeColor.black.cgColor
        
        let font = NativeFont.monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        
        for time in (0 ..< 7862) {
            let (context, pixelBuffer) = try nextContext()
            
            fill(rect: backgroundRect, color: black, in: context)
            
            for robot in floor.robots {
                let rect = CGRect(x: robot.position.x * 20, y: robot.position.y * 20, width: 20, height: 20)
                fill(rect: rect, color: green, in: context)
            }
            
            draw(text: "\(time)", color: white, font: font, rect: textRect, in: context)
            
            submit(context: context, pixelBuffer: pixelBuffer)
            
            floor = floor.run(times: 1)
        }
        
        for _ in (0 ..< 3600) {
            repeatLastFrame()
        }
    }
}
