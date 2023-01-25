//
//  UIColor+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit

extension UIColor {
    
    //MARK: - Button colors
    static let buttonBlueColor = UIColor(hex: "#1698B8")
    static let buttonWhiteColor = UIColor.white
    static let buttonGrayColor = UIColor(hex: "#D2D2D2")
    
    // MARK: - Text
    static let textPrimaryBlueColor = UIColor(hex: "#1698B8")
    static let textSecondaryBrownColor = UIColor(hex: "#9B7354")
    static let textSecondaryDarkBrownColor = UIColor(hex: "#A78A74")
    static let textWhiteColor = UIColor.white
    
    // MARK: - Background
    static let backgroundMainColor = UIColor(hex: "#FEF4EC")
    
    // MARK: - Onboarding
    static let onboardingDescriptionColor = UIColor(hex: "#78461D")
    static let onboardingPageControlCurrent = UIColor(hex: "#CAB4A4")
    static let onboardingPageControlSecondary = UIColor(hex: "#D9D9D9")
    static let onboardingBackItemColor = UIColor(hex: "#CAB4A4")
    static let keyboardButtonsBackgroundColor = UIColor(hex: "#CAB4A4")
    static let keyboardButtonsSelectedTextColor = UIColor(hex: "#1698B8")
    static let keyboardButtonsUnselectedTextColor = UIColor(hex: "#FFFFFF", alpha: 0.7)
    static let keyboardButtonsSelectedItemColor = UIColor(hex: "#FFFFFF")


    
    static let weightPrimary = UIColor(hex: "#1698B8")
    static let mainBackground = UIColor(hex: "#FEF4EC")
    static let buttonDisable = UIColor(hex: "#D2D2D2")
    static let buttonShadowColor = UIColor(hex: "#C38D61")
    static let whiteSeventy = UIColor(hex: "#FFFFFF", alpha: 0.7)
    static let keyboardBackground = UIColor(hex: "#D1D5DB")
    static let promtBigTitle = UIColor(hex: "#78461D")
    static let borderGray = UIColor(hex: "#D9D9D9")
    static let boldBlack = UIColor(hex: "#292D32")
    static let secondaryGrayText = UIColor(hex: "#828D9B")
    static let basicDark = UIColor(hex: "#192621")
    static let seporatorColor = UIColor(hex: " #EAEAEA")
    static let onboardCloseButton = UIColor(hex: "#A78A74")
    static let closeButtonGray = UIColor(hex: "#D0D0D0")

    static let waistMeasurementColor = UIColor(hex: "#F15626")
    static let chestMeasurementColor = UIColor(hex: "#D9821C")
    static let hipMeasurementColor = UIColor(hex: "#D62599")
    static let weightMeasurementColor = UIColor(hex: "#1698B8")
    
    static let waistDimensionBackgroundColor = UIColor(hex: "#F15626", alpha: 0.1)
    static let chestDimensionBackgroundColor = UIColor(hex: "#D9821C", alpha: 0.1)
    static let hipDimensionBackgroundColor = UIColor(hex: "#D62599", alpha: 0.1)
    static let weightDimensionBackgroundColor = UIColor(hex: "#1698B8", alpha: 0.1)
    
    static let waistMeasurementColor80 = UIColor(hex: "#F15626", alpha: 0.8)
    static let chestMeasurementColor80 = UIColor(hex: "#D9821C", alpha: 0.8)
    static let hipMeasurementColor80 = UIColor(hex: "#D62599", alpha: 0.8)
    static let weightMeasurementColor80 = UIColor(hex: "#1698B8", alpha: 0.8)
    
    static let waistDimensionBorderColor = UIColor(hex: "#F15626", alpha: 0.5)
    static let chestDimensionBorderColor = UIColor(hex: "#D9821C", alpha: 0.5)
    static let hipDimensionBorderColor = UIColor(hex: "#D62599", alpha: 0.5)
    static let weightDimensionBorderColor = UIColor(hex: "#1698B8", alpha: 0.5)
    
    static let textFieldBorderGrayColor = UIColor(hex: "#E5EAF1")
    static let textFieldShadowColor = UIColor(hex: "#D1D5DBBF")
    static let saveButtonBorderColor = UIColor(hex: "#82C8D9")
    static let topColorForAddMeasurementGradient = UIColor(hex: "#E8EDF4")
    
    static let weightWidgetBackgroundView = UIColor(hex: "#DFF8FE")
    
    // BMI Colors
    static let bmiMainColor = UIColor(hex: "#71B816")
    static let verySevUnderweight = UIColor(hex: "#4C48D4")
    static let sevUnderweigth = UIColor(hex: "#5293E0")
    static let underweight = UIColor(hex: "#47CCD6")
    static let normalWeight = UIColor(hex: "#45D859")
    static let overweight = UIColor(hex: "#E8E142")
    static let obeseClass1 = UIColor(hex: "#ECB83C")
    static let obeseClass2 = UIColor(hex: "#ED683E")
    static let obeseClass3 = UIColor(hex: "#C62D2D")
    static let bmiDescriptionLabelColor = UIColor(hex: "#9B7354")
    
    static let indicatorNameLabelColor = UIColor(hex: "#A78A74")
    static let blackoutBackground = UIColor(hex: "#000000", alpha: 0.25)
    
    // Milestone colors
    static let milestoneUnselectedColor = UIColor(hex: "#F3DDCC")
    static let milestoneMainColor = UIColor(hex: "#9B7354")
    static let milestoneUsualLabelColor = UIColor(hex: "#A78A74")
    static let redCircleProgressLineColor = UIColor(hex: "#E89F6B")
    static let greenCircleProgressLineColor = UIColor(hex: "#A6DD6F")
    static let pickMileShadowColor = UIColor(hex: "#C38D617D")
    
    // ChartView colors
    static let chartLineColor = UIColor(hex: "#FDD9BC")
    static let chartDateColor = UIColor(hex: "#A78A74")
    static let chartSecondGradientColor = UIColor(hex: "#F15626", alpha: 0.43)
    static let chartThirdGradientColor = UIColor(hex: "#F15626", alpha: 0.01)
    
    // Settings colors
    static let settingsTitleColor = UIColor(hex: "#9B7354")
    static let switchUnselectedColor = UIColor(hex: "#F4EAE2")
    static let avatarBorderColor = UIColor(hex: "#A78A74")

    //MARK: - Init HEX color
    convenience init(hex: String, alpha: CGFloat? = nil) {
        var hex: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hex.hasPrefix("#") {
            hex.remove(at: hex.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)
        
        var aValue: UInt64
        let rValue, gValue, bValue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (aValue, rValue, gValue, bValue) = (255, (rgbValue >> 4 & 0xF) * 17,
                                                (rgbValue >> 4 & 0xF) * 17, (rgbValue & 0xF) * 17)
        case 6: // RGB (24-bit)
            (aValue, rValue, gValue, bValue) = (255, rgbValue >> 16, rgbValue >> 8 & 0xFF, rgbValue & 0xFF)
        case 8: // ARGB (32-bit)
            (aValue, rValue, gValue, bValue) = (rgbValue >> 24, rgbValue >> 16 & 0xFF,
                                                rgbValue >> 8 & 0xFF, rgbValue & 0xFF)
        default: // gray as like systemGray
            (aValue, rValue, gValue, bValue) = (255, 123, 123, 129)
        }
        
        if let alpha = alpha, alpha >= 0, alpha <= 1 {
            aValue = UInt64(alpha * 255)
        }
        
        self.init(
            red: CGFloat(rValue) / 255,
            green: CGFloat(gValue) / 255,
            blue: CGFloat(bValue) / 255,
            alpha: CGFloat(aValue) / 255)
    }
    
    var hex: String {
        let cgColorInRGB = cgColor.converted(to: CGColorSpace(name: CGColorSpace.sRGB)!,
                                             intent: .defaultIntent,
                                             options: nil)!
        let colorRef = cgColorInRGB.components
        let r = colorRef?[0] ?? 0
        let g = colorRef?[1] ?? 0
        let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
        let a = cgColor.alpha
        
        var color = String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
        
        if a < 1 {
            color += String(format: "%02lX", lroundf(Float(a * 255)))
        }
        
        return color
    }
}
