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
            errorMessage = "\(L10N.Error.preferencesFailed): \(error.localizedDescription)"
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
            UserDefaults.standard.set(theme.rawValue, forKey: "appThemePreference")
        } catch {
            prefs.setTheme(oldTheme) // Revert
            errorMessage = "\(L10N.Error.themeUpdateFailed): \(error.localizedDescription)"
        }
    }
    
    func setDefaultWorkflow(_ workflowId: UUID?) async {
        guard let prefs = preferences else { return }
        
        prefs.defaultWorkflowId = workflowId
        prefs.modifiedAt = Date()
        
        do {
            try await repository.save(prefs)
        } catch {
            errorMessage = "\(L10N.Error.workflowSetFailed): \(error.localizedDescription)"
        }
    }
    
    func addWidgetSelected(_ workflowId: UUID) async {
        guard let prefs = preferences else {
            errorMessage = L10N.Error.preferencesFailed
            return
        }
        
        if prefs.widgetSelections.count >= 4 {
            errorMessage = L10N.WidgetPreferences.limitReached
            return
        }
        
        do {
            prefs.addWidgetSelection(workflowId)
            try await repository.save(prefs)
            
            await widgetService.refreshWidgets()
            
        } catch {
            errorMessage = "\(L10N.Error.widgetAddFailed): \(error.localizedDescription)"
        }
    }
    
    func removeWidgetSelected(_ workflowId: UUID) async {
        guard let prefs = preferences else {
            errorMessage = L10N.Error.preferencesFailed
            return
        }
        
        do {
            prefs.removeWidgetSelection(workflowId)
            try await repository.save(prefs)
            
            await widgetService.refreshWidgets()
            
        } catch {
            errorMessage = "\(L10N.Error.widgetRemoveFailed): \(error.localizedDescription)"
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
