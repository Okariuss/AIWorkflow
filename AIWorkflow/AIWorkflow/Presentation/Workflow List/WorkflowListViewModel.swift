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
    private(set) var workflows: [Workflow] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var searchQuery = "" {
        didSet {
            Task {
                await searchWorkflows()
            }
        }
    }
    
    var sortOption: SortOption = .modifiedDate {
        didSet {
            sortWorkflows()
        }
    }
    
    var filterOption: FilterOption = .all {
        didSet {
            Task {
                await loadWorkflows()
            }
        }
    }
    
    // MARK: - Dependencies
    private let repository: WorkflowRepositoryProtocol
    
    init(repository: WorkflowRepositoryProtocol) {
        self.repository = repository
    }
}

// MARK: - Public Methods
extension WorkflowListViewModel {
    func loadWorkflows() async {
        isLoading = true
        errorMessage = nil
        
        do {
            switch filterOption {
            case .all:
                workflows = try await repository.fetchAll()
            case .favorites:
                workflows = try await repository.fetchFavorites()
            }
            sortWorkflows()
        } catch {
            errorMessage = "Failed to load workflows: \(error.localizedDescription)"
            workflows = []
        }
        isLoading = false
    }
    
    func deleteWorkflow(_ workflow: Workflow) async {
        do {
            try await repository.delete(workflow)
            workflows.removeAll { $0.id == workflow.id }
        } catch {
            errorMessage = "Failed to delete workflow: \(error.localizedDescription)"
        }
    }
    
    func toggleFavorite(_ workflow: Workflow) async {
        workflow.isFavorite.toggle()
        
        do {
            try await repository.save(workflow)
            
            if filterOption == .favorites {
                await loadWorkflows()
            }
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
            await loadWorkflows()
        } catch {
            errorMessage = "Failed to duplicate workflow: \(error.localizedDescription)"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Private Methods
private extension WorkflowListViewModel {
    func searchWorkflows() async {
        guard !searchQuery.isEmpty else {
            await loadWorkflows()
            return
        }
        
        isLoading = true
        
        do {
            workflows = try await repository.search(query: searchQuery)
            sortWorkflows()
        } catch {
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func sortWorkflows() {
        switch sortOption {
        case .name:
            workflows.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .modifiedDate:
            workflows.sort { $0.modifiedAt > $1.modifiedAt }
        case .createdDate:
            workflows.sort { $0.createdAt > $1.createdAt }
        case .stepCount:
            workflows.sort { $0.stepCount > $1.stepCount }
        }
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
