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
            errorMessage = L10N.Error.executionDeleteFailed(error.localizedDescription)
        }
    }
    
    func deleteAll() async {
        do {
            try await repository.deleteAll()
        } catch {
            errorMessage = L10N.Error.executionDeleteAllFailed(error.localizedDescription)
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
        case all
        case successful
        case failed
        
        var title: String {
            switch self {
            case .all: L10N.History.Filter.all
            case .successful: L10N.History.Filter.success
            case .failed: L10N.History.Filter.failed
            }
        }
    }
    
    enum SortOption: String, CaseIterable {
        case dateDescending
        case dateAscending
        case duration
        case workflowName
        
        var title: String {
            switch self {
            case .dateDescending: L10N.History.Sort.newest
            case .dateAscending: L10N.History.Sort.oldest
            case .duration: L10N.History.Sort.duration
            case .workflowName: L10N.History.Sort.name
            }
        }
    }
}
