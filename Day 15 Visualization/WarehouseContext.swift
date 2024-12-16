//
//  WarehouseContext.swift
//  Advent of Code 2024
//
//  Created by Stephen H. Gerstacker on 2024-12-15.
//  SPDX-License-Identifier: MIT
//

import AdventOfCode
import Foundation
import Visualization
import simd

class WarehouseContext: Solution3DContext {
    
    override var name: String { "Day 15" }
    
    var offset: SIMD3<Float> = .zero
    
    override func run() async throws {
        guard let bundle = Bundle(identifier: "us.gerstacker.advent-of-code.2024") else {
            fatalError("Failed to find bundle for 'us.gerstacker.advent-of-code.2024'.")
        }
        
        guard let dataURL = bundle.url(forResource: "Day15", withExtension: "txt") else {
            fatalError("Couldn't find file 'Day15.txt' in the 'Resources' directory.")
        }
        
        let data = try String(contentsOf: dataURL, encoding: .utf8)
        let blobs = data.split(separator: "\n\n")
        
        var warehouse = Day15.WideWarehouse()
        
        for (y, row) in blobs[0].split(separator: "\n").enumerated() {
            warehouse.height += 1
            warehouse.width = row.count * 2
            
            for (x, letter) in row.enumerated() {
                let point1 = Point(x: x * 2, y: y)
                let point2 = Point(x: x * 2 + 1, y: y)

                switch letter {
                case "#":
                    warehouse.walls.insert(point1)
                    warehouse.walls.insert(point2)
                case "@":
                    warehouse.robot = point1
                case "O":
                    warehouse.boxes.insert(point1)
                default: break
                }
            }
        }
        
        warehouse.instructions = blobs[1].compactMap {
            switch $0 {
            case "^": .north
            case "<": .west
            case ">": .east
            case "v": .south
            case "\n": nil
            default: fatalError("Unknown instruction: \($0)")
            }
        }
        
        try loadMesh(name: "Crate", fromResource: "Wooden_Crate")
        try loadMesh(name: "Wall", fromResource: "Stylized_Low-poly_Stone_Block")
        try loadBoxMesh(name: "Robot", extents: SIMD3<Float>(1.0, 1.0, 1.0), baseColor: SIMD4<Float>(1.0, 0.0, 0.0, 1.0), roughnessFactor: 0.5)
        
        offset = SIMD3<Float>(Float(warehouse.width) / -2 + 0.5, 0.0, Float(warehouse.height) / -2 + 0.5)
        
        for point in warehouse.walls {
            let nodeName = "Wall \(point.x), \(point.y)"
            addNode(name: nodeName, mesh: "Wall", batch: "Walls")
            
            let point3D = SIMD3<Float>(Float(point.x), 0, Float(point.y))
            let scale = unitScale(forMesh: "Wall")
            let translation = simd_float4x4(translate: offset + point3D)
            
            print("T: \(translation) for \(nodeName)")
            
            updateNode(name: nodeName, transform: translation * scale)
        }
        
        addNode(name: "Robot", mesh: "Robot")
        updateNode(name: "Robot", transform: translation(for: warehouse.robot))
        
        let cameraPosition = SIMD3<Float>(0, 35, offset.z * -1 + 3)
        updateCamera(eye: cameraPosition, lookAt: SIMD3<Float>(0, 0, 5), up: SIMD3<Float>(0, 1, 0))
        updatePerspective(near: 0.01, far: 200, angle: .pi / 2)

        addDirectLight(name: "Sun", lookAt: .zero, from: cameraPosition, up: SIMD3<Float>(0, 1, 0), intensity: 4)
        
        addPointLight(name: "Point 1", color: SIMD3<Float>(1.0, 1.0, 0.8), intensity: 500)
        
        warehouse.run { [weak self] boxes, robot, movingBoxes, vector in
            guard let self else { return }
            
            for box in boxes {
                let nodeName = "Box \(box.x), \(box.y)"
                addNode(name: nodeName, mesh: "Crate")
                
                let translation = translation(for: box, leftNudge: 0.5)
                let unitScale = unitScale(forMesh: "Crate")
                let scale = simd_float4x4(scale: SIMD3<Float>(2.0, 1.0, 1.0))
                
                updateNode(name: nodeName, transform: translation * unitScale * scale)
            }
            
            if let movingBoxes {
                for box in movingBoxes {
                    let nodeName = "Box \(box.x), \(box.y)"
                    addNode(name: nodeName, mesh: "Crate")
                }
            }
            
            for time: Float in stride(from: 0.0, to: 1.0, by: 0.2) {
                let adjustedTime = easeOutQuad(time)
                
                updateNode(name: "Robot", transform: translation(for: robot, vector: vector, progress: adjustedTime))
                updateLight(name: "Point 1", transform: translation(for: robot + vector, height: 15, vector: vector, progress: adjustedTime))
                
                if let movingBoxes {
                    for box in movingBoxes {
                        let nodeName = "Box \(box.x), \(box.y)"
                        
                        let translation = translation(for: box, vector: vector, progress: adjustedTime, leftNudge: 0.5)
                        let unitScale = unitScale(forMesh: "Crate")
                        let scale = simd_float4x4(scale: SIMD3<Float>(2.0, 1.0, 1.0))
                        
                        updateNode(name: nodeName, transform: translation * unitScale * scale)
                    }
                }

                try? snapshot()
            }

            
            for box in boxes {
                let nodeName = "Box \(box.x), \(box.y)"
                removeNode(name: nodeName)
            }
            
            if let movingBoxes {
                for box in movingBoxes {
                    let nodeName = "Box \(box.x), \(box.y)"
                    removeNode(name: nodeName)
                }
            }
        }
    }
    
    func translation(for point: Point, height: Float = 0, vector: Point = .zero, progress: Float = 0.0, leftNudge: Float = 0.0) -> simd_float4x4 {
        let point3D = SIMD3<Float>(Float(point.x) + leftNudge + (Float(vector.x) * progress), height, Float(point.y) + (Float(vector.y) * progress))
        let translation = simd_float4x4(translate: offset + point3D)

        return translation
    }
}
