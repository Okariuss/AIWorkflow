//
//  LocalizationHelper.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 21.11.2025.
//

import Foundation
import SwiftUI
import AppIntents

// MARK: - String Extension for Localization
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    func localized(_ args: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: args)
    }
}

// MARK: - Localized String Keys
enum L10N {
    // MARK: - Common
    enum Common {
        static let save = "common.save".localized
        static let cancel = "common.cancel".localized
        static let delete = "common.delete".localized
        static let edit = "common.edit".localized
        static let done = "common.done".localized
        static let close = "common.close".localized
        static let add = "common.add".localized
        static let remove = "common.remove".localized
        static let ok = "common.ok".localized
        static let yes = "common.yes".localized
        static let no = "common.no".localized
        static let error = "common.error".localized
        static let success = "common.success".localized
        static let loading = "common.loading".localized
        static let saving = "common.saving".localized
        static let clear = "common.clear".localized
        static let copy = "common.copy".localized
        static let share = "common.share".localized
        static let search = "common.search".localized
        static let filter = "common.filter".localized
        static let sort = "common.sort".localized
        static let more = "common.more".localized
        static let run = "common.run".localized
        static let stop = "common.stop".localized
        static let retry = "common.retry".localized
        static let seconds = "common.seconds".localized
    }
    
    // MARK: - Workflow List
    enum WorkflowList {
        static let title = "workflow_list.title".localized
        static let search = "workflow_list.search".localized
        static func deleteMessage(_ name: String) -> String {
            "workflow_list.delete.message".localized(name)
        }
        static let create = "workflow_list.create".localized
        static let emptyMessage = "workflow_list.empty.message".localized
        static let emptyAction = "workflow_list.empty.action".localized
        static let favoritesEmptyMessage = "workflow_list.favorites_empty.message".localized
        static let favoritesEmptyAction = "workflow_list.favorites_empty.action".localized
        static func searchEmpty(_ query: String) -> String {
            "workflow_list.search_empty.message".localized(query)
        }
        static let filterNoMatch = "workflow_list.filter_no_match.message".localized

        static let settings = "workflow_list.settings".localized
        static let history = "workflow_list.history".localized
        
        enum Filter {
            static let all = "workflow_list.filter.all".localized
            static let favorites = "workflow_list.filter.favorites".localized
        }
        
        enum Sort {
            static let name = "workflow_list.sort.name".localized
            static let modified = "workflow_list.sort.modified".localized
            static let created = "workflow_list.sort.created".localized
            static let steps = "workflow_list.sort.steps".localized
        }
    }
    
    // MARK: - Workflow Entity
    enum WorkflowEntity {
        static func steps(_ count: Int) -> LocalizedStringResource {
            LocalizedStringResource(stringLiteral: String(format: NSLocalizedString("workflow.entity.steps", comment: ""), count))
        }
    }
    
    // MARK: - Workflow Detail
    enum WorkflowDetail {
        static let steps = "workflow_detail.steps".localized
        static let prompt = "workflow_detail.prompt".localized
        static let description = "workflow_detail.description".localized
        static let emptyMessage = "workflow_detail.empty.message".localized
        static let emptyAction = "workflow_detail.empty.action".localized
        
        enum Info {
            static let steps = "workflow_detail.info.steps".localized
            static let created = "workflow_detail.info.created".localized
            static let modified = "workflow_detail.info.modified".localized
            static let favorite = "workflow_detail.info.favorite".localized
        }
        
        enum Actions {
            static let run = "workflow_detail.actions.run".localized
            static let edit = "workflow_detail.actions.edit".localized
            static let favorite = "workflow_detail.actions.favorite".localized
            static let unfavorite = "workflow_detail.actions.unfavorite".localized
            static let duplicate = "workflow_detail.actions.duplicate".localized
        }
        
        enum Delete {
            static let title = "workflow_detail.delete.title".localized
            static let message = "workflow_detail.delete.message".localized
        }
        
        enum Duplicated {
            static let title = "workflow_detail.duplicated.title".localized
            static let action = "workflow_detail.duplicated.action".localized
            static let message = "workflow_detail.duplicated.message".localized
            static let copy = "workflow_detail.duplicated.copy".localized
            static let error = "workflow_detail.duplicated.error".localized
        }
    }
    
    // MARK: - Workflow Creation
    enum WorkflowCreation {
        static let titleNew = "workflow_creation.title.new".localized
        static let titleEdit = "workflow_creation.title.edit".localized
        static let name = "workflow_creation.name".localized
        static let description = "workflow_creation.description".localized
        static let workflowInfo = "workflow_creation.info".localized
        static let stepsTitle = "workflow_creation.steps.title".localized
        static let stepsEmpty = "workflow_creation.steps.empty".localized
        static let stepsAdd = "workflow_creation.steps.add".localized
        static let infoFooter = "workflow_creation.info.footer".localized
        static let stepsFooter = "workflow_creation.steps.footer".localized
        static func stepsCount(_ count: Int) -> String {
            "workflow_creation.steps.count".localized(count)
        }
        
        enum Validation {
            static let nameRequired = "workflow_creation.validation.name_required".localized
            static let nameShort = "workflow_creation.validation.name_short".localized
            static let stepsRequired = "workflow_creation.validation.steps_required".localized
        }
    }
    
    // MARK: - Step Configuration
    enum StepConfig {
        static let titleNew = "step_config.title.new".localized
        static let titleEdit = "step_config.title.edit".localized
        static let invalidStep = "step_config.invalid_step".localized
        static let type = "step_config.type".localized
        static let typeHeader = "step_config.type.header".localized
        static let typeFooter = "step_config.type.footer".localized
        static let prompt = "step_config.prompt".localized
        static let promptFooter = "step_config.prompt.footer".localized
        static let advanced = "step_config.advanced".localized
        static let test = "step_config.test".localized
        static let testInput = "step_config.test.input".localized
        static let testOutput = "step_config.test.output".localized
        static let testTesting = "step_config.test.testing".localized

        static let testRun = "step_config.test.run".localized
        static let testFooter = "step_config.test.footer".localized
        static let preview = "step_config.preview".localized
        
        enum Advanced {
            static let temperature = "step_config.advanced.temperature".localized
            static let temperaturePredictable = "step_config.advanced.temperature.predictable".localized
            static let temperatureCreative = "step_config.advanced.temperature.creative".localized
            static let maxTokens = "step_config.advanced.max_tokens".localized
            static let maxTokensShort = "step_config.advanced.max_tokens.short".localized
            static let maxTokensLong = "step_config.advanced.max_tokens.long".localized
            static let sampling = "step_config.advanced.sampling".localized
            static let reset = "step_config.advanced.reset".localized
            static let footer = "step_config.advanced.footer".localized
        }
        
        enum Validation {
            static let empty = "step_config.validation.empty".localized
            static let short = "step_config.validation.short".localized
            static let temperature = "step_config.validation.temperature".localized
            static let tokens = "step_config.validation.tokens".localized
            static let testInput = "step_config.validation.testInput".localized
        }
    }
    
    // MARK: - Step Types
    enum StepType {
        static let summarize = "step_type.summarize".localized
        static let translate = "step_type.translate".localized
        static let extract = "step_type.extract".localized
        static let rewrite = "step_type.rewrite".localized
        static let analyze = "step_type.analyze".localized
        static let custom = "step_type.custom".localized
        
        static let summarizeSystemPrompt = "step_type.system_prompt.summarize".localized
        static let translateSystemPrompt = "step_type.system_prompt.translate".localized
        static let extractSystemPrompt = "step_type.system_prompt.extract".localized
        static let rewriteSystemPrompt = "step_type.system_prompt.rewrite".localized
        static let analyzeSystemPrompt = "step_type.system_prompt.analyze".localized
        
    }
    
    // MARK: - Live Activity
    enum LiveActivity {
        static let starting = "live_activity.starting".localized
    }
    
    // MARK: - Execution
    enum Execution {
        static let title = "execution.title".localized
        static let input = "execution.input".localized
        static func inputCharacters(_ count: Int) -> String {
            "execution.input.characters".localized(count)
        }
        static let progress = "execution.progress".localized
        static let results = "execution.results".localized
        static let liveActivityEnabled = "execution.live_activity.enabled".localized
        static let errorTitle = "execution.error.title".localized
        
        enum Results {
            static let status = "execution.results.status".localized
            static let duration = "execution.results.duration".localized
            static let stepsCompleted = "execution.results.steps_completed".localized
            static let output = "execution.results.output".localized
        }
        
        enum Actions {
            static let copy = "execution.actions.copy".localized
            static let runAgain = "execution.actions.run_again".localized
        }
        
        enum Status {
            static let running = "execution.status.running".localized
            static let completed = "execution.status.completed".localized
            static let failed = "execution.status.failed".localized
            static let cancelled = "execution.status.cancelled".localized
        }
    }
    
    // MARK: - Workflow Step
    enum WorkflowStep {
        enum Advanced {
            static let greedy = "workflow_step.advanced.greedy".localized
            static let greedyDescription = "workflow_step.advanced.greedy_description".localized
            static let random = "workflow_step.advanced.random".localized
            static let randomDescription = "workflow_step.advanced.random_description".localized
        }
    }
    
    // MARK: - History
    enum History {
        static let title = "history.title".localized
        static let search = "history.search".localized
        static let emptyMessage = "history.empty.message".localized
        static let emptySuccess = "history.empty.success".localized
        static let emptyFailed = "history.empty.failed".localized
        static func emptySearch(_ query: String) -> String {
            "history.empty.search".localized(query)
        }
        static let noMatch = "history.empty.no_matched_filter".localized
        static let statistics = "history.statistics".localized
        
        enum Statistics {
            static let total = "history.statistics.total".localized
            static let success = "history.statistics.success".localized
            static let failed = "history.statistics.failed".localized
        }
        
        enum Filter {
            static let all = "history.filter.all".localized
            static let success = "history.filter.success".localized
            static let failed = "history.filter.failed".localized
        }
        
        enum Sort {
            static let newest = "history.sort.newest".localized
            static let oldest = "history.sort.oldest".localized
            static let duration = "history.sort.duration".localized
            static let name = "history.sort.name".localized
        }
        
        enum DeleteAll {
            static let title = "history.delete_all.title".localized
            static let message = "history.delete_all.message".localized
        }
        
        enum Detail {
            static let title = "history.detail.title".localized
            static let workflow = "history.detail.workflow".localized
            static let duration = "history.detail.duration".localized
            static let executed = "history.detail.executed".localized
            static let input = "history.detail.input".localized
            static let steps = "history.detail.steps".localized
            static let output = "history.detail.output".localized
        }
        
        enum Share {
            static let title = "history.share_text.title".localized
            static let date = "history.share_text.date".localized
            static let input = "history.share_text.input".localized
        }
    }
    
    // MARK: - Settings
    enum Settings {
        static let title = "settings.title".localized
        
        enum AIService {
            static let title = "settings.ai_service".localized
            static let description = "settings.ai_service.description".localized
            static let status = "settings.ai_service.status".localized
            static let available = "settings.ai_service.available".localized
            static let unavailable = "settings.ai_service.unavailable".localized
            static let requirements = "settings.ai_service.requirements".localized
            static let requirementsIOS = "settings.ai_service.requirements.ios".localized
            static let requirementsIntelligence = "settings.ai_service.requirements.intelligence".localized
            static let requirementsDevice = "settings.ai_service.requirements.device".localized
            
            enum Privacy {
                static let local = "settings.ai_service.privacy.local".localized
                static let offline = "settings.ai_service.privacy.offline".localized
            }
        }
        
        enum Test {
            enum Configuration {
                static let title = "settings.test.configuration.title".localized
                static let streaming = "settings.test.configuration.streaming".localized
                static let structured = "settings.test.configuration.structured".localized
            }
            
            enum Prompt {
                static let title = "settings.test.prompt.title".localized
                static let message = "settings.test.prompt.message".localized
                static let quick = "settings.test.prompt.quick".localized
                static let summarizeTag = "settings.test.prompt.summarize_tag".localized
                static let extractTag = "settings.test.prompt.extract_tag".localized
                static let analyzeTag = "settings.test.prompt.analyze_tag".localized
            }
            
            enum Response {
                static let title = "settings.test.response.title".localized
                static let processing = "settings.test.response.processing".localized
                static let noResponse = "settings.test.response.no_response".localized
            }
            
            static let executePrompt = "settings.test.execute_prompt".localized
        }
        
        enum Preferences {
            static let title = "settings.preferences".localized
            static let theme = "settings.preferences.theme".localized
            
            enum Theme {
                static let light = "settings.preferences.theme.light".localized
                static let dark = "settings.preferences.theme.dark".localized
                static let system = "settings.preferences.theme.system".localized
            }
        }
        
        enum Widgets {
            static let title = "settings.widgets".localized
            static let preferences = "settings.widgets.preferences".localized
            static let description = "settings.widgets.description".localized
        }
        
        enum Siri {
            static let title = "settings.siri".localized
            static let manage = "settings.siri.manage".localized
        }
        
        enum Privacy {
            static let title = "settings.privacy".localized
            static let onDeviceTitle = "settings.privacy.ondevice.title".localized
            static let onDeviceDescription = "settings.privacy.ondevice.description".localized
            static let noDataTitle = "settings.privacy.nodata.title".localized
            static let noDataDescription = "settings.privacy.nodata.description".localized
            static let offlineTitle = "settings.privacy.offline.title".localized
            static let offlineDescription = "settings.privacy.offline.description".localized
        }
        
        enum About {
            static let title = "settings.about".localized
            static let version = "settings.about.version".localized
            static let build = "settings.about.build".localized
            static let test = "settings.about.test".localized
        }
        
        enum Technology {
            static let title = "settings.technology".localized
            static let framework = "settings.technology.framework".localized
            static let frameworkValue = "settings.technology.framework.value".localized
            static let architecture = "settings.technology.architecture".localized
            static let architectureValue = "settings.technology.architecture.value".localized
        }
    }
    
    // MARK: - Widget Preferences
    enum WidgetPreferences {
        static let title = "widget_preferences.title".localized
        static let header = "widget_preferences.header".localized
        static let description = "widget_preferences.description".localized
        static func selected(_ count: Int) -> String {
            "widget_preferences.selected".localized(count)
        }
        static let available = "widget_preferences.available".localized
        static let footer = "widget_preferences.footer".localized
        static let emptyTitle = "widget_preferences.empty.title".localized
        static let emptyMessage = "widget_preferences.empty.message".localized
        static let limitReached = "widget_preferences.limit_reached".localized
        static let notFound = "widget_preferences.not_found".localized
        static let saveFailed = "widget_preferences.save_failed".localized
    }
    
    // MARK: - Siri
    enum Siri {
        static let title = "siri.title".localized
        static let description = "siri.description".localized
        static let available = "siri.available".localized
        static let emptyWorkflow = "siri.empty_workflow".localized
        static let commands = "siri.commands".localized
        static let commandsExamples = "siri.commands.examples".localized
        static let commandsExample1 = "siri.commands.example1".localized
        static let commandsExample2 = "siri.commands.example2".localized
        static let commandsExample3 = "siri.commands.example3".localized
        static let howTo = "siri.howto".localized
        
        enum HowTo {
            static let step1Title = "siri.howto.step1.title".localized
            static let step1Description = "siri.howto.step1.description".localized
            static let step2Title = "siri.howto.step2.title".localized
            static let step2Description = "siri.howto.step2.description".localized
            static let step3Title = "siri.howto.step3.title".localized
            static let step3Description = "siri.howto.step3.description".localized
        }
    }
    
    // MARK: - Errors
    enum Error {
        static let workflowNotFound = "error.workflow_not_found".localized
        static let noSteps = "error.no_steps".localized
        static let emptyInput = "error.empty_input".localized
        static func stepFailed(_ step: Int, _ message: String) -> String {
            "error.step_failed".localized(step, message)
        }
        static let executionCancelled = "error.execution_cancelled".localized
        static let executionFailed = "error.execution_failed".localized
        static func executionDeleteFailed(_ message: String) -> String {
            "error.execution.delete_failed".localized(message)
        }
        static func executionDeleteAllFailed(_ message: String) -> String {
            "error.execution.delete_all".localized(message)
        }
        static let aiUnavailable = "error.ai_unavailable".localized
        static let saveFailed = "error.save_failed".localized
        static let deleteFailed = "error.delete_failed".localized
        static let preferencesFailed = "error.preferences_failed".localized
        static let aiModelUnavailable = "error.ai_model_unavailable".localized
        static let aiInvalidResponse = "error.ai_invalid_response".localized
        static func aiExecutionFailed(_ message: String) -> String {
            "error.ai_execution_failed".localized(message)
        }
        static let aiCancelled = "error.ai_cancelled".localized
        static let themeUpdateFailed = "error.theme.update_failed".localized
        static let workflowSetFailed = "error.workflow.set_failed".localized
        static let widgetAddFailed = "error.widget.add_failed".localized
        static let widgetRemoveFailed = "error.widget.remove_failed".localized
        static let invalidWorkflow = "error.invalid_workflow".localized
        static let favoriteUpdateFailed = "error.favorite_update_failed".localized
    }
    
    // MARK: - AI Models
    enum AIModels {
        // MARK: -- Summarization Model
        enum SummaryResult {
            static let summary = "summary_result.summary".localized
            static let keyPoints = "summary_result.keyPoints".localized
            static let sentiment = "summary_result.sentiment".localized
        }
        
        // MARK: -- Extraction Model
        enum ExtractedInfo {
            static let emails = "extracted_info.emails".localized
            static let phoneNumbers = "extracted_info.phoneNumbers".localized
            static let dates = "extracted_info.dates".localized
            static let names = "extracted_info.names".localized
        }
        
        // MARK: -- Translation Model
        enum TranslationResult {
            static let translatedText = "translation_result.translatedText".localized
            static let sourceLanguage = "translation_result.sourceLanguage".localized
            static let targetLanguage = "translation_result.targetLanguage".localized
        }
        
        // MARK: -- Analysis Model
        enum AnalysisResult {
            static let tone = "analysis_result.tone".localized
            static let themes = "analysis_result.themes".localized
            static let complexity = "analysis_result.complexity".localized
            static let insights = "analysis_result.insights".localized
        }
    }

    
    // MARK: - Accessibility
    enum Accessibility {
        static func workflowRow(_ name: String, _ steps: Int) -> String {
            "accessibility.workflow_row".localized(name, steps)
        }
        static func stepRow(_ index: Int, _ type: String) -> String {
            "accessibility.step_row".localized(index, type)
        }
        static let favoriteButton = "accessibility.favorite_button".localized
        static let deleteButton = "accessibility.delete_button".localized
        static let runButton = "accessibility.run_button".localized
        static let addStepButton = "accessibility.add_step_button".localized
        static func progress(_ percentage: Double) -> String {
            "accessibility.progress".localized(percentage)
        }
    }
    
    // MARK: - Intents
    enum Intents {
        // MARK: - Quick Run
        static let quickRunTitle: LocalizedStringResource = "intents.quick_run_title"
        static let quickRunDescription: LocalizedStringResource = "intents.quick_run_description"
        static let quickRunParameterWorkflow: LocalizedStringResource = "intents.quick_run_parameter_workflow"
        static let quickRunParameterInputText: LocalizedStringResource = "intents.quick_run_parameter_input_text"
        
        // MARK: - Run
        static let runWorkflowTitle: LocalizedStringResource = "intents.run_workflow_title"
        static let runWorkflowDescription: LocalizedStringResource = "intents.run_workflow_description"
        static let runWorkflowParameterWorkflow: LocalizedStringResource = "intents.run_workflow_parameter_workflow"
        static let runWorkflowParameterInputText: LocalizedStringResource = "intents.run_workflow_parameter_input_text"
        static let runWorkflowParameterInputTextDescription: LocalizedStringResource = "intents.run_workflow_parameter_input_text_description"
        
        static let runWorkflowDialogNotFound: LocalizedStringResource = "intents.run_workflow_dialog_not_found"
        static let runWorkflowDialogDone: LocalizedStringResource = "intents.run_workflow_dialog_done"
        static let runWorkflowDialogFailed: LocalizedStringResource = "intents.run_workflow_dialog_failed"
        
        static func simple(_ key: String, in applicationName: String) -> AppShortcutPhrase<RunWorkflowIntent> {
            let format = NSLocalizedString(key, comment: "")
            let phrase = String(format: format, applicationName)
            return AppShortcutPhrase(phrase)
        }
        
        static func workflow(_ key: String, in applicationName: String) -> AppShortcutPhrase<RunWorkflowIntent> {
            let format = NSLocalizedString(key, comment: "")
            let phrase = String(format: format, "\(\RunWorkflowIntent.workflow)", applicationName)
            return AppShortcutPhrase(phrase)
        }
    }
}
