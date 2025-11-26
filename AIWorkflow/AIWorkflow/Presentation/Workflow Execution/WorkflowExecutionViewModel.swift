//
//  WorkflowExecutionViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 14.11.2025.
//

import Foundation
import UIKit
import ActivityKit
import AppIntents

@MainActor
@Observable
final class WorkflowExecutionViewModel {
    // MARK: - Published State
    let workflow: Workflow
    
    var inputText = ""
    
    private(set) var isExecuting = false
    private(set) var currentStep: WorkflowStep?
    private(set) var currentStepIndex = 0
    private(set) var currentOutput = ""
    private(set) var completedSteps: [StepExecutionResult] = []
    private(set) var executionResult: WorkflowExecutionResult?
    private(set) var errorMessage: String?
    
    var progress: Double {
        guard workflow.hasSteps else { return 0 }
        return Double(completedSteps.count) / Double(workflow.stepCount)
    }
    
    var canExecute: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        workflow.hasSteps &&
        !isExecuting
    }
    
    var canCancel: Bool {
        isExecuting
    }
    
    private let haptics = UINotificationFeedbackGenerator()
    
    // MARK: - Dependencies
    private let executionService: WorkflowExecutionService
    
    // MARK: - Init
    init(
        workflow: Workflow,
        executionService: WorkflowExecutionService
    ) {
        self.workflow = workflow
        self.executionService = executionService
    }
}

// MARK: - Public Methods
extension WorkflowExecutionViewModel {
    func execute() async {
        guard canExecute else { return }
        isExecuting = true
        resetState()
        
        do {
            let result = try await executionService.executeWorkflow(
                workflow: workflow,
                inputText: inputText,
                enableLiveActivity: true,
                onStepStart: { [weak self] step in
                    self?.handleStepStart(step)
                },
                onStepProgress: { [weak self] step, output in
                    self?.handleStepProgress(step, output: output)
                },
                onStepComplete: { [weak self] result in
                    self?.handleStepComplete(result)
                }
            )
            
            executionResult = result
            
        } catch {
            if let execError = error as? WorkflowExecutionError {
                errorMessage = execError.localizedDescription
            } else {
                errorMessage = error.localizedDescription
            }
        }
        
        isExecuting = false
        currentStep = nil
    }
    
    func cancel() {
        guard canCancel else { return }
        executionService.cancelExecution()
    }
    
    func reset() {
        inputText = ""
        currentStep = nil
        resetState()
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Private Methods
private extension WorkflowExecutionViewModel {
    func resetState() {
        currentStepIndex = 0
        currentOutput = ""
        completedSteps = []
        executionResult = nil
        errorMessage = nil
    }
    
    func handleStepStart(_ step: WorkflowStep) {
        currentStep = step
        currentStepIndex = completedSteps.count
        currentOutput = ""
    }
    
    func handleStepProgress(_ step: WorkflowStep, output: String) {
        currentOutput = output
    }
    
    func handleStepComplete(_ result: StepExecutionResult) {
        completedSteps.append(result)
        currentOutput = result.output
        
        if result.isSuccess {
            haptics.notificationOccurred(.success)
        } else {
            haptics.notificationOccurred(.error)
        }
    }
}
