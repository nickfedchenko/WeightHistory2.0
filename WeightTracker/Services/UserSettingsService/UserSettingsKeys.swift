//
//  UserSettingsKeys.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import Foundation

protocol USKeysProtocol {
    var rawValue: String { get }
}

enum UserSettingsKeys: String, USKeysProtocol {
    case lenght
    case weight
    case isFirstLaunch
    case isUserSptilGoal
    case milestonesNumber
    case isHapticFedbackOn
    case isAppleHelthOn
    case isImeprial
}
