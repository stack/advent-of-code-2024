//
//  Day10VisualizationApp.swift
//  Day 10 Visualization
//
//  Created by Stephen H. Gerstacker on 2024-12-10.
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import Visualization

@main
struct Day_10_VisualizationApp: App {
    
    @State var context: SolutionContext = TerrainContext(width: 3840, height: 2160, frameRate: 60.0, maxConstantsSize: 1024 * 1024 * 20)
    
    var body: some Scene {
        WindowGroup {
#if os(macOS)
            SolutionView()
                .environment(context)
                .navigationTitle(context.name)
#else
            NavigationStack {
                SolutionView()
                    .environment(context)
                    .navigationTitle(context.name)
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea(.all, edges: [.bottom])
            }
#endif
        }
    }
}
