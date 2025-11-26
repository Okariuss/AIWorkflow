//
//  WorkflowListView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI
import SwiftData

struct WorkflowListView: View {
    
    // MARK: - SwiftData Query
    @Query(sort: \Workflow.modifiedAt, order: .reverse)
    private var allWorkflows: [Workflow]
    
    // MARK: - Properties
    @State private var viewModel: WorkflowListViewModel
    @State private var selectedWorkflow: Workflow?
    
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingCreateSheet = false
    @State private var showingDeleteConfirmation = false
    @State private var workflowToDelete: Workflow?
    
    // MARK: - Init
    init(viewModel: WorkflowListViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Computed Properties
    private var filteredWorkflows: [Workflow] {
        viewModel.filterWorkflows(allWorkflows)
    }
    
    // MARK: - View
    var body: some View {
        NavigationStack {
            Group {
                if filteredWorkflows.isEmpty {
                    emptyStateView
                } else {
                    workflowsList
                }
            }
            .navigationTitle(L10N.WorkflowList.title)
            .toolbar {
                toolbarContent
            }
            .searchable(text: $viewModel.searchQuery, prompt: L10N.WorkflowList.search)
            .sheet(isPresented: $showingCreateSheet) {
                WorkflowCreationView(viewModel: DependencyContainer.shared.makeWorkflowCreationViewModel())
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingHistory) {
                NavigationStack {
                    ExecutionHistoryView(
                        viewModel: DependencyContainer.shared.makeExecutionHistoryViewModel()
                    )
                }
            }
            .alert(L10N.WorkflowDetail.Delete.title, isPresented: $showingDeleteConfirmation, presenting: workflowToDelete) { workflow in
                Button(L10N.Common.cancel, role: .cancel) {
                    workflowToDelete = nil
                }
                Button(L10N.Common.delete, role: .destructive) {
                    deleteWorkflow(workflow)
                }
            } message: { workflow in
                Text(L10N.WorkflowList.deleteMessage(workflow.name))
            }
            .alert(L10N.Common.error, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button(L10N.Common.ok) {
                    viewModel.clearError()
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
            .animation(.spring(response: 0.3), value: filteredWorkflows.count)
        }
    }
}

// MARK: - Subviews
private extension WorkflowListView {
    @ViewBuilder
    var emptyStateView: some View {
        if viewModel.searchQuery.isEmpty && allWorkflows.isEmpty {
            EmptyStateView(
                message: L10N.WorkflowList.emptyMessage,
                systemImage: "square.stack.3d.up.slash",
                actionTitle: L10N.WorkflowList.emptyAction,
                action: {
                    HapticManager.shared.impact(.medium)
                    showingCreateSheet = true
                }
            )
        } else if viewModel.searchQuery.isEmpty && viewModel.filterOption == .favorites {
            EmptyStateView(
                message: L10N.WorkflowList.favoritesEmptyMessage,
                systemImage: "star.slash",
                actionTitle: L10N.WorkflowList.favoritesEmptyAction,
                action: {
                    HapticManager.shared.selectionChanged()
                    withAnimation {
                        viewModel.filterOption = .all
                    }
                }
            )
        } else if !viewModel.searchQuery.isEmpty {
            EmptyStateView(message: L10N.WorkflowList.searchEmpty(viewModel.searchQuery), systemImage: "magnifyingglass")
        } else {
            EmptyStateView(
                message: L10N.WorkflowList.filterNoMatch,
                systemImage: "line.3.horizontal.decrease.circle"
            )
        }
    }
    
    var workflowsList: some View {
        List {
            ForEach(filteredWorkflows, id: \.id) { workflow in
                NavigationLink(value: workflow) {
                    WorkflowRowView(workflow: workflow) {
                        Task {
                            HapticManager.shared.impact(.light)
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
                .transition(.opacity.combined(with: .slide))
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: Workflow.self) { workflow in
            WorkflowDetailView(
                viewModel: DependencyContainer.shared.makeWorkflowDetailViewModel(workflow: workflow)
            )
        }
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker(L10N.Common.filter, selection: $viewModel.filterOption) {
                    ForEach(WorkflowListViewModel.FilterOption.allCases, id: \.self) { option in
                        Text(option.title)
                            .tag(option)
                    }
                }
            } label: {
                Label(L10N.Common.filter, systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                HapticManager.shared.impact(.light)
                showingSettings = true
            } label: {
                Label(L10N.WorkflowList.settings, systemImage: "gear")
            }
        }
        
        ToolbarItem(placement: .topBarLeading) {
            Button {
                HapticManager.shared.impact(.light)
                showingHistory = true
            } label: {
                Label(L10N.WorkflowList.history, systemImage: "clock.arrow.circlepath")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker(L10N.Common.sort, selection: $viewModel.sortOption) {
                    ForEach(WorkflowListViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.title)
                            .tag(option)
                    }
                }
            } label: {
                Label(L10N.Common.sort, systemImage: "arrow.up.arrow.down")
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button {
                HapticManager.shared.impact(.medium)
                showingCreateSheet = true
            } label: {
                Label(L10N.WorkflowList.create, systemImage: "plus")
            }
        }
    }
}

// MARK: - Swipe Actions Buttons
private extension WorkflowListView {
    func deleteButton(for workflow: Workflow) -> some View {
        Button(role: .destructive) {
            HapticManager.shared.notification(.warning)
            workflowToDelete = workflow
            showingDeleteConfirmation = true
        } label: {
            Label(L10N.Common.delete, systemImage: "trash")
        }
    }
    
    func duplicateButton(for workflow: Workflow) -> some View {
        Button {
            Task {
                HapticManager.shared.impact(.medium)
                await viewModel.duplicateWorkflows(workflow)
                HapticManager.shared.notification(.success)
            }
        } label: {
            Label(L10N.WorkflowDetail.Actions.duplicate, systemImage: "doc.on.doc")
        }
        .tint(.blue)
    }
    
    func favoriteButton(for workflow: Workflow) -> some View {
        Button {
            Task {
                HapticManager.shared.impact(.light)
                await viewModel.toggleFavorite(workflow)
            }
        } label: {
            Label(
                workflow.isFavorite ? L10N.WorkflowDetail.Actions.unfavorite : L10N.WorkflowDetail.Actions.favorite,
                systemImage: workflow.isFavorite ? "star.slash" : "star.fill"
            )
        }
        .tint(.yellow)
    }
    
    func deleteWorkflow(_ workflow: Workflow) {
        Task {
            await viewModel.deleteWorkflow(workflow)
            if viewModel.errorMessage == nil {
                HapticManager.shared.notification(.success)
            } else {
                HapticManager.shared.notification(.error)
            }
            workflowToDelete = nil
        }
    }
}

// MARK: - Supporting Types
extension WorkflowListViewModel.FilterOption {
    var icon: String {
        switch self {
        case .all: return "square.stack.3d.up"
        case .favorites: return "star.fill"
        }
    }
}

extension WorkflowListViewModel.SortOption {
    var icon: String {
        switch self {
        case .name: return "textformat"
        case .modifiedDate: return "clock.arrow.circlepath"
        case .createdDate: return "calendar.badge.plus"
        case .stepCount: return "list.number"
        }
    }
}

#Preview("With Workflows") {
    let container = DependencyContainer.shared
    let viewModel = WorkflowListViewModel(
        repository: container.workflowRepository,
        widgetService: container.widgetService
    )
    
    Task {
        let workflow1 = Workflow(
            name: "Summarize & Translate",
            workflowDescription: "Summarize text and translate to Spanish"
        )
        workflow1.steps = [
            WorkflowStep(stepType: "summarize", prompt: "Summarize", order: 0),
            WorkflowStep(stepType: "translate", prompt: "Translate", order: 1)
        ]
        
        let workflow2 = Workflow(
            name: "Extract Key Points",
            workflowDescription: "Extract the main ideas from any text"
        )
        workflow2.isFavorite = true
        workflow2.steps = [
            WorkflowStep(stepType: "extract", prompt: "Extract", order: 0)
        ]
        
        try? await container.workflowRepository.save(workflow1)
        try? await container.workflowRepository.save(workflow2)
    }
    
    return WorkflowListView(viewModel: viewModel)
}

#Preview("Empty State") {
    let container = DependencyContainer.shared
    let viewModel = WorkflowListViewModel(
        repository: container.workflowRepository,
        widgetService: container.widgetService
    )
    
    return WorkflowListView(viewModel: viewModel)
}
