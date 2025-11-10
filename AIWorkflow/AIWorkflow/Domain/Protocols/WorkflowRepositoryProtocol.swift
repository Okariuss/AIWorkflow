//
//  WorkflowRepositoryProtocol.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation

protocol WorkflowRepositoryProtocol {
    func fetchAll() async throws -> [Workflow]
    func fetch(by id: UUID) async throws -> Workflow?
    func save(_ workflow: Workflow) async throws
    func delete(_ workflow: Workflow) async throws
    func fetchFavorites() async throws -> [Workflow]
    func search(query: String) async throws -> [Workflow]
}
