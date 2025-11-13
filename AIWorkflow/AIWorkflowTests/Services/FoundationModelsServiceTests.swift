//
//  FoundationModelsServiceTests.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 13.11.2025.
//

import Testing
import Foundation
@testable import AIWorkflow

@Suite("FoundationModelsService Tests")
@MainActor
struct FoundationModelsServiceTests {
    
    @Test("Service is a singleton")
    func testSingleton() {
        let service1 = FoundationModelsService.shared
        let service2 = FoundationModelsService.shared
        
        #expect(service1 === service2)
    }
    
    @Test("Execute validates empty prompt")
    func testExecuteEmptyPrompt() async {
        let service = FoundationModelsService.shared
        do {
            _ = try await service.execute(prompt: "   ")
            Issue.record("Should have thrown error for empty prompt")
        } catch {
            #expect(error is AIServiceError)
        }
    }
    
    @Test("Execute throws when model unavailable")
    func testExecuteUnavailable() async {
        let service = FoundationModelsService.shared
        
        // Bu durumda modelin uygun olmadığını simüle ediyoruz
        // Gerçek ortamda SystemLanguageModel.isAvailable false dönebilir
        if await service.isAvailable() == false {
            do {
                _ = try await service.execute(prompt: "Hello")
                Issue.record("Should have thrown error for unavailable model")
            } catch {
                #expect(error is AIServiceError)
            }
        } else {
            // Skip test if model is available
            print("⚠️ Skipped: Model available on this device")
        }
    }
    
    @Test("Execute runs successfully with non-empty prompt (if available)")
    func testExecuteSuccess() async throws {
        let service = FoundationModelsService.shared
        
        if await service.isAvailable() {
            let response = try await service.execute(prompt: "Say hello in one word")
            #expect(!response.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        } else {
            print("⚠️ Skipped: Model unavailable on this device")
        }
    }
    
    @Test("Execute streaming yields progressive output")
    func testExecuteStreaming() async throws {
        let service = FoundationModelsService.shared
        
        if await service.isAvailable() {
            let prompt = "Stream 'Hello world' word by word"
            var collected: [String] = []
            
            for try await chunk in try await service.executeStreaming(prompt: prompt) {
                collected.append(chunk)
            }
            
            #expect(!collected.isEmpty)
            #expect(collected.last?.count ?? 0 > 0)
        } else {
            print("⚠️ Skipped: Model unavailable on this device")
        }
    }
    
    @Test("Execute with instructions returns content")
    func testExecuteWithInstructions() async throws {
        let service = FoundationModelsService.shared
        
        if await service.isAvailable() {
            let result = try await service.executeWithInstructions(
                instructions: "Respond with a JSON object",
                prompt: "Give me a JSON with key 'status' and value 'ok'"
            )
            #expect(result.contains("{") || result.contains("status"))
        } else {
            print("⚠️ Skipped: Model unavailable on this device")
        }
    }
}
