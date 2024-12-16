//
//  Day_15_VisualizationApp.swift
//  Day 15 Visualization
//
//  Created by Stephen H. Gerstacker on 2024-12-15.
//

import SwiftUI
import Visualization

@main
struct Day15VisualizationApp: App {
    @State var context: SolutionContext = WarehouseContext(width: 3840, height: 2160, frameRate: 60.0, maxConstantsSize: 1024 * 1024 * 20)
    
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
