//
//  Day14VisualizationApp.swift
//  Day 14 Visualization
//
//  Created by Stephen H. Gerstacker on 2024-12-14.
//

import SwiftUI
import Visualization

@main
struct Day_14_VisualizationApp: App {
    
    @State var context: SolutionContext = VisualizationContext(width: 101 * 20, height: 103 * 20 + 20, frameRate: 60.0)
    
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
