//
//  ExecutionHistoryViewModel.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import Foundation

@MainActor
@Observable
final class ExecutionHistoryViewModel {
    // MARK: - Published State
    private(set) var errorMessage: String?
    
    var searchQuery = ""
    
    var filterOption: FilterOption = .all
    
    var sortOption: SortOption = .dateDescending
    
    // MARK: - Dependencies
    private let repository: ExecutionHistoryRepositoryProtocol
    
    // MARK: Init
    init(repository: ExecutionHistoryRepositoryProtocol) {
        self.repository = repository
    }
}

// MARK: Public Methods
extension ExecutionHistoryViewModel {
    func deleteExecution(_ execution: ExecutionHistory) async {
        do {
            try await repository.delete(execution)
        } catch {
            errorMessage = "Failed to delete execution: \(error.localizedDescription)"
        }
    }
    
    func deleteAll() async {
        do {
            try await repository.deleteAll()
        } catch {
            errorMessage = "Failed to delete all: \(error.localizedDescription)"
        }
    }
    
    func filterExecutions(_ executions: [ExecutionHistory]) -> [ExecutionHistory] {
        var filtered = executions
        
        switch filterOption {
        case .all:
            break
        case .successful:
            filtered = filtered.filter { $0.executionStatus == .success }
        case .failed:
            filtered = filtered.filter { $0.executionStatus == .failed }
        }
        
        if !searchQuery.isEmpty {
            filtered = filtered.filter { execution in
                execution.workflowName.localizedStandardContains(searchQuery)
            }
        }
        
        return sortExecutions(filtered)
    }
    
    func sortExecutions(_ executions: [ExecutionHistory]) -> [ExecutionHistory] {
        switch sortOption {
        case .dateDescending:
            return executions.sorted { $0.executedAt > $1.executedAt }
        case .dateAscending:
            return executions.sorted { $0.executedAt < $1.executedAt }
        case .duration:
            return executions.sorted { $0.duration > $1.duration }
        case .workflowName:
            return executions.sorted { $0.workflowName.localizedCompare($1.workflowName) == .orderedAscending }
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - Supporting Types
extension ExecutionHistoryViewModel {
    enum FilterOption: String, CaseIterable {
        case all = "All"
        case successful = "Successful"
        case failed = "Failed"
    }
    
    enum SortOption: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case duration = "Duration"
        case workflowName = "Workflow Name"
    }
}
