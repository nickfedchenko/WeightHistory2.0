//
//  UIDevice+Extension.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import UIKit

extension UIDevice {
    
    enum ScreenType {
        case x932
        case x926
        case x896
        case x852
        case x844
        case x812
        case less
    }
    
    static var screenType: ScreenType {
        switch UIScreen.main.bounds.height {
        case 932 : return .x932
        case 926 : return .x926
        case 896 : return .x896
        case 852 : return .x852
        case 844 : return .x844
        case 812 : return .x812
        case 0..<812: return .less
        default:   return .x812
        }
    }
    
}
