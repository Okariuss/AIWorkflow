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
    case running = "Running"
    case completed = "Completed"
    case failed = "Failed"
    case cancelled = "Cancelled"
    
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
