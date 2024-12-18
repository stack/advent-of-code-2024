//
//  Day17.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-18.
//  SPDX-License-Identifier: MIT
//

import Foundation

public struct Day17: AdventDay {
    
    enum Opcode {
        case adv(Int)
        case bxl(Int)
        case bst(Int)
        case jnz(Int)
        case bxc(Int)
        case out(Int)
        case bdv(Int)
        case cdv(Int)
    }
    
    struct Program {
        var registerA: Int = 0
        var registerB: Int = 0
        var registerC: Int = 0
        var instructionPointer: Int = 0
        
        var instructions: [Opcode] = []
        var input: [Int] = []
        var output: [Int] = []
        
        mutating func execute() {
            while instructionPointer < instructions.count {
                let instruction = instructions[instructionPointer]
                
                switch instruction {
                case .adv(let combo):
                    let numer = registerA
                    let denom = 2 ^^ comboValue(combo)
                    
                    registerA = numer / denom
                    
                    instructionPointer += 1
                case .bxl(let value):
                    registerB = registerB ^ value
                    instructionPointer += 1
                case .bst(let combo):
                    registerB = comboValue(combo) % 8
                    instructionPointer += 1
                case .jnz(let value):
                    if registerA == 0 {
                        instructionPointer += 1
                    } else {
                        instructionPointer = value / 2
                    }
                case .bxc(_):
                    registerB = registerB ^ registerC
                    instructionPointer += 1
                case .out(let combo):
                    let value = comboValue(combo) % 8
                    output.append(value)
                   
                    instructionPointer += 1
                case .bdv(let combo):
                    let numer = registerA
                    let denom = 2 ^^ comboValue(combo)
                    
                    registerB = numer / denom
                    
                    instructionPointer += 1
                case .cdv(let combo):
                    let numer = registerA
                    let denom = 2 ^^ comboValue(combo)
                    
                    registerC = numer / denom
                    
                    instructionPointer += 1
                }
            }
        }
        
        private func comboValue(_ value: Int) -> Int {
            switch value {
            case 0, 1, 2, 3: value
            case 4: registerA
            case 5: registerB
            case 6: registerC
            case 7: fatalError("Reserved combo value")
            default: fatalError("Invalid combo value \(value)")
            }
        }
    }
    
    var program: Program {
        var program = Program()
        
        for line in data.split(separator: "\n") {
            let parts = line.split(separator: ": ")
            
            guard parts.count == 2 else { continue }
            
            if parts[0] == "Register A" {
                program.registerA = Int(parts[1])!
            } else if parts[0] == "Register B" {
                program.registerB = Int(parts[1])!
            } else if parts[0] == "Register C" {
                program.registerC = Int(parts[1])!
            } else if parts[0] == "Program" {
                program.input = parts[1].split(separator: ",").map { Int($0)! }
                
                program.instructions = program.input.chunks(ofCount: 2).map {
                    let opcode = $0.first!
                    let value = $0.dropFirst().first!
                    
                    return switch opcode {
                    case 0: .adv(value)
                    case 1: .bxl(value)
                    case 2: .bst(value)
                    case 3: .jnz(value)
                    case 4: .bxc(value)
                    case 5: .out(value)
                    case 6: .bdv(value)
                    case 7: .cdv(value)
                    default: fatalError("Invalid opcode \($0[0])")
                    }
                }
            }
        }
        return program
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var program = program
        program.execute()
        
        return program.output.map { String($0) }.joined(separator: ",")
    }
    
    public func part2() async throws -> Any {
        let program = program
        var a = 0
        
        var lowerBound = 0
        mainLoop: for index in (0 ..< program.input.count).reversed() {
            a = lowerBound
            
            while true {
                var currentProgram = program
                currentProgram.registerA = a
                
                currentProgram.execute()
                
                if currentProgram.output == Array(program.input[index...]) {
                    guard currentProgram.output != program.input else {
                        break mainLoop
                    }
                    
                    let aBase8 = String(a, radix: 8) + "0"
                    lowerBound = Int(aBase8, radix: 8)!
                    
                    break
                }
                
                a += 1
            }
        }
        
        return a
    }
}
