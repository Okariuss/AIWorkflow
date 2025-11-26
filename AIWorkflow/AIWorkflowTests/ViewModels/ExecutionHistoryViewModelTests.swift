//
//  ExecutionHistoryViewModelTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("ExecutionHistoryViewModel Tests")
@MainActor
struct ExecutionHistoryViewModelTests {
    
    // MARK: - Mock Repository
    
    final class MockHistoryRepository: ExecutionHistoryRepositoryProtocol {
        var histories: [ExecutionHistory] = []
        var shouldThrowError = false
        var deleteAllCalled = false
        var deleteCalled = false
        
        func fetchAll() async throws -> [ExecutionHistory] {
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            return histories
        }
        
        func fetch(for workflowId: UUID) async throws -> [ExecutionHistory] {
            histories.filter { $0.workflowId == workflowId }
        }
        
        func save(_ history: ExecutionHistory) async throws {
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            histories.append(history)
        }
        
        func delete(_ history: ExecutionHistory) async throws {
            deleteCalled = true
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            histories.removeAll { $0.id == history.id }
        }
        
        func deleteAll() async throws {
            deleteAllCalled = true
            if shouldThrowError {
                throw NSError(domain: "test", code: 1)
            }
            histories.removeAll()
        }
        
        func fetchRecent(limit: Int) async throws -> [ExecutionHistory] {
            Array(histories.prefix(limit))
        }
    }
    
    // MARK: - Tests
    
    @Test("ViewModel initializes correctly")
    func testInitialization() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.searchQuery == "")
    }
    
    @Test("Delete execution succeeds")
    func testDeleteExecution() async {
        let repository = MockHistoryRepository()
        let history = ExecutionHistory(
            workflowId: UUID(),
            workflowName: "Test",
            status: ExecutionHistory.Status.success.rawValue,
            inputText: "Input",
            outputText: "Output"
        )
        repository.histories = [history]
        
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        await viewModel.deleteExecution(history)
        
        #expect(repository.deleteCalled)
        #expect(repository.histories.isEmpty)
    }
    
    @Test("Delete execution failure sets errorMessage")
    func testDeleteExecutionFailure() async {
        let repository = MockHistoryRepository()
        repository.shouldThrowError = true
        
        let history = ExecutionHistory(
            workflowId: UUID(),
            workflowName: "Test",
            status: ExecutionHistory.Status.success.rawValue,
            inputText: "Input",
            outputText: "Output"
        )
        repository.histories = [history]
        
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        await viewModel.deleteExecution(history)
        
        #expect(viewModel.errorMessage != nil)
        #expect(repository.histories.count == 1) // still present
    }
    
    @Test("Delete all succeeds")
    func testDeleteAll() async {
        let repository = MockHistoryRepository()
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 1", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 2", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output")
        ]
        
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        await viewModel.deleteAll()
        
        #expect(repository.deleteAllCalled)
        #expect(repository.histories.isEmpty)
    }
    
    @Test("Delete all failure sets errorMessage")
    func testDeleteAllFailure() async {
        let repository = MockHistoryRepository()
        repository.shouldThrowError = true
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 1", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output")
        ]
        
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        await viewModel.deleteAll()
        
        #expect(viewModel.errorMessage != nil)
        #expect(repository.histories.count == 1) // nothing deleted
    }
    
    @Test("Filter by successful works")
    func testFilterSuccessful() async {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 1", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 2", status: ExecutionHistory.Status.failed.rawValue, inputText: "Input", outputText: "")
        ]
        
        viewModel.filterOption = .successful
        let filtered = viewModel.filterExecutions(repository.histories)
        
        #expect(filtered.count == 1)
        #expect(filtered.first?.workflowName == "Test 1")
    }
    
    @Test("Filter by failed works")
    func testFilterFailed() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 1", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: ""),
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 2", status: ExecutionHistory.Status.failed.rawValue, inputText: "Input", outputText: "")
        ]
        
        viewModel.filterOption = .failed
        let filtered = viewModel.filterExecutions(repository.histories)
        
        #expect(filtered.count == 1)
        #expect(filtered.first?.workflowName == "Test 2")
    }
    
    @Test("Filter executions by search query")
    func testFilterBySearch() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 1", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(workflowId: UUID(), workflowName: "Test 2", status: ExecutionHistory.Status.failed.rawValue, inputText: "Input", outputText: "")
        ]
        
        viewModel.searchQuery = "Test 1"
        let filtered = viewModel.filterExecutions(repository.histories)
        
        #expect(filtered.count == 1)
        #expect(filtered.first?.workflowName == "Test 1")
    }
    
    @Test("Sort executions by name")
    func testSortByName() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Zebra", status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(workflowId: UUID(), workflowName: "Apple", status: ExecutionHistory.Status.failed.rawValue, inputText: "Input", outputText: ""),
            ExecutionHistory(workflowId: UUID(), workflowName: "Mango", status: ExecutionHistory.Status.failed.rawValue, inputText: "Input", outputText: "")
        ]
        
        viewModel.sortOption = .workflowName
        let sorted = viewModel.sortExecutions(repository.histories)
        
        #expect(sorted[0].workflowName == "Apple")
        #expect(sorted[1].workflowName == "Mango")
        #expect(sorted[2].workflowName == "Zebra")
    }
    
    @Test("Sort by date descending")
    func testSortByDateDescending() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        let now = Date()
        repository.histories = [
            ExecutionHistory(id: UUID(), workflowId: UUID(), workflowName: "Old", executedAt: now.addingTimeInterval(-100), duration: 0.5, status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(id: UUID(), workflowId: UUID(), workflowName: "Recent", executedAt: now, duration: 1.0, status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output")
        ]
        
        viewModel.sortOption = .dateDescending
        let sorted = viewModel.sortExecutions(repository.histories)
        
        #expect(sorted.first?.workflowName == "Recent")
    }
    
    @Test("Sort by date ascending")
    func testSortByDateAscending() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        let now = Date()
        repository.histories = [
            ExecutionHistory(id: UUID(), workflowId: UUID(), workflowName: "Old", executedAt: now.addingTimeInterval(-100), duration: 0.5, status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(id: UUID(), workflowId: UUID(), workflowName: "Recent", executedAt: now, duration: 1.0, status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output")
        ]
        
        viewModel.sortOption = .dateAscending
        let sorted = viewModel.sortExecutions(repository.histories)
        
        #expect(sorted.first?.workflowName == "Old")
    }

    @Test("Sort by duration works")
    func testSortByDuration() {
        let repository = MockHistoryRepository()
        let viewModel = ExecutionHistoryViewModel(repository: repository)
        
        repository.histories = [
            ExecutionHistory(workflowId: UUID(), workflowName: "Fast", executedAt: Date(), duration: 0.5, status: ExecutionHistory.Status.success.rawValue, inputText: "Input", outputText: "Output"),
            ExecutionHistory(workflowId: UUID(), workflowName: "Slow", executedAt: Date(), duration: 2.0, status: ExecutionHistory.Status.failed.rawValue, inputText: "Input", outputText: "Output")
        ]
        
        viewModel.sortOption = .duration
        let sorted = viewModel.sortExecutions(repository.histories)
        
        #expect(sorted.first?.workflowName == "Slow")
    }
}
