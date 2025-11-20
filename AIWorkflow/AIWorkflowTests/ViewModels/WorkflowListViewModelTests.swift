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
    
    // MARK: - Mock Workflow Repository
    @MainActor
    final class MockWorkflowRepository: WorkflowRepositoryProtocol {
        var workflows: [Workflow] = []
        var fetchAllCalled = false
        var saveCalled = false
        var deleteCalled = false
        
        func fetchAll() async throws -> [Workflow] {
            fetchAllCalled = true
            return workflows
        }
        
        func fetch(by id: UUID) async throws -> Workflow? {
            workflows.first(where: { $0.id == id })
        }
        
        func save(_ workflow: Workflow) async throws {
            saveCalled = true
            if !workflows.contains(where: { $0.id == workflow.id }) {
                workflows.append(workflow)
            }
        }
        
        func delete(_ workflow: Workflow) async throws {
            deleteCalled = true
            workflows.removeAll(where: { $0.id == workflow.id })
        }
        
        func fetchFavorites() async throws -> [Workflow] {
            workflows.filter { $0.isFavorite }
        }
        
        func search(query: String) async throws -> [Workflow] {
            workflows.filter { $0.name.contains(query) }
        }
    }
    
    // MARK: - Mock Widget Service
    @MainActor
    final class MockWidgetService: WidgetServiceProtocol {
        var refreshCalled = false
        func refreshWidgets() async {
            refreshCalled = true
        }
    }
    
    // MARK: - Tests
    @Test("toggleFavorite saves and refreshes widgets")
    func testToggleFavorite() async {
        let repo = MockWorkflowRepository()
        let widget = MockWidgetService()

        let wf = Workflow(name: "Test", workflowDescription: "", isFavorite: false)
        repo.workflows = [wf]

        let vm = WorkflowListViewModel(
            repository: repo,
            widgetService: widget
        )

        await vm.toggleFavorite(wf)

        #expect(repo.saveCalled == true)
        #expect(widget.refreshCalled == true)
        #expect(wf.isFavorite == true)
    }

    @Test("duplicateWorkflow creates a new workflow")
    func testDuplicate() async {
        let repo = MockWorkflowRepository()
        
        let original = Workflow(name: "X", workflowDescription: "", isFavorite: false)
        let step = WorkflowStep(stepType: "summarize", prompt: "Prompt", order: 1)
        step.workflow = original
        original.steps.append(step)
        
        repo.workflows = [original]

        let vm = WorkflowListViewModel(
            repository: repo,
            widgetService: MockWidgetService()
        )

        await vm.duplicateWorkflows(original)

        #expect(repo.workflows.count == 2)
        #expect(repo.workflows[1].steps.count == 1)
        #expect(repo.workflows[1].name.contains("Copy"))
    }

    @Test("filterWorkflows respects search and favorites")
    func testFilterWorkflows() {
        let repo = MockWorkflowRepository()
        let vm = WorkflowListViewModel(
            repository: repo,
            widgetService: MockWidgetService()
        )
        
        let wf1 = Workflow(name: "Apple", workflowDescription: "", isFavorite: true)
        let wf2 = Workflow(name: "Banana", workflowDescription: "", isFavorite: false)

        vm.filterOption = .favorites
        let filtered = vm.filterWorkflows([wf1, wf2])

        #expect(filtered.count == 1)
        #expect(filtered[0].name == "Apple")
    }
}
