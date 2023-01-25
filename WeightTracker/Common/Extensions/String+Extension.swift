//
//  String+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 25.01.2023.
//

import Foundation

extension String {
    
    func replaceDot() -> String {
            let textDouble = Double(self.replacingOccurrences(of: ",", with: ".")) ?? 0
            return String(format: "%.1f", textDouble)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "\(self)_comment")
      }
}
