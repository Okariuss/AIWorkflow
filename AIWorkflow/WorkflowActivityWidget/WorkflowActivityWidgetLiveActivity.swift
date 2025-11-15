//
//  WorkflowActivityWidgetLiveActivity.swift
//  WorkflowActivityWidget
//
//  Created by Okan Orkun on 15.11.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct WorkflowActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WorkflowActivityAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Step \(context.state.currentStepIndex + 1)/\(context.state.totalSteps)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        
                        Text(context.state.currentStepName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Image(systemName: context.state.status.icon)
                        .foregroundStyle(Helper.colorForStatus(context.state.status))
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 4) {
                        Text(context.attributes.workflowName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        ProgressView(value: context.state.progress)
                            .tint(Helper.colorForStatus(context.state.status))
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if !context.state.currentOutput.isEmpty {
                        Text(context.state.currentOutput)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .padding(.top, 4)
                    }
                }
            } compactLeading: {
                Text("\(context.state.currentStepIndex + 1)/\(context.state.totalSteps)")
                    .font(.caption2)
                    .fontWeight(.semibold)
            } compactTrailing: {
                Image(systemName: context.state.status.icon)
                    .foregroundStyle(Helper.colorForStatus(context.state.status))
            } minimal: {
                Image(systemName: context.state.status.icon)
                    .foregroundStyle(Helper.colorForStatus(context.state.status))
            }
        }
    }
}

#Preview("Notification", as: .content, using: WorkflowActivityAttributes(
    workflowName: "Summarize & Translate",
    workflowID: UUID().uuidString,
    totalSteps: 3,
    startTime: Date()
)) {
    WorkflowActivityWidgetLiveActivity()
} contentStates: {
    WorkflowActivityAttributes.ContentState(
        currentStepIndex: 0,
        currentStepName: "Summarizing",
        totalSteps: 3,
        currentOutput: "The text discusses the main concepts...",
        status: .running,
        progress: 0.33,
        elapsedTime: 2.5
    )
    
    WorkflowActivityAttributes.ContentState(
        currentStepIndex: 1,
        currentStepName: "Translating",
        totalSteps: 3,
        currentOutput: "The text translated to given language...",
        status: .running,
        progress: 0.66,
        elapsedTime: 2.5
    )
    
    WorkflowActivityAttributes.ContentState(
        currentStepIndex: 2,
        currentStepName: "Completed",
        totalSteps: 3,
        currentOutput: "El texto discute los conceptos principales...",
        status: .completed,
        progress: 1.0,
        elapsedTime: 5.2
    )
}
