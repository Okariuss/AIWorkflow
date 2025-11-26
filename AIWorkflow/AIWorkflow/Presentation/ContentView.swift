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
    @State private var workflowToOpen: Workflow?

    
    var body: some View {
        WorkflowListView(
            viewModel: container.makeWorkflowListViewModel()
        )
        .sheet(item: $workflowToOpen) { workflow in
            NavigationStack {
                WorkflowExecutionView(viewModel: container.makeWorkflowExecutionViewModel(workflow: workflow))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("OpenWorkflow"))) { notification in
            guard let workflowId = notification.userInfo?["workflowId"] as? UUID else {
                return
            }
            
            Task {
                if let workflow = try? await container.workflowRepository.fetch(by: workflowId) {
                    await MainActor.run {
                        workflowToOpen = workflow
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(DependencyContainer.shared.container)
}
