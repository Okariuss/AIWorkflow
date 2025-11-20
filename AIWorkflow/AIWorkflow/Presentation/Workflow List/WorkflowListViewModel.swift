//
//  WorkflowListViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Foundation

@MainActor
@Observable
final class WorkflowListViewModel {
    
    // MARK: - Published State
    private(set) var errorMessage: String?
    
    var searchQuery = ""
    
    var sortOption: SortOption = .modifiedDate
    
    var filterOption: FilterOption = .all
    
    var onFavoritesChanged: (() -> Void)?
    
    // MARK: - Dependencies
    private let repository: WorkflowRepositoryProtocol
    private let widgetService: WidgetServiceProtocol
    
    init(
        repository: WorkflowRepositoryProtocol,
        widgetService: WidgetServiceProtocol
    ) {
        self.repository = repository
        self.widgetService = widgetService
    }
}

// MARK: - Public Methods
extension WorkflowListViewModel {
    
    func deleteWorkflow(_ workflow: Workflow) async {
        do {
            try await repository.delete(workflow)
            await widgetService.refreshWidgets()
        } catch {
            errorMessage = "Failed to delete workflow: \(error.localizedDescription)"
        }
    }
    
    func toggleFavorite(_ workflow: Workflow) async {
        workflow.isFavorite.toggle()
        
        do {
            try await repository.save(workflow)
            
            await widgetService.refreshWidgets()
        } catch {
            workflow.isFavorite.toggle()
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }
    
    func duplicateWorkflows(_ workflow: Workflow) async {
        let newWorkflow = Workflow(
            name: "\(workflow.name) (Copy)",
            workflowDescription: workflow.workflowDescription,
            isFavorite: false
        )
        
        for step in workflow.sortedSteps {
            let newStep = WorkflowStep(
                stepType: step.stepType,
                prompt: step.prompt,
                order: step.order
            )
            newStep.workflow = newWorkflow
            newWorkflow.steps.append(newStep)
        }
        
        do {
            try await repository.save(newWorkflow)
        } catch {
            errorMessage = "Failed to duplicate workflow: \(error.localizedDescription)"
        }
    }
    
    func filterWorkflows(_ workflows: [Workflow]) -> [Workflow] {
        var filtered = workflows
        
        switch filterOption {
        case .all:
            break
        case .favorites:
            filtered = filtered.filter { $0.isFavorite }
        }
        
        if !searchQuery.isEmpty {
            filtered = filtered.filter { workflow in
                workflow.name.localizedStandardContains(searchQuery)
            }
        }
        
        return sortWorkflows(filtered)
    }
    
    func sortWorkflows(_ workflows: [Workflow]) -> [Workflow] {
        switch sortOption {
        case .name:
            return workflows.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .modifiedDate:
            return workflows.sorted { $0.modifiedAt > $1.modifiedAt }
        case .createdDate:
            return workflows.sorted { $0.createdAt > $1.createdAt }
        case .stepCount:
            return workflows.sorted { $0.stepCount > $1.stepCount }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types
extension WorkflowListViewModel {
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case modifiedDate = "Last Modified"
        case createdDate = "Date Created"
        case stepCount = "Step Count"
    }
    
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
    }
}
