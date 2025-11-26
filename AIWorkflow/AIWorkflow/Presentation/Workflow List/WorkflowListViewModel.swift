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
            errorMessage = "\(L10N.Error.deleteFailed): \(error.localizedDescription)"
        }
    }
    
    func toggleFavorite(_ workflow: Workflow) async {
        workflow.isFavorite.toggle()
        
        do {
            try await repository.save(workflow)
            
            await widgetService.refreshWidgets()
        } catch {
            workflow.isFavorite.toggle()
            errorMessage = "\(L10N.Error.favoriteUpdateFailed): \(error.localizedDescription)"
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
            errorMessage = "\(L10N.WorkflowDetail.Duplicated.error): \(error.localizedDescription)"
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
        case name
        case modifiedDate
        case createdDate
        case stepCount
        
        var title: String {
            switch self {
            case .name: L10N.WorkflowList.Sort.name
            case .modifiedDate: L10N.WorkflowList.Sort.modified
            case .createdDate: L10N.WorkflowList.Sort.created
            case .stepCount: L10N.WorkflowList.Sort.steps
            }
        }
    }
    
    enum FilterOption: String, CaseIterable {
        case all
        case favorites
        
        var title: String {
            switch self {
            case .all: L10N.WorkflowList.Filter.all
            case .favorites: L10N.WorkflowList.Filter.favorites
            }
        }
    }
}
