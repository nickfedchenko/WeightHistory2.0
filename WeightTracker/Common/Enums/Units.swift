//
//  Units.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import Foundation

enum Units {
    case height
    case weight
}

enum LengthUnits {
    case cm
    case ft
    
    var stringValue: String {
        switch self {
        case .cm: return R.string.localizable.unitsCm()
        case .ft: return R.string.localizable.unitsFt()
        }
    }
}

enum WeightUnits {
    case kg
    case lbs
    
    var stringValue: String {
        switch self {
        case .kg: return R.string.localizable.unitsKg()
        case .lbs: return R.string.localizable.unitsLbs()
        }
    }
}
