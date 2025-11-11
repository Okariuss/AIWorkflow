//
//  WorkflowInfoCardView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 11.11.2025.
//

import SwiftUI

struct WorkflowInfoCardView: View {
    // MARK: - Properties
    let workflow: Workflow
    let createdDate: String
    let modifiedDate: String
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 16) {
            createView(
                leadingText: "Steps",
                image: "list.bullet",
                imageColor: .blue,
                trailingText: "\(workflow.stepCount)"
            )
            
            Divider()
            
            createView(
                leadingText: "Created",
                image: "calendar.badge.plus",
                imageColor: .green,
                trailingText: createdDate
            )
            
            Divider()
            
            createView(
                leadingText: "Last Modified",
                image: "calendar.badge.clock",
                imageColor: .orange,
                trailingText: modifiedDate
            )
            
            if workflow.isFavorite {
                favoriteStatus
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Subviews
private extension WorkflowInfoCardView {
    
    var favoriteStatus: some View {
        VStack(spacing: 16) {
            Divider()
            
            HStack {
                Label {
                    Text("Favorite")
                        .foregroundStyle(.secondary)
                } icon: {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Reusable Methods
private extension WorkflowInfoCardView {
    func createView(leadingText: String, image: String, imageColor: Color, trailingText: String) -> some View {
        HStack {
            Label {
                Text(leadingText)
                    .foregroundStyle(.secondary)
            } icon: {
                Image(systemName: image)
                    .foregroundStyle(imageColor)
            }
            
            Spacer()
            
            Text(trailingText)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    VStack {
        WorkflowInfoCardView(
            workflow: {
                let workflow = Workflow(
                    name: "Test Workflow",
                    workflowDescription: "Test description"
                )
                workflow.isFavorite = true
                workflow.steps = [
                    WorkflowStep(stepType: "summarize", prompt: "Test", order: 0),
                    WorkflowStep(stepType: "translate", prompt: "Test", order: 1)
                ]
                return workflow
            }(),
            createdDate: "Jan 15, 2025 at 2:30 PM",
            modifiedDate: "2 hours ago"
        )
        
        Spacer()
    }
    .padding()
}
