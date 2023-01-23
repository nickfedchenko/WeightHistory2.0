//
//  HapticFeedbackService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import UIKit

enum HapticFeedback {
    
    case error
    case success
    case warning
    case light
    case medium
    case heavy
    case soft
    case rigid
    case selection
    
    public func vibrate() {
        if UserSettingsService.shared.getIsHapticFeedbackOn() {
            switch self {
            case .error:
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            case .success:
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            case .warning:
                UINotificationFeedbackGenerator().notificationOccurred(.warning)
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            case .soft:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            case .rigid:
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            }
        } else {
            return
        }
    }
}

