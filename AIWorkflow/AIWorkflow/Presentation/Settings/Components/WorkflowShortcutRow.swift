//
//  WorkflowShortcutRow.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 16.11.2025.
//

import SwiftUI

struct WorkflowShortcutRow: View {
    let workflow: Workflow
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.body)
                
                Text(L10N.WorkflowEntity.steps(workflow.stepCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .contentShape(Rectangle())
    }
}
