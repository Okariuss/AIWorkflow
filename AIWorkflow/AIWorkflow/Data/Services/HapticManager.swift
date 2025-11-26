//
//  HapticManager.swift
//  AIWorkflow
//
//  Created by Okan Orkun on 21.11.2025.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()
    
    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        switch style {
        case .light: impactLight.impactOccurred()
        case .medium: impactMedium.impactOccurred()
        case .heavy: impactHeavy.impactOccurred()
        case .soft: impactLight.impactOccurred()
        case .rigid: impactHeavy.impactOccurred()
        @unknown default: impactMedium.impactOccurred()
        }
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        notification.notificationOccurred(type)
    }
    
    func selectionChanged() {
        selection.selectionChanged()
    }
}
