//
//  WorkflowRepository.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation
import SwiftData

final class WorkflowRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - Protocol Implementation
@MainActor
extension WorkflowRepository: WorkflowRepositoryProtocol {
    func fetchAll() async throws -> [Workflow] {
        let descriptor = FetchDescriptor<Workflow>(
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetch(by id: UUID) async throws -> Workflow? {
        let descriptor = FetchDescriptor<Workflow>(
            predicate: #Predicate { workflow in
                workflow.id == id
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func save(_ workflow: Workflow) async throws {
        workflow.modifiedAt = Date()
        modelContext.insert(workflow)
        try modelContext.save()
    }
    
    func delete(_ workflow: Workflow) async throws {
        modelContext.delete(workflow)
        try modelContext.save()
    }
    
    func fetchFavorites() async throws -> [Workflow] {
        let descriptor = FetchDescriptor<Workflow>(
            predicate: #Predicate { workflow in
                workflow.isFavorite == true
            },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func search(query: String) async throws -> [Workflow] {
        let descriptor = FetchDescriptor<Workflow>(
            predicate: #Predicate { workflow in
                workflow.name.localizedStandardContains(query)
            },
            sortBy: [SortDescriptor(\.modifiedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
}
