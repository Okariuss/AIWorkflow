//
//  ContentView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            Text("AI Workflow App")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Build B-001 Completed")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Text("Architecture foundation is ready!")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
