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
        .navigationTitle(L10N.History.title)
        .toolbar {
            toolbarContent
        }
        .searchable(text: $viewModel.searchQuery, prompt: L10N.History.search)
        .alert(L10N.Common.error, isPresented: .constant(viewModel.errorMessage != nil)) {
            Button(L10N.Common.ok) {
                viewModel.clearError()
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .confirmationDialog(L10N.History.DeleteAll.title, isPresented: $showingDeleteAllConfirmation) {
            Button(L10N.Common.delete, role: .destructive) {
                Task {
                    await viewModel.deleteAll()
                }
            }
            Button(L10N.Common.cancel, role: .cancel) {}
        } message: {
            Text(L10N.History.DeleteAll.message)
        }
    }
}

// MARK: - Subviews
private extension ExecutionHistoryView {
    
    @ViewBuilder
    var emptyStateView: some View {
        if viewModel.searchQuery.isEmpty && allExecutions.isEmpty {
            EmptyStateView(
                message: L10N.History.emptyMessage,
                systemImage: "clock.arrow.circlepath",
            )
        } else if viewModel.searchQuery.isEmpty && viewModel.filterOption == .successful {
            EmptyStateView(
                message: L10N.History.emptySuccess,
                systemImage: "checkmark.seal",
                actionTitle: L10N.WorkflowList.favoritesEmptyAction,
                action: { viewModel.filterOption = .all }
            )
        } else if viewModel.searchQuery.isEmpty && viewModel.filterOption == .failed {
            EmptyStateView(
                message: L10N.History.emptyFailed,
                systemImage: "xmark.octagon",
                actionTitle: L10N.WorkflowList.favoritesEmptyAction,
                action: { viewModel.filterOption = .all }
            )
        } else if !viewModel.searchQuery.isEmpty {
            EmptyStateView(message: L10N.History.emptySearch(viewModel.searchQuery), systemImage: "magnifyingglass")
        } else {
            EmptyStateView(
                message: L10N.History.noMatch,
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
                            Label(L10N.Execution.Actions.copy, systemImage: "doc.on.doc")
                        }
                        .disabled(execution.outputText.isEmpty)
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            Task {
                                await viewModel.deleteExecution(execution)
                            }
                        } label: {
                            Label(L10N.Common.delete, systemImage: "trash")
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
                Text(L10N.History.statistics)
                    .font(.headline)
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatItemView(
                    title: L10N.History.Statistics.total,
                    value: "\(allExecutions.count)",
                    icon: "clock.arrow.circlepath",
                    color: .blue
                )
                
                StatItemView(
                    title: L10N.History.Statistics.success,
                    value: "\(allExecutions.filter { $0.executionStatus == .success }.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatItemView(
                    title: L10N.History.Statistics.failed,
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
                Picker(L10N.Common.filter, selection: $viewModel.filterOption) {
                    ForEach(ExecutionHistoryViewModel.FilterOption.allCases, id: \.self) { option in
                        Text(option.title)
                            .tag(option)
                    }
                }
            } label: {
                Label(L10N.Common.filter, systemImage: "line.3.horizontal.decrease.circle")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Picker(L10N.Common.sort, selection: $viewModel.sortOption) {
                    ForEach(ExecutionHistoryViewModel.SortOption.allCases, id: \.self) { option in
                        Text(option.title)
                            .tag(option)
                    }
                }
            } label: {
                Label(L10N.Common.sort, systemImage: "arrow.up.arrow.down")
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                Button(role: .destructive) {
                    showingDeleteAllConfirmation = true
                } label: {
                    Label(L10N.History.DeleteAll.title, systemImage: "trash")
                }
            } label: {
                Label(L10N.Common.more, systemImage: "ellipsis.circle")
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
            Label(L10N.Common.ok, systemImage: "trash")
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
