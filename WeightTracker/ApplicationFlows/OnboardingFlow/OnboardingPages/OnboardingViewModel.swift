//
//  OnboardingViewModel.swift
//  WeightTracker
//
//  Created by Andrey Alymov on 24.01.2023.
//

import Amplitude
import UIKit
import CoreData

final class OnboardingViewModel {
    
    // MARK: - Property list
    private let dbService = CoreDataService.shared
    private let amplitude = Amplitude.instance()
    
    var isUserMale: Bool {
        get {
            UserSettingsService.shared.isUserMale
        }
        set {
            UserSettingsService.shared.isUserMale = newValue
        }
    }
    
    // MARK: - Init
    init() {}
    
    // MARK: - Constarints properties
    var topScreenImageViewConstarint: CGFloat {
        UIDevice.screenType == .less ? 60 : 100
    }
    
    var bottomDatePickerConstraint: CGFloat {
        UIDevice.screenType == .less ? -20 : -50
    }
    
    // MARK: - Saving user data
    func saveUserGender(value: Int16) {
        dbService.saveUserGender(value: value)
        amplitude.logEvent("onb_1_complete", withEventProperties: ["sex": (isUserMale ? "male" : "female")])
    }
    
    func saveUserHeight(value: String, unit: LengthUnits) {
        let userHeight = unifyLengthEnteredData(text: value, unit: unit)
        dbService.saveUserHeight(value: userHeight)
    }
    
    func saveUserBirthday(date: Date) {
        dbService.saveUserBirthday(date: date)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        let dateString = formatter.string(from: date)
        amplitude.logEvent("onb_2_complete", withEventProperties: ["date" : dateString])
    }
    
    func saveUserStartWeight(value: String, unit: WeightUnits) {
        let userStartWeight = unifyWeightEnteredData(text: value, unit: unit)
        dbService.saveUserStartWeight(value: userStartWeight)
        amplitude.logEvent("onb_3_complete_weight", withEventProperties: ["unifiedWeight" : value])
    }
    
    func saveUserGoalWeight(value: String, unit: WeightUnits) {
        let goalWeight = unifyWeightEnteredData(text: value, unit: unit)
        dbService.saveUserGoalWeight(value: goalWeight)
        amplitude.logEvent("onb_4_complete", withEventProperties: ["targetUnifiedWeight": value])
    }
    
    func saveUserGoal(answer: String) {
        dbService.saveUserGoal(answer: answer)
    }
    
    func saveUserWeightFrequency(answer: String) {
        dbService.saveUserWeightFrequency(answer: answer)
        amplitude.logEvent("onb_5_complete", withEventProperties: ["frequency" : answer])
    }
    
    // MARK: - UNIFY ENTERED DATA
    private func unifyWeightEnteredData(text: String, unit: WeightUnits) -> Double {
        guard let doubleValue = Double(text) else { return 0 }
        if unit == .kg {
            return Double(String(format: "%.1f", doubleValue)) ?? 0
        } else {
            return Double(String(format: "%1.f", doubleValue.lbsToKgs())) ?? 0
        }
    }
    
    private func unifyLengthEnteredData(text: String, unit: LengthUnits) -> Double {
        guard let doubleValue = Double(text) else { return 0 }
        if unit == .cm {
            return Double(String(format: "%.1f", doubleValue)) ?? 0
        } else {
            return Double(String(format: "%1.f", doubleValue.ftToCm())) ?? 0
        }
    }
}

