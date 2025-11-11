//
//  ContentView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    
    private let container = DependencyContainer.shared
    
    var body: some View {
        WorkflowListView(
            viewModel: container.makeWorkflowListViewModel()
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(DependencyContainer.shared.container)
}
