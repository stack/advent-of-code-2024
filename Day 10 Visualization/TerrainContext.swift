//
//  TerrainContext.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-10.
//  SPDX-License-Identifier: MIT
//

import AdventOfCode
import Foundation
import Visualization
import simd

class TerrainContext: Solution3DContext {
    
    private let slabHeight: Float = 0.2
    private let boxFactor: Float = 9.0
    
    private let pointLightHeight: Float = 25.0
    private let pointLightIntensity: Float = 500.0
    private let cameraHeight: Float = 50.0
    
    private var left: Float = 0.0
    private var back: Float = 0.0
    
    override var name: String {
        "Day 10"
    }
    
    override func run() async throws {
        guard let bundle = Bundle(identifier: "us.gerstacker.advent-of-code.2024") else {
            fatalError("Failed to find bundle for 'us.gerstacker.advent-of-code.2024'.")
        }
        
        guard let dataURL = bundle.url(forResource: "Day10", withExtension: "txt") else {
            fatalError("Couldn't find file 'Day10.txt' in the 'Resources' directory.")
        }
        
        let data = try String(contentsOf: dataURL, encoding: .utf8)
        
        let trail = Day10.Trail(data: data)
        
        for index in (0 ..< 10) {
            let height = 1.0 + (Float(index) / 25.0) * boxFactor
            try loadBoxMesh(name: "Box \(index)", extents: SIMD3<Float>(1.0, height, 1.0), baseColor: SIMD4<Float>(143.0 / 255.0, 134.0 / 255.0, 126.0 / 255.0, 1.0), roughnessFactor: 0.9)
        }
        
        try loadBoxMesh(name: "Green Slab", extents: SIMD3<Float>(1.0, 0.2, 1.0), baseColor: NativeColor.systemGreen.simd, metallicFactor: 0.2, roughnessFactor: 0.2)
        
        try loadBoxMesh(name: "Red Slab", extents: SIMD3<Float>(1.0, 0.2, 1.0), baseColor: NativeColor.systemRed.simd, metallicFactor: 0.2, roughnessFactor: 0.2)
        try loadBoxMesh(name: "Orange Slab", extents: SIMD3<Float>(1.0, 0.2, 1.0), baseColor: NativeColor.systemOrange.simd, metallicFactor: 0.2, roughnessFactor: 0.2)
        try loadBoxMesh(name: "Yellow Slab", extents: SIMD3<Float>(1.0, 0.2, 1.0), baseColor: NativeColor.systemYellow.simd, metallicFactor: 0.2, roughnessFactor: 0.2)
        try loadBoxMesh(name: "Blue Slab", extents: SIMD3<Float>(1.0, 0.2, 1.0), baseColor: NativeColor.systemBlue.simd, metallicFactor: 0.2, roughnessFactor: 0.2)
        try loadBoxMesh(name: "Purple Slab", extents: SIMD3<Float>(1.0, 0.2, 1.0), baseColor: NativeColor.systemPurple.simd, metallicFactor: 0.2, roughnessFactor: 0.2)
        
        let slabNames = [
            "Red Slab",
            "Orange Slab",
            "Yellow Slab",
            "Blue Slab",
            "Purple Slab"
        ]
        
        try loadMesh(name: "Flag", fromResource: "Flag")
        try loadMesh(name: "Flag Green", fromResource: "Flag Green")

        let size = trail.size
        left = (Float(size.width) / -2.0) + 0.5
        back = (Float(size.height) / -2.0) + 0.5
        
        for (point, value) in trail.tiles {
            let nodeName = "Tile \(point.x), \(point.y)"
            addNode(name: nodeName, mesh: "Box \(value)", batch: "Boxes \(value)")
            
            let height = 1.0 + (Float(value) / 25.0) * boxFactor
            let translation = simd_float4x4(translate: SIMD3<Float>(left + Float(point.x), height / 2.0, back + Float(point.y)))
                            
            updateNode(name: nodeName, transform: translation)
        }
        
        for point in trail.ends {
            let nodeName = "Flag \(point.x), \(point.y)"
            addNode(name: nodeName, mesh: "Flag", batch: "Flags")
            
            let height = 1.0 + (9.0 / 25.0) * boxFactor
            let scale = unitScale(forMesh: "Flag") * simd_float4x4(scale: SIMD3<Float>(2, 2, 2))
            let rotation = simd_float4x4(rotateAbout: SIMD3<Float>(1, 0, 0), byAngle: .pi / 2)
            let translation = simd_float4x4(translate: SIMD3<Float>(left + Float(point.x), height, back + Float(point.y)))
            
            updateNode(name: nodeName, transform: translation * rotation * scale)
        }
        
        for point in trail.heads {
            let nodeName = "Start \(point.x), \(point.y)"
            addNode(name: nodeName, mesh: "Green Slab")
            
            let translation = slabTranslation(for: point, value: 0)
            updateNode(name: nodeName, transform: translation)
        }
        
        let cameraPosition = SIMD3<Float>(left * -1 + 25, cameraHeight, back * -1 + 25)
        updateCamera(eye: cameraPosition, lookAt: .zero, up: SIMD3<Float>(0, 1, 0))
        updatePerspective(near: 0.01, far: 200, angle: .pi / 4)
        
        addDirectLight(name: "Sun", lookAt: .zero, from: cameraPosition, up: SIMD3<Float>(0, 1, 0), intensity: 4)
        
        addPointLight(name: "Point 1", color: SIMD3<Float>(1.0, 1.0, 0.8), intensity: 500)
        updateLight(name: "Point 1", transform: simd_float4x4(translate: SIMD3<Float>(left * -1.0 + 1, cameraHeight / 2, 0)))

        for (index, point) in trail.heads.enumerated() {
            let meshName = slabNames[index % slabNames.count]
            
            trail.hikeBetter(from: point) { [weak self] point, value in
                guard let self else { return }
                guard value != 0 else { return }
                
                if value == 9 {
                    let nodeName = "Flag \(point.x), \(point.y)"
                    removeNode(name: nodeName)
                    addNode(name: nodeName, mesh: "Flag Green", batch: "Green Flags")
                    
                    let height = 1.0 + (9.0 / 25.0) * boxFactor
                    let scale = unitScale(forMesh: "Flag Green") * simd_float4x4(scale: SIMD3<Float>(2, 2, 2))
                    let rotation = simd_float4x4(rotateAbout: SIMD3<Float>(1, 0, 0), byAngle: .pi / 2)
                    let translation = simd_float4x4(translate: SIMD3<Float>(left + Float(point.x), height, back + Float(point.y)))
                    
                    updateNode(name: nodeName, transform: translation * rotation * scale)
                }
                
                let nodeName = "Visit \(point.x), \(point.y)"
                removeNode(name: nodeName)
                addNode(name: nodeName, mesh: meshName)
                
                let translation = slabTranslation(for: point, value: value)
                updateNode(name: nodeName, transform: translation)
                
                try? snapshot()
            }
        }
    }
    
    private func slabTranslation(for point: Point, value: Int) -> simd_float4x4 {
        let baseHeight: Float = 1.0
        let extensionHeight = (Float(value) / 25.0) * boxFactor
        
        let y = baseHeight + extensionHeight + (slabHeight / 2)
        
        return simd_float4x4(translate: SIMD3<Float>(left + Float(point.x), y, back + Float(point.y)))
    }
}
