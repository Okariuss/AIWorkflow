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
    
    
    // MARK: - Initialization
    
    private init() {
        do {
            let schema = Schema([
                Workflow.self,
                WorkflowStep.self,
                ExecutionHistory.self
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

// MARK: - Testing Support
extension DependencyContainer {
    static func createTestContainer() -> DependencyContainer? {
        // Placeholder for now
        nil
    }
}
