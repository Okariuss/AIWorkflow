//
//  WidgetServiceTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 20.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("WidgetService Tests")
@MainActor
struct WidgetServiceTests {
    
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
    
    // MARK: - Mock Preferences Repository
    @MainActor
    final class MockPreferencesRepository: PreferencesRepositoryProtocol {

        var stored: UserPreferences?
        var fetchCalled = false
        var saveCalled = false
        var getOrCreateCalled = false
        
        func fetch() async throws -> UserPreferences {
            fetchCalled = true
            guard let stored else { throw PreferencesError.notFound }
            return stored
        }
        
        func save(_ preferences: UserPreferences) async throws {
            saveCalled = true
            stored = preferences
        }
        
        func getOrCreate() async throws -> UserPreferences {
            getOrCreateCalled = true
            if let stored { return stored }
            let new = UserPreferences()
            stored = new
            return new
        }
    }
    
    // MARK: - Tests
    @Test("refreshWidgets writes correct workflows")
    func testRefreshWidgets() async throws {

        let workflowRepo = MockWorkflowRepository()
        let prefsRepo = MockPreferencesRepository()

        workflowRepo.workflows = (1...5).map { i in
            Workflow(name: "WF\(i)", workflowDescription: "Desc", isFavorite: false)
        }

        let service = WidgetService(
            workflowRepository: workflowRepo,
            preferencesRepository: prefsRepo
        )

        await service.refreshWidgets()

        let defaults = UserDefaults(suiteName: "group.com.okarius.AIWorkflow")
        let data = defaults?.data(forKey: "workflows")
        #expect(data != nil)

        let decoded = try JSONDecoder().decode([WorkflowWidgetData].self, from: data!)
        #expect(decoded.count == 4)
        #expect(decoded[0].name == "WF1")
    }

    @Test("refreshWidgets respects selected workflowIds")
    func testRefreshWidgetsUsesSelected() async throws {

        let workflowRepo = MockWorkflowRepository()
        let prefsRepo = MockPreferencesRepository()
        let selectedId = UUID()

        workflowRepo.workflows = [
            Workflow(id: selectedId, name: "Sel", workflowDescription: "", isFavorite: false),
            Workflow(name: "Other", workflowDescription: "", isFavorite: false)
        ]

        let prefs = UserPreferences()
        prefs.setWidgetSelections([selectedId])
        prefsRepo.stored = prefs
        
        let service = WidgetService(
            workflowRepository: workflowRepo,
            preferencesRepository: prefsRepo
        )

        await service.refreshWidgets()

        let defaults = UserDefaults(suiteName: "group.com.okarius.AIWorkflow")
        let data = defaults?.data(forKey: "workflows")

        let decoded = try JSONDecoder().decode([WorkflowWidgetData].self, from: data!)
        #expect(decoded.count == 1)
        #expect(decoded[0].id == selectedId)
    }
}
