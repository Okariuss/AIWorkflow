//
//  SettingsViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("SettingsViewModel Tests")
@MainActor
struct SettingsViewModelTests {
    
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

    // MARK: - Mock Widget Service
    @MainActor
    final class MockWidgetService: WidgetServiceProtocol {
        var refreshCalled = false
        func refreshWidgets() async {
            refreshCalled = true
        }
    }
    
    // MARK: - Tests
    
    @Test("loadPreferences loads and checks AI availability")
    func testLoadPreferences() async {
        let prefsRepo = MockPreferencesRepository()
        let workflowRepo = MockWorkflowRepository()
        let widgetService = MockWidgetService()
        let aiService = FoundationModelsService.shared
        
        let prefs = UserPreferences()
        prefsRepo.stored = prefs
        
        let vm = SettingsViewModel(
            repository: prefsRepo,
            workflowRepository: workflowRepo,
            widgetService: widgetService,
            aiService: aiService
        )
        
        await vm.loadPreferences()
        
        #expect(vm.preferences != nil)
        #expect(vm.isAIAvailable == true)
    }
    
    @Test("addWidgetSelected respects limit 4")
    func testAddWidgetLimit() async {
        let prefsRepo = MockPreferencesRepository()
        let prefs = UserPreferences()
        prefs.setWidgetSelections([UUID(), UUID(), UUID(), UUID()])
        prefsRepo.stored = prefs
        
        let vm = SettingsViewModel(
            repository: prefsRepo,
            workflowRepository: MockWorkflowRepository(),
            widgetService: MockWidgetService(),
            aiService: FoundationModelsService.shared
        )
        
        await vm.loadPreferences()
        await vm.addWidgetSelected(UUID())
        
        #expect(vm.errorMessage != nil)
    }
    
    @Test("removeWidgetSelected triggers widget refresh")
    func testRemoveWidgetSelected() async {
        let prefsRepo = MockPreferencesRepository()
        let id = UUID()
        let prefs = UserPreferences()
        prefs.setWidgetSelections([id])
        prefsRepo.stored = prefs
        
        let widgetService = MockWidgetService()
        
        let vm = SettingsViewModel(
            repository: prefsRepo,
            workflowRepository: MockWorkflowRepository(),
            widgetService: widgetService,
            aiService: FoundationModelsService.shared
        )
        
        await vm.loadPreferences()
        await vm.removeWidgetSelected(id)
        
        #expect(widgetService.refreshCalled == true)
    }
}
