//
//  Day13.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-13.
//  SPDX-License-Identifier: MIT
//

import Accelerate
import Foundation

public struct Day13: AdventDay {
    
    struct Machine {
        var offsetA: Point
        var offsetB: Point
        var prize: Point
        
        func solve() -> Int? {
            let aValues: [Double] = [ Double(offsetA.x), Double(offsetA.y), Double(offsetB.x), Double(offsetB.y) ]
            let dimension = 2
            
            let bValues: [Double] = [ Double(prize.x), Double(prize.y) ]
            
            guard let results = nonsymmetric_general(a: aValues, dimension: dimension, b: bValues, rightHandSideCount: 1) else { return nil }
            
            let aPressed = Int(results[0].rounded())
            let bPressed = Int(results[1].rounded())
            
            let position = offsetA * aPressed + offsetB * bPressed
            
            if position == prize {
                return (aPressed * 3) + bPressed
            } else {
                return nil
            }
        }
    }
    
    let buttonRegex = /^Button [AB]: X\+(\d+), Y\+(\d+)$/
    let prizeRegex = /^Prize: X=(\d+), Y=(\d+)$/
    
    var machines: [Machine] {
        data
            .split(separator: "\n\n")
            .map { $0.split(separator: "\n") }
            .map {
                let aMatch = $0[0].firstMatch(of: buttonRegex)!
                let bMatch = $0[1].firstMatch(of: buttonRegex)!
                let prizeMatch = $0[2].firstMatch(of: prizeRegex)!
                
                return Machine(
                    offsetA: Point(x: Int(aMatch.output.1)!, y: Int(aMatch.output.2)!),
                    offsetB: Point(x: Int(bMatch.output.1)!, y: Int(bMatch.output.2)!),
                    prize: Point(x: Int(prizeMatch.output.1)!, y: Int(prizeMatch.output.2)!)
                )
            }
    }
    
    public var data: String
    
    public init(data: String) {
        self.data = data
    }
    
    public func part1() async throws -> Any {
        var total = 0
        
        for machine in machines {
            guard let cost = machine.solve() else { continue }
            
            total += cost
        }
            
        return total
    }
    
    public func part2() async throws -> Any {
        let machines = machines.map {
            Machine(offsetA: $0.offsetA, offsetB: $0.offsetB, prize: $0.prize + 10000000000000)
        }
        
        var total = 0
        
        for machine in machines {
            guard let cost = machine.solve() else { continue }
            
            total += cost
        }
            
        return total
    }
}

/// Returns the _x_ in _Ax = b_ for a nonsquare coefficient matrix using `sgesv_`.
///
/// - Parameter a: The matrix _A_ in _Ax = b_ that contains `dimension * dimension`
/// elements.
/// - Parameter dimension: The order of matrix _A_.
/// - Parameter b: The matrix _b_ in _Ax = b_ that contains `dimension * rightHandSideCount`
/// elements.
/// - Parameter rightHandSideCount: The number of columns in _b_.
///
/// The function specifies the leading dimension (the increment between successive columns of a matrix)
/// of matrices as their number of rows.

/// - Tag: nonsymmetric_general
func nonsymmetric_general(a: [Double], dimension: Int, b: [Double], rightHandSideCount: Int) -> [Double]? {
    
    var info: __LAPACK_int = 0
    
    /// Create a mutable copy of the right hand side matrix _b_ that the function returns as the solution matrix _x_.
    var x = b
    
    /// Create a mutable copy of `a` to pass to the LAPACK routine. The routine overwrites `mutableA`
    /// with the factors `L` and `U` from the factorization `A = P * L * U`.
    var mutableA = a
    
    var ipiv = [__LAPACK_int](repeating: 0, count: dimension)
    
    /// Call `sgesv_` to compute the solution.
    withUnsafePointer(to: __LAPACK_int(dimension)) { n in
        withUnsafePointer(to: __LAPACK_int(rightHandSideCount)) { nrhs in
            dgesv_(n,
                   nrhs,
                   &mutableA,
                   n,
                   &ipiv,
                   &x,
                   n,
                   &info)
        }
    }
    
    if info != 0 {
        NSLog("nonsymmetric_general error \(info)")
        return nil
    }
    
    return x
}
