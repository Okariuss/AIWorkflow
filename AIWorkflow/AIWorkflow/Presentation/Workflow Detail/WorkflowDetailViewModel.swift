//
//  WorkflowDetailViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Foundation

@MainActor
@Observable
final class WorkflowDetailViewModel {
    
    // MARK: - Published State
    let workflow: Workflow
    
    private(set) var errorMessage: String?
    private(set) var wasDeleted = false
    private(set) var isLoading = false
    
    var showingDeleteConfirmation = false

    // MARK: - Dependencies
    private let repository: WorkflowRepositoryProtocol
    
    // MARK: - Init
    init(workflow: Workflow, repository: WorkflowRepositoryProtocol) {
        self.workflow = workflow
        self.repository = repository
    }
    
    // MARK: - Computed Properties
    var createdDateFormatted: String {
        workflow.createdAt.formatted(date: .abbreviated, time: .shortened)
    }
    
    var modifiedDateFormatted: String {
        workflow.modifiedAt.formatted(date: .abbreviated, time: .shortened)
    }
    
    var modifiedDateRelative: String {
        workflow.modifiedAt.formatted(.relative(presentation: .named))
    }
    
    var canRun: Bool {
        workflow.hasSteps
    }
}


// MARK: - Public Methods
extension WorkflowDetailViewModel {
    func toggleFavorite() async {
        workflow.isFavorite.toggle()
        
        do {
            try await repository.save(workflow)
        } catch {
            workflow.isFavorite.toggle()
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }
    
    func deleteWorkflow() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.delete(workflow)
            wasDeleted = true
        } catch {
            errorMessage = "Failed to delete workflow: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func duplicateWorkflow() async -> Workflow? {
        isLoading = true
        errorMessage = nil
        
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
            isLoading = false
            return newWorkflow
        } catch {
            errorMessage = "Failed to duplicate workflow: \(error.localizedDescription)"
            isLoading = false
            return nil
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
