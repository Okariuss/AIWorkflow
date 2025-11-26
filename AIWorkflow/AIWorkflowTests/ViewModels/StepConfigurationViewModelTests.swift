//
//  StepConfigurationViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("StepConfigurationViewModel Tests")
@MainActor
struct StepConfigurationViewModelTests {
    
    // MARK: - Tests

    @Test("ViewModel initializes with default values")
    func testInitialization() {
        let viewModel = StepConfigurationViewModel()
        
        #expect(viewModel.selectedStepType == .summarize)
        #expect(viewModel.prompt.isEmpty)
        #expect(viewModel.validationError == nil)
        #expect(viewModel.isValid == false)
    }
    
    @Test("ViewModel pre-fills when editing")
    func testInitializationWithExistingStep() {
        let step = WorkflowStep(
            stepType: WorkflowStep.StepType.translate.rawValue,
            prompt: "Trabslate to Spanish",
            order: 0
        )
        
        let viewModel = StepConfigurationViewModel(existingStep: step)
        
        #expect(viewModel.selectedStepType == .translate)
        #expect(viewModel.prompt == "Trabslate to Spanish")
    }
    
    @Test("Validation fails for empty prompt")
    func testValidationEmptyPrompt() {
        let viewModel = StepConfigurationViewModel()
        viewModel.prompt = ""
        
        let isValid = viewModel.validate()
        
        #expect(isValid == false)
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Validation fails for short prompt")
    func testValidationShortPrompt() {
        let viewModel = StepConfigurationViewModel()
        viewModel.prompt = "ab"
        
        let isValid = viewModel.validate()
        
        #expect(isValid == false)
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Validation succeeds for valid prompt")
    func testValidationSuccess() {
        let viewModel = StepConfigurationViewModel()
        viewModel.prompt = "Summarize this text"
        
        let isValid = viewModel.validate()
        
        #expect(isValid == true)
        #expect(viewModel.validationError == nil)
    }
    
    @Test("Create step returns new step")
    func testCreateStep() {
        let viewModel = StepConfigurationViewModel()
        viewModel.selectedStepType = .summarize
        viewModel.prompt = "Test prompt"
        
        let step = viewModel.createStep(order: 0)
        
        #expect(step.stepType == WorkflowStep.StepType.summarize.rawValue)
        #expect(step.prompt == "Test prompt")
        #expect(step.order == 0)
    }
    
    @Test("Full prompt includes system prompt")
    func testFullPrompt() {
        let viewModel = StepConfigurationViewModel()
        viewModel.selectedStepType = .summarize
        viewModel.prompt = "My custom instructions"
        
        let fullPrompt = viewModel.fullPrompt
        
        #expect(fullPrompt.contains(L10N.StepType.summarizeSystemPrompt))
        #expect(fullPrompt.contains("My custom instructions"))
    }
}
