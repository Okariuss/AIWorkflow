//
//  WorkflowWidget.swift
//  WorkflowWidget
//
//  Created by Okan Orkun on 17.11.2025.
//

import WidgetKit
import SwiftUI

struct WorkflowWidget: Widget {
    let kind: String = "WorkflowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WorkflowWidgetProvider()) { entry in
            WorkflowWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName(NSLocalizedString("widget.configuration.display_name", comment: "Widget Display Name"))
        .description(NSLocalizedString("widget.configuration.description", comment: "Widget Description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    WorkflowWidget()
} timeline: {
    WorkflowWidgetEntry(
        date: Date(),
        workflows: [
            WorkflowWidgetData(
                id: UUID(),
                name: "Summarize & Translate",
                stepCount: 3,
                isFavorite: true,
                isSelected: true
            )
        ]
    )
}

#Preview(as: .systemMedium) {
    WorkflowWidget()
} timeline: {
    WorkflowWidgetEntry(
        date: Date(),
        workflows: [
            WorkflowWidgetData(
                id: UUID(),
                name: "Summarize Text",
                stepCount: 2,
                isFavorite: true,
                isSelected: false
            ),
            WorkflowWidgetData(
                id: UUID(),
                name: "Quick Translate",
                stepCount: 1,
                isFavorite: false,
                isSelected: true
            )
        ]
    )
}

#Preview(as: .systemLarge) {
    WorkflowWidget()
} timeline: {
    WorkflowWidgetEntry(
        date: Date(),
        workflows: [
            WorkflowWidgetData(
                id: UUID(),
                name: "Summarize & Translate",
                stepCount: 3,
                isFavorite: true,
                isSelected: true
            ),
            WorkflowWidgetData(
                id: UUID(),
                name: "Extract Info",
                stepCount: 2,
                isFavorite: true,
                isSelected: true
            ),
            WorkflowWidgetData(
                id: UUID(),
                name: "Analyze Content",
                stepCount: 1,
                isFavorite: false,
                isSelected: true
            ),
            WorkflowWidgetData(
                id: UUID(),
                name: "Quick Summary",
                stepCount: 1,
                isFavorite: false,
                isSelected: true
            )
        ]
    )
}
