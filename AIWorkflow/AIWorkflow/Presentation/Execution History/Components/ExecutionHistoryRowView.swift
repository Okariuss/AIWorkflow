//
//  ExecutionHistoryRowView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import SwiftUI

struct ExecutionHistoryRowView: View {
    
    // MARK: - Properties
    let execution: ExecutionHistory
    
    // MARK: - View
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerNameStatus
            
            executionDetails
            
            if execution.executionStatus == .success && !execution.outputText.isEmpty {
                Text(execution.outputText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Subviews
private extension ExecutionHistoryRowView {
    var headerNameStatus: some View {
        HStack(alignment: .top) {
            Text(execution.workflowName)
                .font(.headline)
                .lineLimit(1)
            
            Spacer()
            
            statusBadge
        }
    }
    
    var statusBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: execution.executionStatus?.icon ?? "circle")
            Text(execution.status)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(badgeColor)
        .clipShape(.capsule)
    }
    
    var executionDetails: some View {
        HStack(spacing: 12) {
            Label(
                execution.executedAt.formatted(.relative(presentation: .named)),
                systemImage: "clock"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
                        
            Label(
                String(format: "%.1fs", execution.duration),
                systemImage: "timer"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
    
    
}

// MARK: - Helpers
private extension ExecutionHistoryRowView {
    var badgeColor: Color {
        switch execution.executionStatus {
        case .success: .green
        case .failed: .red
        case .cancelled: .orange
        case .none: .gray
        }
    }
}

#Preview {
    List {
        ExecutionHistoryRowView(
            execution: {
                let history = ExecutionHistory(
                    workflowId: UUID(),
                    workflowName: "Summarize & Translate",
                    executedAt: Date().addingTimeInterval(-3600),
                    duration: 2.5,
                    status: ExecutionHistory.Status.success.rawValue,
                    inputText: "Test input",
                    outputText: "This is the final output from the workflow execution. It shows a preview of the result."
                )
                return history
            }()
        )
        
        ExecutionHistoryRowView(
            execution: {
                let history = ExecutionHistory(
                    workflowId: UUID(),
                    workflowName: "Analyze Content",
                    executedAt: Date().addingTimeInterval(-86400),
                    duration: 1.8,
                    status: ExecutionHistory.Status.failed.rawValue,
                    inputText: "Test input",
                    outputText: ""
                )
                return history
            }()
        )
    }
}
