//
//  ExecutionHistoryView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import SwiftUI
import SwiftData

struct ExecutionHistoryView: View {
    
    // MARK: - SwiftData Query
    @Query(sort: \ExecutionHistory.executedAt, order: .reverse)
    private var allExecutions: [ExecutionHistory]
    
    // MARK: - Properties
    @State private var viewModel: ExecutionHistoryViewModel
    @State private var showingDeleteAllConfirmation = false
    
    // MARK: - Init
    init(viewModel: ExecutionHistoryViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Computed Properties
    private var filteredExecutions: [ExecutionHistory] {
        viewModel.filterExecutions(allExecutions)
    }
    
    // MARK: - View
    var body: some View {
        Group {
            if filteredExecutions.isEmpty {
                emptyStateView
            } else {
                historyList
            }
        }
        .navigationTitle("Execution History")
        .toolbar {
            toolbarContent
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search executions")
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .confirmationDialog("Delete All History", isPresented: $showingDeleteAllConfirmation) {
            Button("Delete All", role: .destructive) {
                Task {
                    await viewModel.deleteAll()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all execution history. This action cannot be undone.")
        }
    }
}

// MARK: - Subviews
private extension ExecutionHistoryView {
    
    @ViewBuilder
    var emptyStateView: some View {
        if viewModel.searchQuery.isEmpty && allExecutions.isEmpty {
            EmptyStateView(
                message: "No execution history yet",
                systemImage: "clock.arrow.circlepath",
            )
        } else if viewModel.searchQuery.isEmpty && viewModel.filterOption == .successful {
            EmptyStateView(
                message: "No success executions yet",
                systemImage: "checkmark.seal",
                actionTitle: "Browse All",
                action: { viewModel.filterOption = .all }
            )
        } else if viewModel.searchQuery.isEmpty && viewModel.filterOption == .failed {
            EmptyStateView(
                message: "No failed executions yet",
                systemImage: "xmark.octagon",
                actionTitle: "Browse All",
                action: { viewModel.filterOption = .all }
            )
        } else if !viewModel.searchQuery.isEmpty {
            EmptyStateView(message: "No executions found for '\(viewModel.searchQuery)'", systemImage: "magnifyingglass")
        } else {
            EmptyStateView(
                message: "No executions match the current filter",
                systemImage: "line.3.horizontal.decrease.circle"
            )
        }
    }
    
    var historyList: some View {
        List {
            Section {
                statisticsCard
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            
            Section {
                ForEach(filteredExecutions, id: \.id) { execution in
                    NavigationLink(value: execution) {
                        ExecutionHistoryRowView(execution: execution)
                    }
                    .contextMenu {
                        Button {
                            UIPasteboard.general.string = execution.outputText
                        } label: {
                            Label("Copy Output", systemImage: "doc.on.doc")
                        }
                        .disabled(execution.outputText.isEmpty)
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteExecution(execution)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        deleteButton(for: execution)
                    }
                    .transition(.opacity.combined(with: .slide))
                }
                .animation(.spring(response: 0.3), value: filteredExecutions.count)
            }
        }
        .listStyle(.insetGrouped)
        .navigationDestination(for: ExecutionHistory.self) { execution in
            ExecutionHistoryDetailView(execution: execution)
        }
    }
    
    var statisticsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Statistics")
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatItemView(
                    title: "Total",
                    value: "\(allExecutions.count)",
                    icon: "clock.arrow.circlepath",
                    color: .blue
                )
                
                StatItemView(
                    title: "Success",
                    value: "\(allExecutions.filter { $0.executionStatus == .success }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItemView(
                    title: "Failed",
                    value: "\(allExecutions.filter { $0.executionStatus == .failed }.count)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Menu {
                Picker("Filter", selection: $viewModel.filterOption) {
                    ForEach(ExecutionHistoryViewModel.FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
            } label: {
                Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker("Sort", selection: $viewModel.sortOption) {
                    ForEach(ExecutionHistoryViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.rawValue)
                            .tag(option)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button(role: .destructive) {
                    showingDeleteAllConfirmation = true
                } label: {
                    Label("Delete All History", systemImage: "trash")
                }
            } label: {
                Label("More", systemImage: "ellipsis.circle")
            }
            .disabled(allExecutions.isEmpty)
        }
    }
}

// MARK: - Swipe Actions Buttons
private extension ExecutionHistoryView {
    
    func deleteButton(for execution: ExecutionHistory) -> some View {
        Button(role: .destructive) {
            Task {
                await viewModel.deleteExecution(execution)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
}

#Preview("With History") {
    NavigationStack {
        ExecutionHistoryView(
            viewModel: {
                let container = DependencyContainer.shared
                return ExecutionHistoryViewModel(repository: container.executionHistoryRepository)
            }()
        )
        .modelContainer(DependencyContainer.shared.container)
        .onAppear {
            // Add sample history
            Task {
                let history1 = ExecutionHistory(
                    workflowId: UUID(),
                    workflowName: "Summarize & Translate",
                    executedAt: Date().addingTimeInterval(-3600),
                    duration: 2.5,
                    status: ExecutionHistory.Status.success.rawValue,
                    inputText: "Test input",
                    outputText: "Final output"
                )
                
                let history2 = ExecutionHistory(
                    workflowId: UUID(),
                    workflowName: "Analyze Content",
                    executedAt: Date().addingTimeInterval(-86400),
                    duration: 1.8,
                    status: ExecutionHistory.Status.failed.rawValue,
                    inputText: "Test input",
                    outputText: ""
                )
                
                try? await DependencyContainer.shared.executionHistoryRepository.save(history1)
                try? await DependencyContainer.shared.executionHistoryRepository.save(history2)
            }
        }
    }
}

#Preview("Empty State") {
    NavigationStack {
        ExecutionHistoryView(
            viewModel: {
                let container = DependencyContainer.shared
                return ExecutionHistoryViewModel(repository: container.executionHistoryRepository)
            }()
        )
        .modelContainer(DependencyContainer.shared.container)
    }
}
