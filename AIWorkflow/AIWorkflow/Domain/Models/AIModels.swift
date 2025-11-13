//
//  AIModels.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 12.11.2025.
//

import Foundation
import FoundationModels

// MARK: - Summarization Model
@Generable
struct SummaryResult {
    @Guide(description: "A concise summary in 2-3 sentences")
    var summary: String
    
    @Guide(description: "3-5 key points from the text")
    var keyPoints: [String]
    
    @Guide(description: "Overall sentiment: positive, negative, or neutral")
    var sentiment: String
}

// MARK: - Extraction Model
@Generable
struct ExtractedInfo {
    @Guide(description: "List of email addresses found")
    var emails: [String]
    
    @Guide(description: "List of phone numbers found")
    var phoneNumbers: [String]
    
    @Guide(description: "List of dates mentioned")
    var dates: [String]
    
    @Guide(description: "List of names or entities found")
    var names: [String]
}

// MARK: - Translation Model
@Generable
struct TranslationResult {
    @Guide(description: "The translated text")
    var translatedText: String
    
    @Guide(description: "Source language detected")
    var sourceLanguage: String
    
    @Guide(description: "Target language")
    var targetLanguage: String
}

// MARK: - Analysis Model
@Generable
struct AnalysisResult {
    @Guide(description: "Overall tone of the text")
    var tone: String
    
    @Guide(description: "Main themes identified", .count(3...5))
    var themes: [String]
    
    @Guide(description: "Complexity level: simple, moderate, or complex")
    var complexity: String
    
    @Guide(description: "Key insights from the analysis", .count(2...4))
    var insights: [String]
}
