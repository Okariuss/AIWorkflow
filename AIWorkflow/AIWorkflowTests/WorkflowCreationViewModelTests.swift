//
//  WorkflowCreationViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowCreationViewModel Tests")
@MainActor
struct WorkflowCreationViewModelTests {
    
    // MARK: - Mock Repository
    final class MockWorkflowRepository: WorkflowRepositoryProtocol {
        var workflows: [Workflow] = []
        var shouldThrowError = false
        var saveCalled = false
        
        func fetchAll() async throws -> [Workflow] {
            workflows
        }
        
        func fetch(by id: UUID) async throws -> Workflow? {
            workflows.first { $0.id == id }
        }
        
        func save(_ workflow: Workflow) async throws {
            saveCalled = true
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
                workflows[index] = workflow
            } else {
                workflows.append(workflow)
            }
        }
        
        func delete(_ workflow: Workflow) async throws {
            workflows.removeAll { $0.id == workflow.id }
        }
        
        func fetchFavorites() async throws -> [Workflow] {
            workflows.filter { $0.isFavorite }
        }
        
        func search(query: String) async throws -> [Workflow] {
            workflows.filter { $0.name.localizedStandardContains(query) }
        }
    }
    
    @Test("ViewModel initializes with empty state")
    func testInitialization() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        #expect(viewModel.name.isEmpty)
        #expect(viewModel.workflowDescription.isEmpty)
        #expect(viewModel.steps.isEmpty)
        #expect(viewModel.isValid == false)
    }
    
    @Test("ViewModel pre-fills when editing")
    func testInitializationWithExistingWorkflow() {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(
            name: "Test Workflow",
            workflowDescription: "Test Description"
        )
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let viewModel = WorkflowCreationViewModel(
            repository: repository,
            existingWorkflow: workflow
        )
        
        #expect(viewModel.name == "Test Workflow")
        #expect(viewModel.workflowDescription == "Test Description")
        #expect(viewModel.steps.count == 1)
    }
    
    @Test("Add step appends to list")
    func testAddStep() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        #expect(viewModel.steps.count == 1)
        #expect(viewModel.steps[0].order == 0)
    }
    
    @Test("Delete step removes from list and reorders")
    func testDeleteStep() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        let step1 = WorkflowStep(stepType: "summarize", prompt: "First", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Second", order: 1)
        let step3 = WorkflowStep(stepType: "analyze", prompt: "Third", order: 2)
        
        viewModel.addStep(step1)
        viewModel.addStep(step2)
        viewModel.addStep(step3)
        
        #expect(viewModel.steps.count == 3)
        
        viewModel.deleteStep(at: 1)
        
        #expect(viewModel.steps.count == 2)
        #expect(viewModel.steps[0].prompt == "First")
        #expect(viewModel.steps[1].prompt == "Third")
        #expect(viewModel.steps[1].order == 1) // Reordered
    }
    
    @Test("Move step reorders correctly")
    func testMoveStep() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        let step1 = WorkflowStep(stepType: "summarize", prompt: "First", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Second", order: 1)
        let step3 = WorkflowStep(stepType: "analyze", prompt: "Third", order: 2)
        
        viewModel.addStep(step1)
        viewModel.addStep(step2)
        viewModel.addStep(step3)
        
        viewModel.moveStep(from: 2, to: 0)
        
        #expect(viewModel.steps[0].prompt == "Third")
        #expect(viewModel.steps[1].prompt == "First")
        #expect(viewModel.steps[2].prompt == "Second")
        #expect(viewModel.steps[0].order == 0)
        #expect(viewModel.steps[1].order == 1)
        #expect(viewModel.steps[2].order == 2)
    }
    
    @Test("Duplicate step creates copy")
    func testDuplicateStep() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        let step = WorkflowStep(stepType: "summarize", prompt: "Original", order: 0)
        viewModel.addStep(step)
        
        viewModel.duplicateStep(at: 0)
        
        #expect(viewModel.steps.count == 2)
        #expect(viewModel.steps[0].prompt == "Original")
        #expect(viewModel.steps[1].prompt == "Original")
        #expect(viewModel.steps[1].order == 1)
    }
    
    @Test("Validation fails for empty name")
    func testValidationEmptyName() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        viewModel.name = ""
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        let isValid = viewModel.validate()
        
        #expect(isValid == false)
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Validation fails for short name")
    func testValidationShortName() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        viewModel.name = "ab"
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        let isValid = viewModel.validate()
        
        #expect(isValid == false)
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Validation fails for no steps")
    func testValidationNoSteps() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        viewModel.name = "Valid Name"
        
        let isValid = viewModel.validate()
        
        #expect(isValid == false)
        #expect(viewModel.validationError != nil)
    }
    
    @Test("Validation succeeds for valid workflow")
    func testValidationSuccess() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        viewModel.name = "Valid Name"
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        let isValid = viewModel.validate()
        
        #expect(isValid == true)
        #expect(viewModel.validationError == nil)
    }
    
    @Test("Save workflow creates new workflow")
    func testSaveNewWorkflow() async {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        viewModel.name = "New Workflow"
        viewModel.workflowDescription = "Description"
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        let success = await viewModel.saveWorkflow()
        
        #expect(success == true)
        #expect(repository.saveCalled)
        #expect(repository.workflows.count == 1)
        #expect(repository.workflows[0].name == "New Workflow")
        #expect(repository.workflows[0].steps.count == 1)
    }
    
    @Test("Save workflow updates existing workflow")
    func testSaveExistingWorkflow() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Original Name")
        repository.workflows = [workflow]
        
        let viewModel = WorkflowCreationViewModel(
            repository: repository,
            existingWorkflow: workflow
        )
        
        viewModel.name = "Updated Name"
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        let success = await viewModel.saveWorkflow()
        
        #expect(success == true)
        #expect(repository.workflows[0].name == "Updated Name")
        #expect(repository.workflows[0].steps.count == 1)
    }
    
    @Test("Save workflow handles errors")
    func testSaveWorkflowError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        
        let viewModel = WorkflowCreationViewModel(repository: repository)
        viewModel.name = "Test"
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        
        let success = await viewModel.saveWorkflow()
        
        #expect(success == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("isValid property reflects validation state")
    func testIsValidProperty() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowCreationViewModel(repository: repository)
        
        #expect(viewModel.isValid == false)
        
        viewModel.name = "Test"
        #expect(viewModel.isValid == false)
        
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        viewModel.addStep(step)
        #expect(viewModel.isValid == true)
        
        viewModel.name = ""
        #expect(viewModel.isValid == false)
    }
}
