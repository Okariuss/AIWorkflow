//
//  DependencyContainer.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    static let shared = DependencyContainer()
    
    // MARK: - Properties
    
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    // MARK: - Repositories

    lazy var workflowRepository: WorkflowRepositoryProtocol = {
        WorkflowRepository(modelContext: modelContext)
    }()
    
    lazy var executionHistoryRepository: ExecutionHistoryRepositoryProtocol = {
        ExecutionHistoryRepository(modelContext: modelContext)
    }()
    
    lazy var preferencesRepository: PreferencesRepositoryProtocol = {
        PreferencesRepository(modelContext: modelContext)
    }()
    
    // MARK: - Services

    lazy var aiService: AIServiceProtocol = {
        FoundationModelsService.shared
    }()
    
    lazy var workflowExecutionEngine: WorkflowExecutionEngineProtocol = {
        WorkflowExecutionEngine(aiService: aiService)
    }()
    
    lazy var workflowExecutionService: WorkflowExecutionService = {
        WorkflowExecutionService(
            executionEngine: workflowExecutionEngine,
            historyRepository: executionHistoryRepository
        )
    }()
    
    lazy var widgetService: WidgetServiceProtocol = {
        WidgetService(
            workflowRepository: workflowRepository,
            preferencesRepository: preferencesRepository
        )
    }()
    
    // MARK: - Initialization
    
    private init() {
        do {
            let schema = Schema([
                Workflow.self,
                WorkflowStep.self,
                ExecutionHistory.self,
                UserPreferences.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            self.modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}

// MARK: - Public Access
extension DependencyContainer {
    var container: ModelContainer {
        modelContainer
    }
    
    var context: ModelContext {
        modelContext
    }
}

// MARK: - ViewModels
extension DependencyContainer {
    func makeWorkflowListViewModel() -> WorkflowListViewModel {
        WorkflowListViewModel(
            repository: workflowRepository,
            widgetService: widgetService
        )
    }
    
    func makeWorkflowCreationViewModel(existingWorkflow: Workflow? = nil) -> WorkflowCreationViewModel {
        WorkflowCreationViewModel(
            repository: workflowRepository,
            existingWorkflow: existingWorkflow
        )
    }
    
    func makeWorkflowDetailViewModel(workflow: Workflow) -> WorkflowDetailViewModel {
        WorkflowDetailViewModel(
            workflow: workflow,
            repository: workflowRepository
        )
    }
    
    func makeWorkflowExecutionViewModel(workflow: Workflow) -> WorkflowExecutionViewModel {
        WorkflowExecutionViewModel(
            workflow: workflow,
            executionService: workflowExecutionService
        )
    }
    
    func makeExecutionHistoryViewModel() -> ExecutionHistoryViewModel {
        ExecutionHistoryViewModel(repository: executionHistoryRepository)
    }
    
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            repository: preferencesRepository,
            workflowRepository: workflowRepository,
            widgetService: widgetService
        )
    }
}

// MARK: - Testing Support
extension DependencyContainer {
    static func createTestContainer() -> DependencyContainer? {
        // Placeholder for now
        nil
    }
}
