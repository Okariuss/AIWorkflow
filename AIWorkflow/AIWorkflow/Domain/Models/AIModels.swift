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
    @Guide(description: L10N.AIModels.SummaryResult.summary)
    var summary: String
    
    @Guide(description: L10N.AIModels.SummaryResult.keyPoints)
    var keyPoints: [String]
    
    @Guide(description: L10N.AIModels.SummaryResult.sentiment)
    var sentiment: String
}

// MARK: - Extraction Model
@Generable
struct ExtractedInfo {
    @Guide(description: L10N.AIModels.ExtractedInfo.emails)
    var emails: [String]
    
    @Guide(description: L10N.AIModels.ExtractedInfo.phoneNumbers)
    var phoneNumbers: [String]
    
    @Guide(description: L10N.AIModels.ExtractedInfo.dates)
    var dates: [String]
    
    @Guide(description: L10N.AIModels.ExtractedInfo.names)
    var names: [String]
}

// MARK: - Translation Model
@Generable
struct TranslationResult {
    @Guide(description: L10N.AIModels.TranslationResult.translatedText)
    var translatedText: String
    
    @Guide(description: L10N.AIModels.TranslationResult.sourceLanguage)
    var sourceLanguage: String
    
    @Guide(description: L10N.AIModels.TranslationResult.targetLanguage)
    var targetLanguage: String
}

// MARK: - Analysis Model
@Generable
struct AnalysisResult {
    @Guide(description: L10N.AIModels.AnalysisResult.tone)
    var tone: String
    
    @Guide(description: L10N.AIModels.AnalysisResult.themes, .count(3...5))
    var themes: [String]
    
    @Guide(description: L10N.AIModels.AnalysisResult.complexity)
    var complexity: String
    
    @Guide(description: L10N.AIModels.AnalysisResult.insights, .count(2...4))
    var insights: [String]
}
