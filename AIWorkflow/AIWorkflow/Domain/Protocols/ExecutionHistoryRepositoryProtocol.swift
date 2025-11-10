//
//  ExecutionHistoryRepositoryProtocol.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation

protocol ExecutionHistoryRepositoryProtocol {
    func fetchAll() async throws -> [ExecutionHistory]
    func fetch(for workflowId: UUID) async throws -> [ExecutionHistory]
    func save(_ history: ExecutionHistory) async throws
    func delete(_ history: ExecutionHistory) async throws
    func deleteAll() async throws
    func fetchRecent(limit: Int) async throws -> [ExecutionHistory]
}
