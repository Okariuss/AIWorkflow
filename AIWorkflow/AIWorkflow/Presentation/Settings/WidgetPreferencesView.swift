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
        .navigationTitle(L10N.WidgetPreferences.title)
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
                        Text(L10N.WidgetPreferences.header)
                            .font(.headline)
                        
                        Text(L10N.WidgetPreferences.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: selectedCount > 0 ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(selectedCount > 0 ? .green : .secondary)
                    
                    Text(L10N.WidgetPreferences.selected(selectedCount))
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
                
                Text(L10N.WidgetPreferences.emptyTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(L10N.WidgetPreferences.emptyMessage)
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
            Text(L10N.WidgetPreferences.available)
        } footer: {
            Text(L10N.WidgetPreferences.footer)
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
