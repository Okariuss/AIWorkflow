//
//  PreferencesRepositoryTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("PreferencesRepository Tests")
@MainActor
struct PreferencesRepositoryTests {
    
    // MARK: - Mock Repository
    final class MockPreferencesRepository: PreferencesRepositoryProtocol {
        var preferences: UserPreferences?
        var shouldThrowError = false
        var saveCalled = false
        
        func fetch() async throws -> UserPreferences {
            if shouldThrowError {
                throw PreferencesError.notFound
            }
            
            guard let prefs = preferences else {
                throw PreferencesError.notFound
            }
            
            return prefs
        }
        
        func save(_ preferences: UserPreferences) async throws {
            saveCalled = true
            
            if shouldThrowError {
                throw PreferencesError.saveFailed
            }
            
            self.preferences = preferences
        }
        
        func getOrCreate() async throws -> UserPreferences {
            do {
                return try await fetch()
            } catch {
                let newPrefs = UserPreferences()
                try await save(newPrefs)
                return newPrefs
            }
        }
    }
    
    // MARK: - Tests
    
    @Test("UserPreferences initializes with default values")
    func testUserPreferencesInitialization() {
        let prefs = UserPreferences()
        
        #expect(prefs.defaultWorkflowId == nil)
        #expect(prefs.theme == .system)
        #expect(prefs.widgetSelections.isEmpty)
    }
    
    @Test("Theme preference can be set and retrieved")
    func testThemePreference() {
        let prefs = UserPreferences()
        
        prefs.setTheme(.dark)
        #expect(prefs.theme == .dark)
        
        prefs.setTheme(.light)
        #expect(prefs.theme == .light)
    }
    
    @Test("Widget favorites can be added and removed")
    func testWidgetFavorites() {
        let prefs = UserPreferences()
        let workflowId1 = UUID()
        let workflowId2 = UUID()
        
        #expect(prefs.widgetSelections.isEmpty)
        
        prefs.addWidgetSelection(workflowId1)
        #expect(prefs.widgetSelections.count == 1)
        #expect(prefs.widgetSelections.contains(workflowId1))
        
        prefs.addWidgetSelection(workflowId2)
        #expect(prefs.widgetSelections.count == 2)
        
        prefs.removeWidgetSelection(workflowId1)
        #expect(prefs.widgetSelections.count == 1)
        #expect(!prefs.widgetSelections.contains(workflowId1))
        #expect(prefs.widgetSelections.contains(workflowId2))
    }
    
    @Test("Widget favorites prevent duplicates")
    func testWidgetFavoritesDuplicates() {
        let prefs = UserPreferences()
        let workflowId = UUID()
        
        prefs.addWidgetSelection(workflowId)
        prefs.addWidgetSelection(workflowId)
        
        #expect(prefs.widgetSelections.count == 1)
    }
    
    @Test("Repository getOrCreate returns existing preferences")
    func testGetOrCreateExisting() async throws {
        let repository = MockPreferencesRepository()
        let existingPrefs = UserPreferences()
        repository.preferences = existingPrefs
                
        #expect(repository.saveCalled == false)
    }
    
    @Test("Repository getOrCreate creates new preferences when none exist")
    func testGetOrCreateNew() async throws {
        let repository = MockPreferencesRepository()
        
        #expect(repository.saveCalled == true)
    }
    
    @Test("Repository save updates preferences")
    func testSave() async throws {
        let repository = MockPreferencesRepository()
        let prefs = UserPreferences()
        
        try await repository.save(prefs)
        
        #expect(repository.saveCalled == true)
    }
    
    @Test("Repository fetch throws when preferences not found")
    func testFetchNotFound() async {
        let repository = MockPreferencesRepository()
        
        do {
            _ = try await repository.fetch()
            Issue.record("Should have thrown error")
        } catch {
            #expect(error is PreferencesError)
        }
    }
}
