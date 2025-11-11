//
//  WorkflowListView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct WorkflowListView: View {
    
    // MARK: - Properties
    @State private var viewModel: WorkflowListViewModel
    @State private var showingCreateSheet = false
    @State private var selectedWorkflow: Workflow?
    
    
    // MARK: - Init
    init(viewModel: WorkflowListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.workflows.isEmpty {
                    ProgressView("Loading workflows...")
                } else if viewModel.workflows.isEmpty {
                    emptyStateView
                } else {
                    workflowsList
                }
            }
            .navigationTitle("Workflows")
            .toolbar {
                toolbarContent
            }
            .searchable(text: $viewModel.searchQuery, prompt: "Search workflows")
            .refreshable {
                await viewModel.loadWorkflows()
            }
            .sheet(isPresented: $showingCreateSheet) {
                // Placeholder for now
                Text("Create workflow screen")
                    .font(.title)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .task {
                await viewModel.loadWorkflows()
            }
        }
    }
}

// MARK: - Subviews
private extension WorkflowListView {
    @ViewBuilder
    var emptyStateView: some View {
        if viewModel.searchQuery.isEmpty {
            EmptyStateView(
                message: viewModel.filterOption == .favorites ? "No favorite workflows yet" : "No workflows yet",
                systemImage: viewModel.filterOption == .favorites ? "star.slash" : "square.stack.3d.up.slash",
                actionTitle: "Create Workflow",
                action: { showingCreateSheet = true }
            )
        } else {
            EmptyStateView(message: "No workflows for '\(viewModel.searchQuery)'", systemImage: "magnifyingglass")
        }
    }
    
    var workflowsList: some View {
        List {
            ForEach(viewModel.workflows, id: \.id) { workflow in
                NavigationLink(value: workflow) {
                    WorkflowRowView(workflow: workflow) {
                        Task {
                            await viewModel.toggleFavorite(workflow)
                        }
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    deleteButton(for: workflow)
                    duplicateButton(for: workflow)
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    favoriteButton(for: workflow)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Workflow.self) { workflow in
            // Placeholder for now
            Text("Workflow Detail: \(workflow.name)")
                .font(.title)
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Filter", selection: $viewModel.filterOption) {
                    ForEach(WorkflowListViewModel.FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(WorkflowListViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingCreateSheet = true
            } label: {
                Label("Create Workflow", systemImage: "plus")
            }
        }
    }
}

// MARK: - Swipe Actions Buttons
private extension WorkflowListView {
    func deleteButton(for workflow: Workflow) -> some View {
        Button(role: .destructive) {
            Task {
                await viewModel.deleteWorkflow(workflow)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    func duplicateButton(for workflow: Workflow) -> some View {
        Button {
            Task {
                await viewModel.duplicateWorkflows(workflow)
            }
        } label: {
            Label("Duplicate", systemImage: "doc.on.doc")
        }
        .tint(.blue)
    }
    
    func favoriteButton(for workflow: Workflow) -> some View {
        Button {
            Task {
                await viewModel.toggleFavorite(workflow)
            }
        } label: {
            Label(
                workflow.isFavorite ? "Unfavorite" : "Favorite",
                systemImage: workflow.isFavorite ? "star.slash" : "star.fill"
            )
        }
        .tint(.yellow)
    }
}

#Preview("With Workflows") {
    let container = DependencyContainer.shared
    let viewModel = WorkflowListViewModel(repository: container.workflowRepository)
    
    // Add sample workflows
//    Task {
//        let workflow1 = Workflow(
//            name: "Summarize & Translate",
//            workflowDescription: "Summarize text and translate to Spanish"
//        )
//        workflow1.steps = [
//            WorkflowStep(stepType: "summarize", prompt: "Summarize", order: 0),
//            WorkflowStep(stepType: "translate", prompt: "Translate", order: 1)
//        ]
//        
//        let workflow2 = Workflow(
//            name: "Extract Key Points",
//            workflowDescription: "Extract the main ideas from any text"
//        )
//        workflow2.isFavorite = true
//        workflow2.steps = [
//            WorkflowStep(stepType: "extract", prompt: "Extract", order: 0)
//        ]
//        
//        try? await container.workflowRepository.save(workflow1)
//        try? await container.workflowRepository.save(workflow2)
//    }
    
    return WorkflowListView(viewModel: viewModel)
}

#Preview("Empty State") {
    let container = DependencyContainer.shared
    let viewModel = WorkflowListViewModel(repository: container.workflowRepository)
    
    return WorkflowListView(viewModel: viewModel)
}
