//
//  WidgetSizeService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 26.01.2023.
//

import UIKit

struct WidgetSizeService: CustomStringConvertible {
    
    var description: String {
        return """
    Current view has:
        - height: \(height)
    """
    }
    
    enum WidgetViewConfigurationType {
        case large, medium, compact, small
    }
    
    // MARK: - Private properties
    private var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    private var indentBetween: CGFloat = 16
    
    // MARK: - Public properties
    var sideIndent: CGFloat = {
        if UIDevice.screenType == .x932  {
            return 25
        } else if UIDevice.screenType == .x852 {
            return 25.5
        } else {
            return 24
        }
    }()
    
    var type: WidgetViewConfigurationType = .large
    
    var widgetWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let insets: CGFloat = sideIndent * 2
        return (screenWidth - insets - indentBetween) / 2
    }
    
    /// Константа для констрейта высоты, применяется самостоятельно.
    var height: CGFloat {
        switch UIDevice.screenType {
            
        case .x932:
            switch type {
            case .large:     return 303
            case .medium:    return 182
            case .compact:   return 120
            case .small:     return 72
            }
            
        case .x926:
            switch type {
            case .large:     return 303
            case .medium:    return 182
            case .compact:   return 120
            case .small:     return 72
            }
            
        case .x896:
            switch type {
            case .large:     return 280
            case .medium:    return 175
            case .compact:   return 112
            case .small:     return 72
            }
            
        case .x852:
            switch type {
            case .large:     return 240
            case .medium:    return 163
            case .compact:   return 98.67
            case .small:     return 72
            }
            
        case .x844:
            switch type {
            case .large:     return 240
            case .medium:    return 163
            case .compact:   return 98.67
            case .small:     return 72
            }
            
        case .x812:
            switch type {
            case .large:     return 215.5
            case .medium:    return 155.5
            case .compact:   return 90.5
            case .small:     return 72
            }
            
        case .less:
            switch type {
            case .large:     return 215.5
            case .medium:    return 155.5
            case .compact:   return 90.5
            case .small:     return 72
            }
        }
    
    }
    
    //MARK: - Init
    init(type: WidgetViewConfigurationType = .medium) {
        self.type = type
    }
    
}

