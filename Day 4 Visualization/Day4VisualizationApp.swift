//
//  Day4VisualizationApp.swift
//  Day 4 Visualization
//
//  Created by Stephen H. Gerstacker on 2024-12-04.
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import Visualization

@main
struct Day4VisualizationApp: App {
    
    @State var context: SolutionContext = VisualizationContext(width: 2048, height: 2048, frameRate: 60.0)
    
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
