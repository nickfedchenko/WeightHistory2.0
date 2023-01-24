//
//  FontService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit

final class FontService {
    
    static let shared = FontService()
    
    func localFont(size: CGFloat, bold: Bool) -> UIFont {
        if Locale.isLanguageRus {
            return R.font.sfProDisplayHeavy(size: size) ?? UIFont.systemFont(ofSize: size)
        } else {
            if bold {
                return R.font.promptBold(size: size) ?? UIFont.systemFont(ofSize: size)
            } else {
                return R.font.promptSemiBold(size: size) ?? UIFont.systemFont(ofSize: size)
            }
        }
    }
}
