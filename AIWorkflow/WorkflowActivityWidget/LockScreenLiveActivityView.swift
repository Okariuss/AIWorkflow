//
//  LockScreenLiveActivityView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import SwiftUI
import WidgetKit

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<WorkflowActivityAttributes>
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: context.state.status.icon)
                    .foregroundStyle(Helper.colorForStatus(context.state.status))
                
                Text(context.attributes.workflowName)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Text(context.state.status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Step \(context.state.currentStepIndex + 1) of \(context.state.totalSteps)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(context.state.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                ProgressView(value: context.state.progress)
                    .tint(Helper.colorForStatus(context.state.status))
            }
            
            if !context.state.currentStepName.isEmpty {
                HStack {
                    Text(context.state.currentStepName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .activityBackgroundTint(.clear)
    }
}
