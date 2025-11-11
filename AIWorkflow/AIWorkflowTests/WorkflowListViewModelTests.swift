//
//  WorkflowListViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WorkflowListViewModel Tests")
@MainActor
struct WorkflowListViewModelTests {
    
    // MARK: - Mock Repository
    final class MockWorkflowRepository: WorkflowRepositoryProtocol {
        var workflows: [Workflow] = []
        var shouldThrowError = false
        var saveCalled = false
        var deleteCalled = false
        
        func fetchAll() async throws -> [Workflow] {
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            return workflows
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
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            return workflows.filter { $0.isFavorite }
        }
        
        func search(query: String) async throws -> [Workflow] {
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            return workflows.filter { $0.name.localizedStandardContains(query) }
        }
    }
    
    @Test("ViewModel initializes with empty state")
    func testInitialization() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowListViewModel(repository: repository)
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.searchQuery == "")
    }
    
    @Test("Delete workflow succeeds")
    func testDeleteWorkflowSuccess() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        repository.workflows = [workflow]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.deleteWorkflow(workflow)
        
        #expect(repository.deleteCalled)
        #expect(repository.workflows.isEmpty)
    }
    
    @Test("Delete workflow handles error")
    func testDeleteWorkflowError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        let workflow = Workflow(name: "Test")
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.deleteWorkflow(workflow)
        
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Toggle favorite updates workflow")
    func testToggleFavorite() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Test")
        workflow.isFavorite = false
        repository.workflows = [workflow]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.toggleFavorite(workflow)
        
        #expect(repository.saveCalled)
        #expect(workflow.isFavorite == true)
    }
    
    @Test("Toggle favorite reverts on error")
    func testToggleFavoriteError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        let workflow = Workflow(name: "Test")
        workflow.isFavorite = false
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.toggleFavorite(workflow)
        
        #expect(workflow.isFavorite == false) // Reverted
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Duplicate workflow creates copy")
    func testDuplicateWorkflow() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Original")
        let step = WorkflowStep(stepType: "summarize", prompt: "Test", order: 0)
        step.workflow = workflow
        workflow.steps = [step]
        repository.workflows = [workflow]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.duplicateWorkflows(workflow)
        
        #expect(repository.saveCalled)
        #expect(repository.workflows.count == 2)
        #expect(repository.workflows[1].name.contains("Copy"))
        #expect(repository.workflows[1].steps.count == 1)
    }
    
    @Test("Filter workflows by favorites")
    func testFilterFavorites() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowListViewModel(repository: repository)
        
        let workflow1 = Workflow(name: "Test 1")
        workflow1.isFavorite = true
        let workflow2 = Workflow(name: "Test 2")
        workflow2.isFavorite = false
        let allWorkflows = [workflow1, workflow2]
        
        viewModel.filterOption = .favorites
        let filtered = viewModel.filterWorkflows(allWorkflows)
        
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Test 1")
    }
    
    @Test("Filter workflows by search query")
    func testFilterBySearch() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowListViewModel(repository: repository)
        
        let workflow1 = Workflow(name: "Summarize Text")
        let workflow2 = Workflow(name: "Translate Document")
        let allWorkflows = [workflow1, workflow2]
        
        viewModel.searchQuery = "Summarize"
        let filtered = viewModel.filterWorkflows(allWorkflows)
        
        #expect(filtered.count == 1)
        #expect(filtered.first?.name == "Summarize Text")
    }
    
    @Test("Sort workflows by name")
    func testSortByName() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowListViewModel(repository: repository)
        
        let workflow1 = Workflow(name: "Zebra")
        let workflow2 = Workflow(name: "Apple")
        let workflow3 = Workflow(name: "Mango")
        let allWorkflows = [workflow1, workflow2, workflow3]
        
        viewModel.sortOption = .name
        let sorted = viewModel.sortWorkflows(allWorkflows)
        
        #expect(sorted[0].name == "Apple")
        #expect(sorted[1].name == "Mango")
        #expect(sorted[2].name == "Zebra")
    }
    
    @Test("Sort workflows by step count")
    func testSortByStepCount() {
        let repository = MockWorkflowRepository()
        let viewModel = WorkflowListViewModel(repository: repository)
        
        let workflow1 = Workflow(name: "One")
        workflow1.steps = [WorkflowStep(stepType: "test", prompt: "test", order: 0)]
        
        let workflow2 = Workflow(name: "Three")
        workflow2.steps = [
            WorkflowStep(stepType: "test", prompt: "test", order: 0),
            WorkflowStep(stepType: "test", prompt: "test", order: 1),
            WorkflowStep(stepType: "test", prompt: "test", order: 2)
        ]
        
        let workflow3 = Workflow(name: "Two")
        workflow3.steps = [
            WorkflowStep(stepType: "test", prompt: "test", order: 0),
            WorkflowStep(stepType: "test", prompt: "test", order: 1)
        ]
        
        let allWorkflows = [workflow1, workflow2, workflow3]
        
        viewModel.sortOption = .stepCount
        let sorted = viewModel.sortWorkflows(allWorkflows)
        
        #expect(sorted[0].stepCount == 3)
        #expect(sorted[1].stepCount == 2)
        #expect(sorted[2].stepCount == 1)
    }
}
