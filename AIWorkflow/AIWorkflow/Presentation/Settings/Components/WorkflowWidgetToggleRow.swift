//
//  WorkflowWidgetToggleRow.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 19.11.2025.
//

import SwiftUI

struct WorkflowWidgetToggleRow: View {
    let workflow: Workflow
    let isSelected: Bool
    let canSelect: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.body)
                
                HStack {
                    Text(L10N.WorkflowEntity.steps(workflow.stepCount))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    if workflow.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                    }
                }
            }
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isSelected },
                set: { onToggle($0) }
            ))
            .labelsHidden()
            .disabled(!canSelect && !isSelected)
        }
        .contentShape(Rectangle())
        .opacity(canSelect || isSelected ? 1.0 : 0.5)
    }
}
