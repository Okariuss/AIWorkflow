//
//  AIServiceTestView.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 12.11.2025.
//

import SwiftUI

struct AIServiceTestView: View {
    // MARK: - State
    
    @State private var prompt = """
        Summarize the following text in 2-3 sentences: 
        SwiftUI is Apple's modern framework for building user interfaces across all Apple platforms.
        """
    @State private var response = ""
    @State private var displayedResponse = ""
    @State private var isExecuting = false
    @State private var errorMessage: String?
    @State private var useStreaming = true
    @State private var useStructuredOutput = false
    @State private var executionTime: TimeInterval = 0
    
    private let aiService = FoundationModelsService.shared
    
    var body: some View {
        Form {
            Section {
                AIServiceStatusView()
            }
            
            configurationSection
            promptSection
            responseSection
            actionSection
        }
        .navigationTitle("AI Service Test")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
        .animation(.spring(duration: 0.25), value: useStreaming)
        .animation(.spring(duration: 0.25), value: useStructuredOutput)
    }
}

// MARK: - Subviews
private extension AIServiceTestView {
    var configurationSection: some View {
        Section("Test Configuration") {
            Toggle("Use Streaming", isOn: $useStreaming)
                .onChange(of: useStreaming) { oldValue, newValue in
                    if newValue { useStructuredOutput = false }
                }
            
            Toggle("Use Structured Output", isOn: $useStructuredOutput)
                .disabled(useStreaming)
                .onChange(of: useStructuredOutput) { oldValue, newValue in
                    if newValue { useStreaming = false }
                }
        }
    }
    
    var promptSection: some View {
        Section("Test Prompt") {
            TextEditor(text: $prompt)
                .frame(minHeight: 120)
                .font(.body)
                .padding(.vertical, 4)
            
            Picker("Quick Prompts", selection: $prompt) {
                Text("Custom").tag(prompt)
                Text("Summarize").tag("Summarize the following text: SwiftUI is Apple's modern framework...")
                Text("Extract Info").tag("Extract email addresses and phone numbers from: Contact John at john@example.com or call 555-1234")
                Text("Analyze").tag("Analyze the sentiment and tone of: I absolutely love this new feature!")
            }
            .pickerStyle(.menu)
        }
    }
    
    var responseSection: some View {
        Section("Response") {
            if isExecuting && useStreaming {
                // STREAMING DURUMUNDA ANİMASYONLU YAZIM
                ScrollView {
                    Text(displayedResponse.isEmpty ? "…" : displayedResponse)
                        .font(.body)
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(nil, value: displayedResponse)
                        .padding(.vertical, 4)
                }
                .frame(maxHeight: 250)
            } else if isExecuting {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Processing...")
                        .foregroundStyle(.secondary)
                }
            } else if !response.isEmpty {
                responseView
                    .transition(.opacity.combined(with: .slide))
            } else {
                Text("No response yet")
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    var responseView: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                Text(response)
                    .font(.body)
                    .textSelection(.enabled)
                    .animation(nil, value: response)
                    .padding(.vertical, 4)
            }
            .frame(maxHeight: 250)
            
            Divider()
            
            HStack {
                Label("\(String(format: "%.2f", executionTime))s", systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Copy") {
                    UIPasteboard.general.string = response
                }
                .font(.caption)
            }
        }
    }
    
    var actionSection: some View {
        Section {
            Button {
                Task {
                    await executePrompt()
                }
            } label: {
                Label("Execute Prompt", systemImage: "play.fill")
            }
            .disabled(isExecuting || prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            if !response.isEmpty {
                Button("Clear") {
                    withAnimation(.easeInOut) {
                        response = ""
                        executionTime = 0
                    }
                }
            }
        }
    }
}

// MARK: - Private Methods
private extension AIServiceTestView {
    func executePrompt() async {
        isExecuting = true
        response = ""
        displayedResponse = ""
        errorMessage = nil
        
        let startTime = Date()
        
        do {
            if useStructuredOutput && prompt.lowercased().contains("summarize") {

                let result: SummaryResult = try await aiService.executeStructured(
                    prompt: prompt,
                    generating: SummaryResult.self
                )
                withAnimation(.easeInOut) {
                    response = """
                        Summary: \(result.summary)
                        
                        Key Points:
                        \(result.keyPoints.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
                        
                        Sentiment: \(result.sentiment)
                        """
                    displayedResponse = response
                }
            } else if useStreaming {
                for try await snapshot in try await aiService.executeStreaming(prompt: prompt) {
                    await MainActor.run {
                        response = snapshot
                        animateTextStreaming(snapshot)
                    }
                }
            } else {
                let result = try await aiService.execute(prompt: prompt)
                withAnimation(.easeInOut) {
                    response = result
                    displayedResponse = result
                }
            }
            
            executionTime = Date().timeIntervalSince(startTime)
        } catch {
            await MainActor.run {
                errorMessage = (error as? AIServiceError)?.localizedDescription ?? error.localizedDescription
            }
        }
        
        isExecuting = false
    }
    
    func animateTextStreaming(_ newText: String) {
        let currentCount = displayedResponse.count
        guard newText.count >= currentCount else {
            displayedResponse = newText
            return
        }
        let newChars = Array(newText.dropFirst(currentCount))
        
        Task {
            for char in newChars {
                try? await Task.sleep(nanoseconds: 25_000_000)
                await MainActor.run {
                    withAnimation(.linear(duration: 0.02)) {
                        displayedResponse.append(char)
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AIServiceTestView()
    }
}
