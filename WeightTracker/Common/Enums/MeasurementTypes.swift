//
//  MeasurementTypes.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

enum MeasurementTypes {
    case chest
    case waist
    case hip
    case weight
    case bmi
    
    var color: UIColor  {
        switch self {
        case .chest:    return UIColor.chestMeasurementColor
        case .waist:    return UIColor.waistMeasurementColor
        case .hip:      return UIColor.hipMeasurementColor
        case .weight:   return UIColor.weightMeasurementColor
        case .bmi:      return UIColor.bmiMainColor
        }
    }
    
    var logKey: String {
        switch self {
        case .chest:
            return "chest_add"
        case .waist:
            return "waist_add"
        case .hip:
            return "hip_add"
        case .weight:
            return "weight_add"
        case .bmi:
            return ""
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .chest:    return UIColor.chestDimensionBackgroundColor
        case .waist:    return UIColor.waistDimensionBackgroundColor
        case .hip:      return UIColor.hipDimensionBackgroundColor
        case .weight:   return UIColor.weightDimensionBackgroundColor
        case .bmi:      return UIColor.bmiMainColor
        }
    }
    
    var unselectedItemColor: UIColor {
        switch self {
        case .chest:    return UIColor.chestMeasurementColor80
        case .waist:    return UIColor.waistMeasurementColor80
        case .hip:      return UIColor.hipMeasurementColor80
        case .weight:   return UIColor.weightMeasurementColor80
        case .bmi:      return UIColor.bmiMainColor
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .chest:    return UIColor.chestDimensionBorderColor
        case .waist:    return UIColor.waistDimensionBorderColor
        case .hip:      return UIColor.hipDimensionBorderColor
        case .weight:   return UIColor.weightDimensionBorderColor
        case .bmi:      return UIColor.bmiMainColor
        }
    }
    
    var title: String {
        switch self {
        case .chest:     return R.string.localizable.widgetChest()
        case .waist:     return R.string.localizable.widgetWaist()
        case .hip:       return R.string.localizable.widgetHip()
        case .weight:    return R.string.localizable.widgetWeight()
        case .bmi:       return R.string.localizable.widgetBmi()
        }
    }
}
