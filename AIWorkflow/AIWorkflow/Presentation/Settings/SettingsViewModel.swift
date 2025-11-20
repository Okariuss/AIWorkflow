//
//  SettingsViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import Foundation
import FoundationModels
import WidgetKit
import Intents

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Published State
    private(set) var preferences: UserPreferences?
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // AI Service Status
    private(set) var isAIAvailable = false
    private(set) var aiAvailability: SystemLanguageModel.Availability = .unavailable(.deviceNotEligible)
    
    var currentTheme: UserPreferences.ThemePreference {
        preferences?.theme ?? .system
    }
    
    var widgetSelections: [UUID] {
        preferences?.widgetSelections ?? []
    }
    
    // MARK: - Dependencies
    private let repository: PreferencesRepositoryProtocol
    private let workflowRepository: WorkflowRepositoryProtocol
    private let aiService: FoundationModelsService
    private let widgetService: WidgetServiceProtocol
    
    // MARK: - Init
    init(
        repository: PreferencesRepositoryProtocol,
        workflowRepository: WorkflowRepositoryProtocol,
        widgetService: WidgetServiceProtocol,
        aiService: FoundationModelsService? = nil
    ) {
        self.repository = repository
        self.workflowRepository = workflowRepository
        self.widgetService = widgetService
        self.aiService = aiService ?? .shared
    }
}

// MARK: - Public Methods
extension SettingsViewModel {
    func loadPreferences() async {
        isLoading = true
        errorMessage = nil
        
        do {
            preferences = try await repository.getOrCreate()
            await checkAIAvailability()
        } catch {
            errorMessage = "Failed to load preferences: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func checkAIAvailability() async {
        isAIAvailable = await aiService.isAvailable()
        aiAvailability = aiService.availabilityDetails()
    }
    
    func updateTheme(_ theme: UserPreferences.ThemePreference) async {
        guard let prefs = preferences else { return }
        
        let oldTheme = prefs.theme
        prefs.setTheme(theme)
        
        do {
            try await repository.save(prefs)
        } catch {
            prefs.setTheme(oldTheme) // Revert
            errorMessage = "Failed to update theme: \(error.localizedDescription)"
        }
    }
    
    func setDefaultWorkflow(_ workflowId: UUID?) async {
        guard let prefs = preferences else { return }
        
        prefs.defaultWorkflowId = workflowId
        prefs.modifiedAt = Date()
        
        do {
            try await repository.save(prefs)
        } catch {
            errorMessage = "Failed to set default workflow: \(error.localizedDescription)"
        }
    }
    
    func addWidgetSelected(_ workflowId: UUID) async {
        guard let prefs = preferences else {
            errorMessage = "Preferences not loaded"
            return
        }
        
        if prefs.widgetSelections.count >= 4 {
            errorMessage = "Widget can only show 4 workflows maximum"
            return
        }
        
        do {
            prefs.addWidgetSelection(workflowId)
            try await repository.save(prefs)
            
            await widgetService.refreshWidgets()
            
        } catch {
            errorMessage = "Failed to add widget favorite: \(error.localizedDescription)"
        }
    }
    
    func removeWidgetSelected(_ workflowId: UUID) async {
        guard let prefs = preferences else {
            errorMessage = "Preferences not loaded"
            return
        }
        
        do {
            prefs.removeWidgetSelection(workflowId)
            try await repository.save(prefs)
            
            await widgetService.refreshWidgets()
            
        } catch {
            errorMessage = "Failed to remove widget favorite: \(error.localizedDescription)"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
