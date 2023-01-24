//
//  Locale+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import Foundation

extension Locale {
    static var isLanguageRus: Bool {
        if #available(iOS 16, *) {
            return Locale.current.language.languageCode?.identifier == "ru"
        } else {
            return Locale.current.languageCode == "ru"
        }
    }
}
