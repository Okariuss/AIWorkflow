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
        var fetchAllCalled = false
        var saveCalled = false
        var deleteCalled = false
        
        func fetchAll() async throws -> [Workflow] {
            fetchAllCalled = true
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
        
        #expect(viewModel.workflows.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.searchQuery == "")
    }
    
    @Test("Load workflows succeeds")
    func testLoadWorkflowsSuccess() async {
        let repository = MockWorkflowRepository()
        let workflow1 = Workflow(name: "Workflow 1")
        let workflow2 = Workflow(name: "Workflow 2")
        repository.workflows = [workflow1, workflow2]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.loadWorkflows()
        
        #expect(repository.fetchAllCalled)
        #expect(viewModel.workflows.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test("Load workflows handles error")
    func testLoadWorkflowsError() async {
        let repository = MockWorkflowRepository()
        repository.shouldThrowError = true
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.loadWorkflows()
        
        #expect(viewModel.workflows.isEmpty)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test("Delete workflows succeeds")
    func testDeleteWorkflowsSuccess() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Workflow 1")
        repository.workflows = [workflow]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.loadWorkflows()
        
        #expect(viewModel.workflows.count == 1)
        
        await viewModel.deleteWorkflow(workflow)
        
        #expect(repository.deleteCalled)
        #expect(viewModel.workflows.isEmpty)
    }
    
    @Test("Toggle favorite updates workflow")
    func testToggleFavorite() async {
        let repository = MockWorkflowRepository()
        let workflow = Workflow(name: "Workflow 1")
        workflow.isFavorite = false
        repository.workflows = [workflow]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.loadWorkflows()
        
        await viewModel.toggleFavorite(workflow)
        #expect(repository.saveCalled)
        #expect(workflow.isFavorite == true)
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
    
    @Test("Search filters workflows by name")
    func testSearchWorkflows() async {
        let repository = MockWorkflowRepository()
        let workflow1 = Workflow(name: "Summarize Text")
        let workflow2 = Workflow(name: "Translate Document")
        repository.workflows = [workflow1, workflow2]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        viewModel.searchQuery = "summarize"
        
        try? await Task.sleep(for: .milliseconds(100))
        
        #expect(viewModel.workflows.count == 1)
        #expect(viewModel.workflows.first?.name == "Summarize Text")
    }
    
    @Test("Sort by name orders alphabetically")
    func testSortByName() async {
        let repository = MockWorkflowRepository()
        let workflow1 = Workflow(name: "Zebra")
        let workflow2 = Workflow(name: "Apple")
        let workflow3 = Workflow(name: "Mango")
        repository.workflows = [workflow1, workflow2, workflow3]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        await viewModel.loadWorkflows()
        
        viewModel.sortOption = .name
        
        #expect(viewModel.workflows[0].name == "Apple")
        #expect(viewModel.workflows[1].name == "Mango")
        #expect(viewModel.workflows[2].name == "Zebra")
    }
    
    @Test("Filter favorites shows only favorites")
    func testFilterFavorites() async {
        let repository = MockWorkflowRepository()
        let workflow1 = Workflow(name: "Test 1")
        workflow1.isFavorite = true
        let workflow2 = Workflow(name: "Test 2")
        workflow2.isFavorite = false
        repository.workflows = [workflow1, workflow2]
        
        let viewModel = WorkflowListViewModel(repository: repository)
        viewModel.filterOption = .favorites
        await viewModel.loadWorkflows()
        
        #expect(viewModel.workflows.count == 1)
        #expect(viewModel.workflows.first?.name == "Test 1")
    }
}
