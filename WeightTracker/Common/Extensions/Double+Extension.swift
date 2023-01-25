//
//  Double+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

extension Double {
    
    private var referenceSize: (width: CGFloat, height: CGFloat) { (375, 812) }
    private var screenSize: CGSize { UIScreen.main.bounds.size }
    
    var fit: CGFloat {
        var ratio: CGFloat = 1
        if screenSize.height > referenceSize.height {
            ratio = screenSize.height / referenceSize.height
        }
        return CGFloat(self) * ratio
    }
    
    var fitY: CGFloat {
        var ratio: CGFloat = 1
        if screenSize.height >= referenceSize.height {
            ratio = screenSize.height / referenceSize.height
        } else {
            ratio = screenSize.height / referenceSize.height / 1.15
        }
        return CGFloat(self) * ratio
    }
    
    var fitW: CGFloat {
        let ratio = screenSize.width / referenceSize.width
        return CGFloat(self) * ratio
    }
    
    var fitH: CGFloat {
        let ratio = screenSize.height / referenceSize.height
        return CGFloat(self) * ratio
    }
    
    var fitWMore: CGFloat {
        let ratio = screenSize.width / referenceSize.width
        return ratio > 1 ? CGFloat(self) * ratio : CGFloat(self)
    }
    
}

    func roundTen(_ value: Double) -> Double {
        return round(value * 10.0) / 10.0
    }

    func roundHundred(_ value: Double) -> Double {
        return round(value * 100.0) / 100.0
    }

extension Double {
    func actualWeightValue() -> Double {
        if UserSettingsService.shared.isImperial {
            return self * 2.20462
        } else {
            return self
        }
    }
    
    func actualLengthValue() -> Double {
        if UserSettingsService.shared.isImperial {
            return self * 0.0328084
        } else {
            return self
        }
    }
    
    func lbsToKgs() -> Double {
        return self / 2.20462
    }
    
    func ftToCm() -> Double {
        self / 0.0328084
    }
}
