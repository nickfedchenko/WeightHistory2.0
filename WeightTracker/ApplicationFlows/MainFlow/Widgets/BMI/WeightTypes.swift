//
//  WeightTypes.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 27.01.2023.
//

import UIKit

enum WeightTypes {
    
    case verySevUnderweigth
    case sevUnderweigth
    case underweight
    case normalWeight
    case overweight
    case obeseClass1
    case obeseClass2
    case obeseClass3

    
    var color: UIColor {
        switch self {
        case .verySevUnderweigth:   return .verySevUnderweight
        case .sevUnderweigth:       return .sevUnderweigth
        case .underweight:          return .underweight
        case .normalWeight:         return .normalWeight
        case .overweight:           return .overweight
        case .obeseClass1:          return .obeseClass1
        case .obeseClass2:          return .obeseClass2
        case .obeseClass3:          return .obeseClass3
        }
    }
    
    var text: String {
        switch self {
        case .verySevUnderweigth:   return R.string.localizable.bmiWidgetVerySevUnderweigth()
        case .sevUnderweigth:       return R.string.localizable.bmiWidgetSevUnderweigth()
        case .underweight:          return R.string.localizable.bmiWidgetUnderweight()
        case .normalWeight:         return R.string.localizable.bmiWidgetNormalWeight()
        case .overweight:           return R.string.localizable.bmiWidgetOverWeight()
        case .obeseClass1:          return R.string.localizable.bmiWidgetObeseClass1()
        case .obeseClass2:          return R.string.localizable.bmiWidgetObeseClass2()
        case .obeseClass3:          return R.string.localizable.bmiWidgetObeseClass3()
        }
    }
    
    var indexText: String {
        switch self {
        case .verySevUnderweigth:   return "< 16.0"
        case .sevUnderweigth:       return "16.0 - 16.9"
        case .underweight:          return "17.0 - 18.4"
        case .normalWeight:         return "18.5 - 24.9"
        case .overweight:           return "25.0 - 29.9"
        case .obeseClass1:          return "30.0 - 34.9"
        case .obeseClass2:          return "35.0 - 39.9"
        case .obeseClass3:          return "> 40.0"
        }
    }
}
