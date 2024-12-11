//
//  NativeTypes.swift
//  Advent of Code 2024 Visualization
//
//  Created by Stephen H. Gerstacker on 2024-12-10.
//  SPDX-License-Identifier: MIT
//


#if os(macOS)
import AppKit

public typealias NativeColor = NSColor
public typealias NativeFont = NSFont

#else
import UIKit

public typealias NativeColor = UIColor
public typealias NativeFont = UIFont

#endif

import simd

extension NativeColor {
    
    public var simd: SIMD4<Float> {
        let color = cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        let components = color?.components
        
        return SIMD4<Float>(
            Float(components?[0] ?? 0.0),
            Float(components?[1] ?? 0.0),
            Float(components?[2] ?? 0.0),
            Float(components?[3] ?? 0.0)
        )
    }
}
