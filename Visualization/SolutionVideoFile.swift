//
//  SolutionVideoFile.swift
//  Advent of Code 2024 Visualization
//
//  Created by Stephen H. Gerstacker on 2023-11-26.
//  SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct SolutionVideoFile: FileDocument {
    
    static var readableContentTypes = [UTType.mpeg4Movie]
    
    private let sourceURL: URL
    
    init(sourceURL: URL) {
        self.sourceURL = sourceURL
    }
    
    init(configuration: ReadConfiguration) throws {
        throw SolutionError.apiError("Cannot init with read configuration")
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return try FileWrapper(url: sourceURL)
    }
}
