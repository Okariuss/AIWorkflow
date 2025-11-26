//
//  WorkflowActivityAttributes.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 15.11.2025.
//

import ActivityKit
import Foundation
import SwiftUI

struct WorkflowActivityAttributes: ActivityAttributes {
    // MARK: - Content State
    public struct ContentState: Codable, Hashable {
        var currentStepIndex: Int
        var currentStepName: String
        var totalSteps: Int
        var currentOutput: String
        var status: ActivityExecutionStatus
        var progress: Double
        var elapsedTime: TimeInterval
    }
    
    // MARK: - Static Attributes
    var workflowName: String
    var workflowID: String
    var totalSteps: Int
    var startTime: Date
}

// MARK: - Execution Status

enum ActivityExecutionStatus: String, Codable, Hashable {
    case running
    case completed
    case failed
    case cancelled
    
    var title: String {
        switch self {
        case .running: NSLocalizedString("execution.status.running", comment: "Running status")
        case .completed: NSLocalizedString("execution.status.completed", comment: "Completed status")
        case .failed: NSLocalizedString("execution.status.failed", comment: "Failed status")
        case .cancelled: NSLocalizedString("execution.status.cancelled", comment: "Cancelled status")
        }
    }

    var icon: String {
        switch self {
        case .running: return "gearshape.2.fill"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .cancelled: return "stop.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .running: return "blue"
        case .completed: return "green"
        case .failed: return "red"
        case .cancelled: return "orange"
        }
    }
}

final class Helper {
    static var shared = Helper()
        
    private init() { }
    
    static func colorForStatus(_ status: ActivityExecutionStatus) -> Color {
        switch status {
        case .running: return .blue
        case .completed: return .green
        case .failed: return .red
        case .cancelled: return .orange
        }
    }
}
