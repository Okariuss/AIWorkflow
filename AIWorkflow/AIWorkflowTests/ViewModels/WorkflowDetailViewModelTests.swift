//
//  WorkflowDetailViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowDetailViewModel Tests")
@MainActor
struct WorkflowDetailViewModelTests {
    
    // MARK: - Mock Repository
    final class MockWorkflowRepository: WorkflowRepositoryProtocol {
        var workflows: [Workflow] = []
        var shouldThrowError = false
        var saveCalled = false
        var deleteCalled = false
        
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
            deleteCalled = true
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            workflows.removeAll { $0.id == workflow.id }
        }
        
        func fetchFavorites() async throws -> [Workflow] {
            workflows.filter { $0.isFavorite }
        }
        
        func search(query: String) async throws -> [Workflow] {
            workflows.filter { $0.name.localizedStandardContains(query) }
        }
    }
    
    // MARK: - Tests
    @Test("ViewModel initializes with workflow")
    func testInitialization() {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        
        #expect(viewModel.workflow.name == "Test")
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.wasDeleted == false)
        #expect(viewModel.isLoading == false)
    }
    
    @Test("canRun is true when workflow has steps")
    func testCanRunWithSteps() {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        
        #expect(viewModel.canRun == true)
    }
    
    @Test("canRun is false when workflow has no steps")
    func testCanRunWithoutSteps() {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        
        #expect(viewModel.canRun == false)
    }
    
    @Test("Toggle favorite succeeds")
    func testToggleFavoriteSuccess() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        workflow.isFavorite = false
        repository.workflows = [workflow]
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        await viewModel.toggleFavorite()
        
        #expect(workflow.isFavorite == true)
        #expect(repository.saveCalled)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Toggle favorite reverts on error")
    func testToggleFavoriteError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        let workflow = Workflow(name: "Test")
        workflow.isFavorite = false
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        await viewModel.toggleFavorite()
        
        #expect(workflow.isFavorite == false) // Reverted
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Delete workflow succeeds")
    func testDeleteWorkflowSuccess() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        repository.workflows = [workflow]
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        await viewModel.deleteWorkflow()
        
        #expect(repository.deleteCalled)
        #expect(viewModel.wasDeleted == true)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Delete workflow handles error")
    func testDeleteWorkflowError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        let workflow = Workflow(name: "Test")
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        await viewModel.deleteWorkflow()
        
        #expect(viewModel.wasDeleted == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Duplicate workflow creates copy with steps")
    func testDuplicateWorkflowSuccess() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(
            name: "Original",
            workflowDescription: "Description"
        )
        let step1 = WorkflowStep(stepType: "summarize", prompt: "Test 1", order: 0)
        let step2 = WorkflowStep(stepType: "translate", prompt: "Test 2", order: 1)
        step1.workflow = workflow
        step2.workflow = workflow
        workflow.steps = [step1, step2]
        repository.workflows = [workflow]
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        let duplicated = await viewModel.duplicateWorkflow()
        
        #expect(duplicated != nil)
        #expect(duplicated?.name == "Original (Copy)")
        #expect(duplicated?.workflowDescription == "Description")
        #expect(duplicated?.steps.count == 2)
        #expect(duplicated?.isFavorite == false)
        #expect(repository.saveCalled)
    }
    
    @Test("Duplicate workflow handles error")
    func testDuplicateWorkflowError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        let workflow = Workflow(name: "Test")
        
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        let duplicated = await viewModel.duplicateWorkflow()
        
        #expect(duplicated == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Date formatting returns valid strings")
    func testDateFormatting() {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        let viewModel = WorkflowDetailViewModel(workflow: workflow, repository: repository)
        
        #expect(!viewModel.createdDateFormatted.isEmpty)
        #expect(!viewModel.modifiedDateFormatted.isEmpty)
        #expect(!viewModel.modifiedDateRelative.isEmpty)
    }
}
