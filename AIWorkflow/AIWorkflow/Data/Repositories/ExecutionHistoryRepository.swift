//
//  ExecutionHistoryRepository.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation
import SwiftData

final class ExecutionHistoryRepository {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - Protocol Integration
@MainActor
extension ExecutionHistoryRepository: ExecutionHistoryRepositoryProtocol {
    func fetchAll() async throws -> [ExecutionHistory] {
        let descriptor = FetchDescriptor<ExecutionHistory>(
            sortBy: [SortDescriptor(\.executedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func fetch(for workflowId: UUID) async throws -> [ExecutionHistory] {
        let descriptor = FetchDescriptor<ExecutionHistory>(
            predicate: #Predicate{ history in
                history.workflowId == workflowId
            },
            sortBy: [SortDescriptor(\.executedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    func save(_ history: ExecutionHistory) async throws {
        modelContext.insert(history)
        try modelContext.save()
    }
    
    func delete(_ history: ExecutionHistory) async throws {
        modelContext.delete(history)
        try modelContext.save()
    }
    
    func deleteAll() async throws {
        let allHistory = try await fetchAll()
        allHistory.forEach(modelContext.delete)
        try modelContext.save()
    }
    
    func fetchRecent(limit: Int) async throws -> [ExecutionHistory] {
        var descriptor = FetchDescriptor<ExecutionHistory>(
            sortBy: [SortDescriptor(\.executedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        return try modelContext.fetch(descriptor)
    }
}
