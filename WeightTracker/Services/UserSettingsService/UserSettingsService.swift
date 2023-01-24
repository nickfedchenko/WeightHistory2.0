//
//  UserSettingsService.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 23.01.2023.
//

import Foundation

private protocol USServiceProtocol {
    func getValue<T>(key: UserSettingsKeys) -> T?
    func setValue<T>(key: UserSettingsKeys, value: T?)
    func removeValue(key: UserSettingsKeys)
}

final class UserSettingsService: USServiceProtocol {
    
    static let shared = UserSettingsService()
    
    // MARK: - Init
    private init() {}
        
    // MARK: - Generic private methods
    fileprivate func setValue<T>(key: UserSettingsKeys, value: T?) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    fileprivate func getValue<T>(key: UserSettingsKeys) -> T? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
    
    fileprivate func removeValue(key: UserSettingsKeys) {
        UserDefaults.standard.set(nil, forKey: key.rawValue)
    }
    
    // MARK: - Units
    func saveUserUnits(lenght: LengthUnits, width: WeightUnits) {
        setValue(key: .weight, value: width)
        setValue(key: .lenght, value: lenght)
    }
    
    func saveUserLengthUnit(lenght: LengthUnits) {
        setValue(key: .lenght, value: lenght.stringValue)
    }
    
    func saveUserWeighthUnit(weight: WeightUnits) {
        setValue(key: .weight, value: weight.stringValue)
    }
    
    func getUserLenghtUnit() -> String {
        let length = getValue(key: .lenght) ?? R.string.localizable.unitsCm()
        return length
    }
    
    var isImperial: Bool {
        get {
            getValue(key: .isImeprial) ?? false
        }
        set {
            setValue(key: .isImeprial, value: newValue)
        }
    }
    
    func getUserWeighthUnit() -> String {
        let weight = getValue(key: .weight) ?? R.string.localizable.unitsKg()
        return weight
    }
    
    // MARK: - Checking is onboarding screens passed?
    func onboardingWillNotShowingMore() {
        setValue(key: .isOnboardingPassed, value: false)
    }
    
    func isOnboardingPassed() -> Bool {
        guard let isOnboardingPassed: Bool = getValue(key: .isOnboardingPassed) else { return true }
        return isOnboardingPassed
    }
    
    // MARK: - Milestones
    func setIsUserSplitGoal(value: Bool) {
        setValue(key: .isUserSptilGoal, value: value)
    }
    
    func getIsUserSplitGoal() -> Bool {
        guard let isUserSplitGoal: Bool = getValue(key: .isUserSptilGoal) else { return true }
        return isUserSplitGoal
    }
    
    func setMilestonesNumber(index: Int) {
        setValue(key: .milestonesNumber, value: index)
    }
    
    func getMilestonesNumber() -> Int {
        guard let isUserSplitGoal: Int = getValue(key: .milestonesNumber) else { return 10 }
        return isUserSplitGoal
    }
    
    // MARK: - UserSettingsVC
    func setIsHapticFeedbackOn(value: Bool) {
        setValue(key: .isHapticFedbackOn, value: value)
    }
    
    func setIsAppleHealthOn(value: Bool) {
        setValue(key: .isAppleHelthOn, value: value)
    }
    
    func setIsUserMale(value: Bool) {
        setValue(key: .isUserMale, value: value)
    }
    
    var isUserMale: Bool {
        get {
            getValue(key: .isUserMale) ?? false
        }
        set {
            setValue(key: .isUserMale, value: newValue)
        }
    }
    
    func getIsHapticFeedbackOn() -> Bool {
        guard let isHapticOn: Bool = getValue(key: .isHapticFedbackOn) else { return true }
        return isHapticOn
    }
    
    func getIsAppleHealthOn() -> Bool {
        guard let isAppleHealthOn: Bool = getValue(key: .isAppleHelthOn) else { return false }
        return isAppleHealthOn
    }
    
}
