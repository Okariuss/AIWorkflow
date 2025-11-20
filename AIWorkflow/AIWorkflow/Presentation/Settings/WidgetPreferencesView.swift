//
//  WidgetPreferencesView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import SwiftUI
import SwiftData

struct WidgetPreferencesView: View {
    
    // MARK: - SwiftData Query
    @Query(sort: \Workflow.name)
    private var allWorkflows: [Workflow]
    
    // MARK: - Properties
    @State var viewModel: SettingsViewModel
    @State private var selectedCount = 0
    
    // MARK: - View
    var body: some View {
        List {
            instructionsSection
            
            if allWorkflows.isEmpty {
                emptyStateSection
            } else {
                workflowsSection
            }
        }
        .navigationTitle("Widget Preferences")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            updateSelectedCount()
        }
        .onChange(of: viewModel.widgetSelections) { _, _ in
            updateSelectedCount()
        }
    }
    
    private func updateSelectedCount() {
        selectedCount = viewModel.widgetSelections.count
    }
}

// MARK: - Subviews
private extension WidgetPreferencesView {
    var instructionsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Widget Workflows")
                            .font(.headline)
                        
                        Text("Select up to 4 workflows to display")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: selectedCount > 0 ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selectedCount > 0 ? .green : .secondary)
                    
                    Text("\(selectedCount) of 4 selected")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .animation(.easeInOut(duration: 0.2), value: selectedCount)
            }
            .padding(.vertical, 4)
        }
    }
    
    var emptyStateSection: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "square.stack.3d.up.slash")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)
                
                Text("No Workflows Available")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text("Create workflows in the app first")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        }
    }
    
    var workflowsSection: some View {
        Section {
            ForEach(allWorkflows, id: \.id) { workflow in
                WorkflowWidgetToggleRow(
                    workflow: workflow,
                    isSelected: viewModel.widgetSelections.contains(workflow.id),
                    canSelect: viewModel.widgetSelections.contains(workflow.id) || viewModel.widgetSelections.count < 4
                ) { isSelected in
                    Task {
                        if isSelected {
                            await viewModel.addWidgetSelected(workflow.id)
                        } else {
                            await viewModel.removeWidgetSelected(workflow.id)
                        }
                    }
                }
            }
        } header: {
            Text("Available Workflows")
        } footer: {
            Text("Selected workflows will appear in your home screen widget. Changes take effect immediately.")
                .font(.caption)
        }
    }
}

#Preview {
    NavigationStack {
        WidgetPreferencesView(
            viewModel: SettingsViewModel(
                repository: DependencyContainer.shared.preferencesRepository,
                workflowRepository: DependencyContainer.shared.workflowRepository,
                widgetService: DependencyContainer.shared.widgetService
            )
        )
        .modelContainer(DependencyContainer.shared.container)
    }
}
