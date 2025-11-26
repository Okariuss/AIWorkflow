//
//  WorkflowCreationViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Foundation

@MainActor
@Observable
final class WorkflowCreationViewModel {
    
    // MARK: - Published State
    var name = ""
    var workflowDescription = ""
    
    private(set) var steps: [WorkflowStep] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var validationError: String?
    
    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !steps.isEmpty
    }
    
    var getExistingWorkflow: Workflow? {
        existingWorkflow
    }
    
    // MARK: - Dependencies
    private let repository: WorkflowRepositoryProtocol
    private let existingWorkflow: Workflow?
    
    // MARK: Init
    init(
        repository: WorkflowRepositoryProtocol,
        existingWorkflow: Workflow? = nil
    ) {
        self.repository = repository
        self.existingWorkflow = existingWorkflow
        
        if let workflow = existingWorkflow {
            self.name = workflow.name
            self.workflowDescription = workflow.workflowDescription
            self.steps = workflow.sortedSteps
        }
    }
}

// MARK: - Public Methods
extension WorkflowCreationViewModel {
    // MARK: - Step Management
    
    func addStep(_ step: WorkflowStep) {
        step.order = steps.count
        steps.append(step)
    }
    
    func updateStep(_ step: WorkflowStep, at index: Int) {
        guard steps.indices.contains(index) else { return }
        steps[index] = step
        reorderSteps()
    }
    
    func deleteStep(at index: Int) {
        guard steps.indices.contains(index) else { return }
        steps.remove(at: index)
        reorderSteps()
    }
    
    func moveStep(from source: Int, to destination: Int) {
        guard
            steps.indices.contains(source),
            steps.indices.contains(destination)
        else { return }
        
        let step = steps.remove(at: source)
        steps.insert(step, at: destination)
        reorderSteps()
    }
    
    func duplicateStep(at index: Int) {
        guard steps.indices.contains(index) else { return }
        
        let originalStep = steps[index]
        let duplicatedStep = WorkflowStep(
            stepType: originalStep.stepType,
            prompt: originalStep.prompt,
            order: steps.count
        )
        
        steps.append(duplicatedStep)
        reorderSteps()
    }
    
    // MARK: - Validation
    
    func validate() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedName.isEmpty {
            validationError = L10N.WorkflowCreation.Validation.nameRequired
            return false
        }
        
        if trimmedName.count < 3 {
            validationError = L10N.WorkflowCreation.Validation.nameShort
            return false
        }
        
        if steps.isEmpty {
            validationError = L10N.WorkflowCreation.Validation.stepsRequired
            return false
        }
        
        validationError = nil
        return true
    }
    
    // MARK: - Save
    
    func saveWorkflow() async -> Bool {
        guard validate() else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let workflow: Workflow
            
            if let existing = existingWorkflow {
                workflow = existing
                workflow.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
                workflow.workflowDescription = workflowDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                
                workflow.steps.removeAll()
            } else {
                workflow = Workflow(
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    workflowDescription: workflowDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            
            for step in steps {
                step.workflow = workflow
                workflow.steps.append(step)
            }
            
            try await repository.save(workflow)
            
            isLoading = false
            return true
        } catch {
            errorMessage = "\(L10N.Error.saveFailed): \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    // MARK: - Error Handling
    
    func clearValidationError() {
        validationError = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Private Methods
private extension WorkflowCreationViewModel {
    func reorderSteps() {
        for (index, step) in steps.enumerated() {
            step.order = index
        }
    }
}
