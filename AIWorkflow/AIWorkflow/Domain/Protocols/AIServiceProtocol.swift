//
//  AIServiceProtocol.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 10.11.2025.
//

import Foundation

protocol AIServiceProtocol {
    func execute(prompt: String) async throws -> String
    func executeStreaming(prompt: String) async throws -> AsyncThrowingStream<String, Error>
    func executeWithOptions(prompt: String, temperature: Double, maxTokens: Int, samplingMode: WorkflowStep.AdvancedOptions.SamplingMode) async throws -> String
    func executeStreamingWithOptions(prompt: String, temperature: Double, maxTokens: Int, samplingMode: WorkflowStep.AdvancedOptions.SamplingMode) async throws -> AsyncThrowingStream<String, Error>
    func isAvailable() async -> Bool
}

// MARK: - AI Service Errors
enum AIServiceError: LocalizedError {
    case modelNotAvailable
    case invalidResponse
    case executionFailed(String)
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .modelNotAvailable: "AI model is not available on this device. Requires iOS 18.2+ and A17 Pro chip or later."
        case .invalidResponse: "Received an invalid response from the AI model."
        case .executionFailed(let message): "AI execution failed: \(message)"
        case .cancelled: "AI execution was cancelled."
        }
    }
}
