//
//  EmptyStateView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct EmptyStateView: View {
    let message: String
    let systemImage: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        message: String = L10N.WorkflowList.emptyMessage,
        systemImage: String = "square.stack.3d.up.slash",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.systemImage = systemImage
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            Text(message)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(40)
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateView()
        
        EmptyStateView(
            message: "No favorite workflows",
            systemImage: "star.slash",
            actionTitle: "Browse All",
            action: {}
        )
    }
}
