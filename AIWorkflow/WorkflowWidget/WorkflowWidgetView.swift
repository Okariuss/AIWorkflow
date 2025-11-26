//
//  WorkflowWidgetView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 17.11.2025.
//

import SwiftUI
import WidgetKit

struct WorkflowWidgetView: View {
    
    let entry: WorkflowWidgetEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let entry: WorkflowWidgetEntry
    
    var body: some View {
        if let workflow = entry.workflows.first {
            VStack(spacing: 12) {
                Image(systemName: "gearshape.2.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                
                Text(workflow.name)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                
                Text(String(format: NSLocalizedString("workflow_creation.steps.count", comment: "Number of steps"), workflow.stepCount))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding()
            .widgetURL(URL(string: "aiworkflow://run/\(workflow.id.uuidString)"))
        } else {
            ContentUnavailableView(
                NSLocalizedString("widget_preferences.empty.title", comment: "No Workflows Available"),
                systemImage: "square.stack.3d.up.slash"
            )
        }
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let entry: WorkflowWidgetEntry
    
    var body: some View {
        if !entry.workflows.isEmpty {
            HStack(spacing: 12) {
                ForEach(entry.workflows.prefix(2)) { workflow in
                    Link(destination: URL(string: "aiworkflow://run/\(workflow.id.uuidString)")!) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .foregroundStyle(.blue)
                                
                                if workflow.isFavorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.caption)
                                }
                            }
                            
                            Text(workflow.name)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Text(String(format: NSLocalizedString("workflow_creation.steps.count", comment: "Number of steps"), workflow.stepCount))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.quaternary.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        } else {
            ContentUnavailableView(
                NSLocalizedString("widget_preferences.empty.title", comment: "No Workflows Available"),
                systemImage: "square.stack.3d.up.slash",
                description: Text(NSLocalizedString("widget_preferences.empty.message", comment: "Create workflows in the app first"))
            )
        }
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let entry: WorkflowWidgetEntry
    
    var body: some View {
        if !entry.workflows.isEmpty {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "gearshape.2.fill")
                        .foregroundStyle(.blue)
                    
                    Text(NSLocalizedString("widget.configuration.display_name", comment: "Quick Run"))
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("\(entry.workflows.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                Divider()
                
                VStack(spacing: 8) {
                    ForEach(entry.workflows) { workflow in
                        Link(destination: URL(string: "aiworkflow://run/\(workflow.id.uuidString)")!) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(workflow.name)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        
                                        if workflow.isFavorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    Text(String(format: NSLocalizedString("workflow_creation.steps.count", comment: "Number of steps"), workflow.stepCount))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(.quaternary.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding()
                
                Spacer()
            }
        } else {
            ContentUnavailableView(
                NSLocalizedString("widget_preferences.empty.title", comment: "No Workflows Available"),
                systemImage: "square.stack.3d.up.slash",
                description: Text(NSLocalizedString("widget_preferences.empty.message", comment: "Create workflows in the app first"))
            )
        }
    }
}
