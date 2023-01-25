//
//  UITextField+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import UIKit

extension UITextField {
    
    // MARK: - Validation of height
    func isHeightValid(with unit: LengthUnits) -> Validation {
        
        guard let height = Double(text?.replaceDot() ?? "0") else { return .outOfRange}
        
        if text == nil || text == "" || text == " " || text == "0" {
            return .empty
        }

        switch unit {
            
        case .cm:
            if height > 10 && height < 250 {
                return .normal
            } else {
                return .outOfRange
            }
            
        case .ft:
            if height > 0.3 && height < 8.2 {
                return .normal
            } else {
                return .outOfRange
            }
        }
    }
    
    // MARK: - Validation of Weight
    func isWeightValid(with unit: WeightUnits) -> Validation {
        
        guard let weight = Double(text?.replaceDot() ?? "0") else { return .outOfRange}
        
        if text == nil || text == "" || text == " " || text == "0" {
            return .empty
        }

        switch unit {
            
        case .kg:
            if weight > 2 && weight < 250 {
                return .normal
            } else {
                return .outOfRange
            }
            
        case .lbs:
            if weight > 4 && weight < 550 {
                return .normal
            } else {
                return .outOfRange
            }
            
        }
    }
}
